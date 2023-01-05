%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_Dat1FidFileIncr
%% 
%%  Update function for decrease scan number of spectrum 1.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag data


FCTNAME = 'SP2_Data_Dat1FidFileIncr';


%--- confirm data format ---
if strcmp(data.spec1.fidDir(end-4:end-1),'.fid')                % Varian
    fprintf('Data format: Varian\n');
    flag.dataManu = 1;        
elseif strcmp(data.spec1.fidName,'fid') || strcmp(data.spec1.fidName,'rawdata.job0')              % Bruker
    fprintf('Data format: Bruker\n');
    flag.dataManu = 2;     
elseif strcmp(data.spec1.fidFile(end-1:end),'.7')               % GE
    fprintf('Data format: General Electric\n');
    flag.dataManu = 3;
elseif strcmp(data.spec1.fidFile(end-3:end),'.rda')             % Siemens
    fprintf('Data format: Siemens (.rda)\n');
    flag.dataManu = 4;
elseif strcmp(data.spec1.fidFile(end-3:end),'.dcm')             % DICOM
    fprintf('Data format: DICOM\n');
    flag.dataManu = 5;
elseif strcmp(data.spec1.fidFile(end-3:end),'.dat')             % Siemens raw
    fprintf('Data format: Siemens (.dat)\n');
    flag.dataManu = 6;
elseif strcmp(data.spec1.fidFile(end-3:end),'.raw')             % Philips raw
    fprintf('Data format: Philips (.raw)\n');
    flag.dataManu = 7;
elseif strcmp(data.spec1.fidFile(end-4:end),'.SDAT')            % Philips collapsed
    fprintf('Data format: Philips (.SDAT)\n');
    flag.dataManu = 8;
elseif strcmp(data.spec1.fidFile(end-3:end),'.IMA')             % DICOM
    fprintf('Data format: DICOM (.IMA)\n');
    flag.dataManu = 9;
else
    fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME);
    return
end

%--- derive study path ---
if flag.OS==1            % Linux
    slashInd = find(data.spec1.fidDir=='/');
elseif flag.OS==2        % Mac
    slashInd = find(data.spec1.fidDir=='/');
else                     % PC
    slashInd = find(data.spec1.fidDir=='\');
end

%--- directory extraction ---
if flag.dataManu==1 || flag.dataManu==2                         % Varian || Bruker
    if length(slashInd)<2
        set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
        fprintf('%s ->\nInvalid parent directory for data set 1. Program aborted.\n',FCTNAME);
        return
    end
    studyDir = data.spec1.fidDir(1:slashInd(end-1));
else                                                            % GE, Siemens, Philips
    if length(slashInd)<1
        set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
        fprintf('%s ->\nInvalid parent directory for data set 1. Program aborted.\n',FCTNAME);
        return
    end
    studyDir = data.spec1.fidDir(1:slashInd(end));
end

%--- path handling for scan number identification ---
dirStruct = dir(studyDir);
dirLen    = length(dirStruct);
altCnt    = 0;                  % alternative .fid directory counter (init)
altStruct = [];                 % init alternative fid (directory) structure

%--- vendor-specfic path handling ---
switch flag.dataManu                                            
    case 1                                                      % Varian
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.fid') & dirStruct(sCnt).isdir==1);    % all .fid directories
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        scanName   = data.spec1.fidDir(slashInd(end-1)+1:slashInd(end)-1);
        [scanStr,fake] = strtok(scanName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        expDir = '';                        % init / reset
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.fid\']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                expDir = [studyDir num2str(expNew) '.fid\'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and path from alternative
                % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        expDir = [studyDir altStruct(altCnt).name '\'];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end

            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if isempty(expDir)
            fprintf('%s ->\nNo valid directory found.\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        dat1FidFileTmp = [expDir 'fid'];

        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = data.spec1.fidFile(1:end-3);                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidDir 'procpar'];            % adopt procpar (/method) file path
        data.spec1.acqpFile = [data.spec1.fidDir 'text'];               % adopt text (/acqp) file path
        % end of Varian
        
    case 2                                                      % Bruker
        if strcmp(data.spec1.fidFile(end-2:end),'fid')                  % old/new fid file
            %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if dirStruct(sCnt).isdir==1 && ~strcmp(dirStruct(sCnt).name,'.') && ~strcmp(dirStruct(sCnt).name,'..')       % is directory
                    if SP2_CheckFileExistenceR([studyDir dirStruct(sCnt).name '/fid']),0   % contains fid file
                        underInd = findstr(dirStruct(sCnt).name,'_');
                        % check for underscore and reasonable string-to-number conversion
                        if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                            altCnt = altCnt + 1;
                            altStruct(altCnt).name   = dirStruct(sCnt).name;
                            altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                        end
                    end
                end
            end
            altN = altCnt;    % number of alternative .fid directories

            %--- scan number extraction ---
            scanName   = data.spec1.fidDir(slashInd(end-1)+1:slashInd(end)-1);
            [scanStr,fake] = strtok(scanName,'_');
            expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
            expNewOrig = expNew;

            %--- assignment of experiment directory ---
            expDir = '';                        % init / reset
            maxGap = 100;                       % maximum gap allowed between scans in automated search
            f_succ = 0;                         % init success flag
            gapCnt = 0;                         % gap counter (on top of immediate neighbor)
            while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
                %--- scan extraction ---
                if SP2_CheckDirAccessR([studyDir num2str(expNew) '\']),flag.verbose
                    % direct assignment of 1.fid, 2.fid, 3.fid, ...
                    expDir = [studyDir num2str(expNew) '\'];
                    f_succ = 1;
                    gapCnt = maxGap;
                else
                    % try to extract/deduce scan number and path from alternative
                    % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                    for altCnt = 1:altN
                        if expNew==altStruct(altCnt).number
                            expDir = [studyDir altStruct(altCnt).name '\'];
                            f_succ = 1;
                            gapCnt = maxGap;
                        end
                    end
                end

                %--- counter update ---
                expNew = expNew + 1;            % serial experiment number
                gapCnt = gapCnt + 1;            % gap counter update
            end

            %--- check if unique scan could be identified ---
            if ~f_succ
                fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                        FCTNAME,expNewOrig)
                set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
                return
            end
            if isempty(expDir)
                fprintf('%s ->\nNo valid directory found.\n',FCTNAME);
                set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
                return
            end
            dat1FidFileTmp = [expDir 'fid'];

            if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
                fprintf('%s ->\nAssigned file can''t be found...\n',FCTNAME);
                set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
                return
            end
            set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
            data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
            clear dat1FidFileTmp

            %--- update paths ---
            data.spec1.fidDir = data.spec1.fidFile(1:end-3);                % update scan path
        else                                % new rawdata.job0
            %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if dirStruct(sCnt).isdir==1 && ~strcmp(dirStruct(sCnt).name,'.') && ~strcmp(dirStruct(sCnt).name,'..')       % is directory
                    if SP2_CheckFileExistenceR([studyDir dirStruct(sCnt).name '/rawdata.job0']),0   % contains fid file
                        underInd = findstr(dirStruct(sCnt).name,'_');
                        % check for underscore and reasonable string-to-number conversion
                        if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                            altCnt = altCnt + 1;
                            altStruct(altCnt).name   = dirStruct(sCnt).name;
                            altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                        end
                    end
                end
            end
            altN = altCnt;    % number of alternative .fid directories

            %--- scan number extraction ---
            scanName   = data.spec1.fidDir(slashInd(end-1)+1:slashInd(end)-1);
            [scanStr,fake] = strtok(scanName,'_');
            expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
            expNewOrig = expNew;

            %--- assignment of experiment directory ---
            expDir = '';                        % init / reset
            maxGap = 100;                       % maximum gap allowed between scans in automated search
            f_succ = 0;                         % init success flag
            gapCnt = 0;                         % gap counter (on top of immediate neighbor)
            while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
                %--- scan extraction ---
                if SP2_CheckDirAccessR([studyDir num2str(expNew) '\']),flag.verbose
                    % direct assignment of 1.fid, 2.fid, 3.fid, ...
                    expDir = [studyDir num2str(expNew) '\'];
                    f_succ = 1;
                    gapCnt = maxGap;
                else
                    % try to extract/deduce scan number and path from alternative
                    % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                    for altCnt = 1:altN
                        if expNew==altStruct(altCnt).number
                            expDir = [studyDir altStruct(altCnt).name '\'];
                            f_succ = 1;
                            gapCnt = maxGap;
                        end
                    end
                end

                %--- counter update ---
                expNew = expNew + 1;            % serial experiment number
                gapCnt = gapCnt + 1;            % gap counter update
            end

            %--- check if unique scan could be identified ---
            if ~f_succ
                fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                        FCTNAME,expNewOrig)
                set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
                return
            end
            if isempty(expDir)
                fprintf('%s ->\nNo valid directory found.\n',FCTNAME);
                set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
                return
            end
            dat1FidFileTmp = [expDir 'rawdata.job0'];

            if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
                fprintf('%s ->\nAssigned file can''t be found...\n',FCTNAME);
                set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
                return
            end
            set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
            data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
            clear dat1FidFileTmp

            %--- update paths ---
            data.spec1.fidDir = data.spec1.fidFile(1:end-12);                % update scan path
        end
        
        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidDir 'method'];         % adopt method file path
        data.spec1.acqpFile = [data.spec1.fidDir 'acqp'];           % adopt acqp file path
        % end of Bruker
        
    case 3                                                      % GE
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.7') & dirStruct(sCnt).isdir==0);    % all .7 files
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        [scanStr,fake] = strtok(data.spec1.fidName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.7']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = [studyDir num2str(expNew) '.7'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and from alternative
                % files (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        dat1FidFileTmp = [studyDir altStruct(altCnt).name];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end
            
            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = studyDir;                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidDir 'geMethod'];         % adopt method file path
        data.spec1.acqpFile = [data.spec1.fidDir 'geAcqp'];           % adopt acqp file path
        % end of GE
        
    case 4                                                      % Siemens .rda
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.rda') & dirStruct(sCnt).isdir==0);    % all .rda files
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        [scanStr,fake] = strtok(data.spec1.fidName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.rda']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = [studyDir num2str(expNew) '.rda'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and from alternative
                % files (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        dat1FidFileTmp = [studyDir altStruct(altCnt).name];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end
            
            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = studyDir;                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidDir 'rdaMethod'];         % adopt method file path
        data.spec1.acqpFile = [data.spec1.fidDir 'rdaAcqp'];           % adopt acqp file path
        % end of Siemens .rda
        
    case 5                                                      % DICOM
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.dcm') & dirStruct(sCnt).isdir==0);    % all .dcm files
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        [scanStr,fake] = strtok(data.spec1.fidName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.dcm']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = [studyDir num2str(expNew) '.dcm'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and from alternative
                % files (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        dat1FidFileTmp = [studyDir altStruct(altCnt).name];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end
            
            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = studyDir;                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidDir 'dcmMethod'];         % adopt method file path
        data.spec1.acqpFile = [data.spec1.fidDir 'dcmAcqp'];           % adopt acqp file path
        % end of DICOM
        
    case 6                                                      % Siemens .dat
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.dat') & dirStruct(sCnt).isdir==0);    % all .dat files
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        [scanStr,fake] = strtok(data.spec1.fidName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.dat']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = [studyDir num2str(expNew) '.dat'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and from alternative
                % files (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        dat1FidFileTmp = [studyDir altStruct(altCnt).name];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end
            
            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = studyDir;                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidDir 'datMethod'];         % adopt method file path
        data.spec1.acqpFile = [data.spec1.fidDir 'datAcqp'];           % adopt acqp file path
        % end of Siemens .dat

    case 7                                                      % Philips .raw
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.raw') & dirStruct(sCnt).isdir==0);    % all .raw files
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        [scanStr,fake] = strtok(data.spec1.fidName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.raw']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = [studyDir num2str(expNew) '.raw'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and from alternative
                % files (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        dat1FidFileTmp = [studyDir altStruct(altCnt).name];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end
            
            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = studyDir;                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidFile(1:end-4) '.sin'];       % method file path
        data.spec1.acqpFile = [data.spec1.fidFile(1:end-4) '.lab'];         % acqp file path
        
        % end of Philips .raw

    case 8                                                      % Philips .SDAT
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.SDAT') & dirStruct(sCnt).isdir==0);    % all .SDAT files
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        [scanStr,fake] = strtok(data.spec1.fidName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.SDAT']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = [studyDir num2str(expNew) '.SDAT'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and from alternative
                % files (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        dat1FidFileTmp = [studyDir altStruct(altCnt).name];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end
            
            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = studyDir;                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidFile(1:end-5) '.SPAR'];      % method file path
        data.spec1.acqpFile = [data.spec1.fidDir 'philAcq'];                % fake acqp file path
        
        % end of Philips .SDAT
        
        
        
    case 9                                                      % DICOM .IMA
        %--- extract potential scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.IMA') & dirStruct(sCnt).isdir==0);    % all .IMA files
                underInd = findstr(dirStruct(sCnt).name,'_');
                % check for underscore and reasonable string-to-number conversion
                if any(underInd) && any(str2double(dirStruct(sCnt).name(1:underInd(1)-1)))
                    altCnt = altCnt + 1;
                    altStruct(altCnt).name   = dirStruct(sCnt).name;
                    altStruct(altCnt).number = str2double(dirStruct(sCnt).name(1:underInd(1)-1));
                end
            end
        end
        altN = altCnt;    % number of alternative .fid directories

        %--- scan number extraction ---
        [scanStr,fake] = strtok(data.spec1.fidName,'_');
        expNew     = str2double(scanStr) + 1;             % new scan number, 1 higher
        expNewOrig = expNew;

        %--- assignment of experiment directory ---
        maxGap = 100;                       % maximum gap allowed between scans in automated search
        f_succ = 0;                         % init success flag
        gapCnt = 0;                         % gap counter (on top of immediate neighbor)
        while gapCnt<maxGap                 % find next available scan, extra counter on top of basic
            %--- scan extraction ---
            if SP2_CheckDirAccessR([studyDir num2str(expNew) '.IMA']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = [studyDir num2str(expNew) '.IMA'];
                f_succ = 1;
                gapCnt = maxGap;
            else
                % try to extract/deduce scan number and from alternative
                % files (like 005_matXXX_fovXXX_dateXXX.fid)
                for altCnt = 1:altN
                    if expNew==altStruct(altCnt).number
                        dat1FidFileTmp = [studyDir altStruct(altCnt).name];
                        f_succ = 1;
                        gapCnt = maxGap;
                    end
                end
            end
            
            %--- counter update ---
            expNew = expNew + 1;            % serial experiment number
            gapCnt = gapCnt + 1;            % gap counter update
        end

        %--- check if unique scan could be identified ---
        if ~f_succ
            fprintf('%s ->\nNo scan %i or higher found in current data directory. Program aborted\n',...
                    FCTNAME,expNewOrig)
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        if ~SP2_CheckFileExistenceR(dat1FidFileTmp)
            fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME);
            set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
            return
        end
        set(fm.data.spec1FidFile,'String',dat1FidFileTmp)
        data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
        clear dat1FidFileTmp

        %--- update paths ---
        data.spec1.fidDir = studyDir;                % update scan path

        %--- update parameter files ---
        data.spec1.methFile = [data.spec1.fidDir 'imaMethod'];         % adopt method file path
        data.spec1.acqpFile = [data.spec1.fidDir 'imaAcqp'];           % adopt acqp file path
        % end of DICOM .IMA
            
end

%--- file name extraction ---
if flag.OS==1            % Linux
    slashInd = find(data.spec1.fidFile=='/');
elseif flag.OS==2        % Mac
    slashInd = find(data.spec1.fidFile=='/');
else                     % PC
    slashInd = find(data.spec1.fidFile=='\');
end
data.spec1.fidName = data.spec1.fidFile(slashInd(end)+1:end);

%--- update flag display ---
SP2_Data_DataWinUpdate

%--- check pars file existence
% Varian OR Bruker OR Philips .raw OR Philips .sdat
if flag.dataManu==1 || flag.dataManu==2 || flag.dataManu==7 || flag.dataManu==8           
    if ~SP2_CheckFileExistence(data.spec1.methFile)
        return
    end
end
% Bruker OR Philips .raw
if flag.dataManu==2 || flag.dataManu==7           
    if ~SP2_CheckFileExistence(data.spec1.acqpFile)
        return
    end
end




