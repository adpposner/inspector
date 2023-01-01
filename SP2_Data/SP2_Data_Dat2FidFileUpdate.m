%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat2FidFileUpdate
%% 
%%  Update function for data path of (fid file of) spectrum 1.
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag data


FCTNAME = 'SP2_Data_Dat2FidFileUpdate';

%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
dat2FidFileTmp = get(fm.data.spec2FidFile,'String');
if ~any(dat2FidFileTmp=='/') && ~any(dat2FidFileTmp=='\') && ...
   ~isnan(str2double(dat2FidFileTmp))            % direct scan assignment

    %--- confirm data existence ---
    if ~SP2_CheckFileExistenceR(data.spec2.fidFile)
        return
    end

    %--- confirm data format ---
    if strcmp(data.spec2.fidDir(end-4:end-1),'.fid')                % Varian
        fprintf('Data format: Varian\n')
        flag.dataManu = 1;        
    elseif strcmp(data.spec2.fidName,'fid') || strcmp(data.spec2.fidName,'fid.refscan') || ...  % Bruker
           strcmp(data.spec1.fidName,'rawdata.job0') || strcmp(data.spec1.fidName,'rawdata.job1')
        fprintf('Data format: Bruker\n')
        flag.dataManu = 2;     
    elseif strcmp(data.spec2.fidFile(end-1:end),'.7')               % GE
        fprintf('Data format: General Electric\n')
        flag.dataManu = 3;
    elseif strcmp(data.spec2.fidFile(end-3:end),'.rda')             % Siemens
        fprintf('Data format: Siemens (.rda)\n')
        flag.dataManu = 4;
    elseif strcmp(data.spec2.fidFile(end-3:end),'.dcm')             % DICOM
        fprintf('Data format: DICOM\n')
        flag.dataManu = 5;
    elseif strcmp(data.spec2.fidFile(end-3:end),'.dat')             % Siemens
        fprintf('Data format: Siemens (.dat)\n')
        flag.dataManu = 6;
    elseif strcmp(data.spec2.fidFile(end-3:end),'.raw')             % Philips raw
        fprintf('Data format: Philips (.raw)\n')
        flag.dataManu = 7;
    elseif strcmp(data.spec2.fidFile(end-4:end),'.SDAT')            % Philips collapsed
        fprintf('Data format: Philips (.SDAT)\n')
        flag.dataManu = 8;
    elseif strcmp(data.spec2.fidFile(end-3:end),'.IMA')             % DICOM
        fprintf('Data format: DICOM (.IMA)\n')
        flag.dataManu = 9;
    else
        fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME)
        return
    end

    %--- derive study path ---
    if flag.OS==1            % Linux
        slashInd = find(data.spec2.fidDir=='/');
    elseif flag.OS==2        % Mac
        slashInd = find(data.spec2.fidDir=='/');
    else                        % PC
        slashInd = find(data.spec2.fidDir=='\');
    end
    
    %--- directory extraction ---
    if flag.dataManu==1 || flag.dataManu==2
        if length(slashInd)<2
            fprintf('%s ->\nInvalid parent directory for scan 2. Program aborted.\n',FCTNAME)
            set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
            return
        end
        studyDir = data.spec2.fidDir(1:slashInd(end-1));
    else
        if length(slashInd)<1
            fprintf('%s ->\nInvalid parent directory for scan 2. Program aborted.\n',FCTNAME)
            set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
            return
        end
        studyDir = data.spec2.fidDir(1:slashInd(end));
    end
    
    %--- path handling for scan number identification ---
    dirStruct = dir(studyDir);
    dirLen    = length(dirStruct);
    altCnt    = 0;                  % alternative .fid directory counter (init)
    altStruct = [];                 % init alternative fid (directory) structure

    %--- vendor-specific path handling ---
    switch flag.dataManu
        case 1                                                  % Varian
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat2FidFileTmp)),1);
            %--- assignment of experiment directory ---
            expDir = '';            % init / reset
            if SP2_CheckDirAccessR(SP2_SlashWinLin([studyDir num2str(expNum) '.fid\']))
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                expDir = SP2_SlashWinLin([studyDir num2str(expNum) '.fid\']);
            else
                % try to extract/deduce scan number and path from alternative
                % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        expDir = SP2_SlashWinLin([studyDir altStruct(altCnt).name '\']);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
            end
            if isempty(expDir)
                fprintf('%s ->\nNo valid directory found.\n',FCTNAME)
                set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                return
            end
            dat2FidFileTmp = [expDir 'fid'];
            % end of Varian
             
        case 2                                                      % Bruker
            if strcmp(data.spec2.fidFile(end-2:end),'fid')                  % old/new fid file
                %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
                for sCnt = 1:dirLen             % all elements in folder
                    if dirStruct(sCnt).isdir==1 && ~strcmp(dirStruct(sCnt).name,'.') && ~strcmp(dirStruct(sCnt).name,'..')       % is directory
                        if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir dirStruct(sCnt).name '/fid']),0)   % contains fid file
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

                %--- parameter file handling and consistency ---
                expNum = max(round(str2double(dat2FidFileTmp)),1);
                %--- assignment of experiment directory ---
                expDir = '';            % init / reset
                if SP2_CheckDirAccessR(SP2_SlashWinLin([studyDir num2str(expNum) '\']),flag.verbose)
                    % direct assignment of 1.fid, 2.fid, 3.fid, ...
                    expDir = SP2_SlashWinLin([studyDir num2str(expNum) '\']);
                else
                    % try to extract/deduce scan number and path from alternative
                    % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                    f_done = 0;     % init alternative path success flag
                    for altCnt = 1:altN
                        if expNum==altStruct(altCnt).number
                            expDir = SP2_SlashWinLin([studyDir altStruct(altCnt).name '\']);
                            if f_done       % check for multiple options
                                fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                                fprintf('scan number %i. Program aborted.\n',expNum)
                            else            % update success flag
                                f_done = 1;
                            end
                        end
                    end
                    %--- check if unique alternative was found ---
                    if ~f_done
                        fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                                FCTNAME,expNum)
                        set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                        return
                    end
                end
                if isempty(expDir)
                    fprintf('%s ->\nNo valid directory found.\n',FCTNAME)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
                dat2FidFileTmp = [expDir 'fid'];
            else                                % new rawdata.job0
                %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
                for sCnt = 1:dirLen             % all elements in folder
                    if dirStruct(sCnt).isdir==1 && ~strcmp(dirStruct(sCnt).name,'.') && ~strcmp(dirStruct(sCnt).name,'..')       % is directory
                        if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir dirStruct(sCnt).name '/rawdata.job0']),0)   % contains fid file
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

                %--- parameter file handling and consistency ---
                expNum = max(round(str2double(dat2FidFileTmp)),1);
                %--- assignment of experiment directory ---
                expDir = '';            % init / reset
                if SP2_CheckDirAccessR(SP2_SlashWinLin([studyDir num2str(expNum) '\']),flag.verbose)
                    % direct assignment of 1.fid, 2.fid, 3.fid, ...
                    expDir = SP2_SlashWinLin([studyDir num2str(expNum) '\']);
                else
                    % try to extract/deduce scan number and path from alternative
                    % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                    f_done = 0;     % init alternative path success flag
                    for altCnt = 1:altN
                        if expNum==altStruct(altCnt).number
                            expDir = SP2_SlashWinLin([studyDir altStruct(altCnt).name '\']);
                            if f_done       % check for multiple options
                                fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                                fprintf('scan number %i. Program aborted.\n',expNum)
                            else            % update success flag
                                f_done = 1;
                            end
                        end
                    end
                    %--- check if unique alternative was found ---
                    if ~f_done
                        fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                                FCTNAME,expNum)
                        set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                        return
                    end
                end
                if isempty(expDir)
                    fprintf('%s ->\nNo valid directory found.\n',FCTNAME)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
                dat2FidFileTmp = [expDir 'rawdata.job0'];
            end
            % end of Bruker
            
        case 3                                                      % GE
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if any(strfind(dirStruct(sCnt).name,'.7') & dirStruct(sCnt).isdir==0);    % all .fid directories
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat2FidFileTmp)),1);
            %--- assignment of experiment directory ---
            if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir num2str(expNum) '.7']),flag.verbose)
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat2FidFileTmp = SP2_SlashWinLin([studyDir num2str(expNum) '.7']);
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        dat2FidFileTmp = SP2_SlashWinLin([studyDir altStruct(altCnt).name]);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',dat2FidFileTmp)
                    return
                end
            end
            % end of GE
            
        case 4                                                      % Siemens
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if any(strfind(dirStruct(sCnt).name,'.rda') & dirStruct(sCnt).isdir==0);    % all .fid directories
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat2FidFileTmp)),1);
            %--- assignment of experiment directory ---
            if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir num2str(expNum) '.rda']),flag.verbose)
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat2FidFileTmp = SP2_SlashWinLin([studyDir num2str(expNum) '.rda']);
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        dat2FidFileTmp = SP2_SlashWinLin([studyDir altStruct(altCnt).name]);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
            end
            % end of Siemens
            
        case 5                                                      % DICOM
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat2FidFileTmp)),1);
            %--- assignment of experiment directory ---
            expDir = '';            % init / reset
            if SP2_CheckDirAccessR(SP2_SlashWinLin([studyDir num2str(expNum) '.fid\']),flag.verbose)
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                expDir = SP2_SlashWinLin([studyDir num2str(expNum) '.fid\']);
            else
                % try to extract/deduce scan number and path from alternative
                % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        expDir = SP2_SlashWinLin([studyDir altStruct(altCnt).name '\']);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
            end
            if isempty(expDir)
                fprintf('%s ->\nNo valid directory found.\n',FCTNAME)
                set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                return
            end
            dat2FidFileTmp = [expDir 'fid'];
            % end of DICOM
            
        case 6                                                      % Siemens .dat
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if any(strfind(dirStruct(sCnt).name,'.dat') & dirStruct(sCnt).isdir==0);    % all .fid directories
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat2FidFileTmp)),1);
            %--- assignment of experiment directory ---
            if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir num2str(expNum) '.dat']),flag.verbose)
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat2FidFileTmp = SP2_SlashWinLin([studyDir num2str(expNum) '.dat']);
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        dat2FidFileTmp = SP2_SlashWinLin([studyDir altStruct(altCnt).name]);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
            end
            % end of Siemens .dat
                        
        case 7                                                      % Philips .raw
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if any(strfind(dirStruct(sCnt).name,'.raw') & dirStruct(sCnt).isdir==0);    % all .fid directories
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat1FidFileTmp)),1);
            %--- assignment of experiment directory ---
            if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir num2str(expNum) '.raw']),flag.verbose)
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = SP2_SlashWinLin([studyDir num2str(expNum) '.raw']);
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        dat1FidFileTmp = SP2_SlashWinLin([studyDir altStruct(altCnt).name]);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
            end
            % end of Philips .raw        
            
        case 8                                                      % Philips .SDAT
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if any(strfind(dirStruct(sCnt).name,'.SDAT') & dirStruct(sCnt).isdir==0);    % all .fid directories
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat1FidFileTmp)),1);
            %--- assignment of experiment directory ---
            if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir num2str(expNum) '.SDAT']),flag.verbose)
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat1FidFileTmp = SP2_SlashWinLin([studyDir num2str(expNum) '.SDAT']);
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        dat1FidFileTmp = SP2_SlashWinLin([studyDir altStruct(altCnt).name]);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
            end
            % end of Philips .SDAT            

    case 9                                                      % DICOM (.IMA)
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if any(strfind(dirStruct(sCnt).name,'.IMA') & dirStruct(sCnt).isdir==0);    % all .fid directories
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

            %--- parameter file handling and consistency ---
            expNum = max(round(str2double(dat2FidFileTmp)),1);
            %--- assignment of experiment directory ---
            if SP2_CheckFileExistenceR(SP2_SlashWinLin([studyDir num2str(expNum) '.IMA']),flag.verbose)
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                dat2FidFileTmp = SP2_SlashWinLin([studyDir num2str(expNum) '.IMA']);
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if expNum==altStruct(altCnt).number
                        dat2FidFileTmp = SP2_SlashWinLin([studyDir altStruct(altCnt).name]);
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME)
                            fprintf('scan number %i. Program aborted.\n',expNum)
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,expNum)
                    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
                    return
                end
            end
            % end of DICOM (.IMA)
        
    end
else                                % full path assignment
    dat2FidFileTmp = SP2_SlashWinLin(dat2FidFileTmp);
    if isempty(dat2FidFileTmp)
        fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
        set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
        return
    end
    if ~strcmp(dat2FidFileTmp(end-2:end),'fid') && ~strcmp('.7',dat2FidFileTmp(end-1:end)) && ...
       ~strcmp('.rda',dat2FidFileTmp(end-3:end)) && ~strcmp('.dcm',dat2FidFileTmp(end-3:end)) && ...
       ~strcmp('.dat',dat2FidFileTmp(end-3:end)) && ~strcmp('rawdata.job0',dat2FidFileTmp(end-11:end)) && ...
       ~strcmp('.raw',dat2FidFileTmp(end-3:end)) && ~strcmp('.SDAT',dat2FidFileTmp(end-4:end)) && ...
       ~strcmp('.IMA',dat2FidFileTmp(end-3:end))
        fprintf('%s ->\nAssigned file does not have a valide format (<fid>, <rawdata.job0>, <.7>, <.dat>, <.rda>, <.dcm>), <.raw>, <.SDAT>, <.IMA>), try again...\n',FCTNAME)
        set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
        return
    end
end
if ~SP2_CheckFileExistenceR(dat2FidFileTmp)
    fprintf('%s ->\nAssigned file can''t be opened...\n',FCTNAME)
    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
    return
end
set(fm.data.spec2FidFile,'String',dat2FidFileTmp)
data.spec2.fidFile = get(fm.data.spec2FidFile,'String');
clear dat2FidFileTmp

%--- path handling ---
% if flag.OS
%     slashInd = find(data.spec2.fidFile=='/');
% else
%     slashInd = find(data.spec2.fidFile=='\');
% end
if flag.OS==1            % Linux
    slashInd = find(data.spec2.fidFile=='/');
elseif flag.OS==2        % Mac
    slashInd = find(data.spec2.fidFile=='/');
else                     % PC
    slashInd = find(data.spec2.fidFile=='\');
end
data.spec2.fidName = data.spec2.fidFile(slashInd(end)+1:end);
data.spec2.fidDir  = data.spec2.fidFile(1:slashInd(end));

%--- retrieve data format ---
if strcmp(data.spec2.fidDir(end-4:end-1),'.fid')                        % Varian
    fprintf('Data format: Varian\n')
    flag.dataManu = 1;        
    data.spec2.methFile = [data.spec2.fidDir 'procpar'];                % adopt procpar (/method) file path
    data.spec2.acqpFile = [data.spec2.fidDir 'text'];                   % adopt text (/acqp) file path
elseif strcmp(data.spec2.fidName,'fid') || strcmp(data.spec1.fidName,'rawdata.job0')  % Bruker
    fprintf('Data format: Bruker\n')
    flag.dataManu = 2;     
    data.spec2.methFile = [data.spec2.fidDir 'method'];                 % adopt method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'acqp'];                   % adopt acqp file path
elseif strcmp(data.spec2.fidFile(end-1:end),'.7')                       % GE
    fprintf('Data format: General Electric\n')
    flag.dataManu = 3;
    data.spec2.methFile = [data.spec2.fidDir 'geMeth'];                 % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'geAcq'];                  % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.rda')                     % Siemens
    fprintf('Data format: Siemens (.rda)\n')
    flag.dataManu = 4;
    data.spec2.methFile = [data.spec2.fidDir 'siemMeth'];               % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'siemAcq'];                % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.dcm')                     % DICOM
    fprintf('Data format: DICOM\n')
    flag.dataManu = 5;
    data.spec2.methFile = [data.spec2.fidDir 'dcmMeth'];                % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'dcmAcq'];                 % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.dat')                     % Siemens
    fprintf('Data format: Siemens (.dat)\n')
    flag.dataManu = 6;
    data.spec2.methFile = [data.spec2.fidDir 'siemMeth'];               % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'siemAcq'];                % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.raw')                     % Philips raw
    fprintf('Data format: Philips (.raw)\n')
    flag.dataManu = 7;
    data.spec2.methFile = [data.spec2.fidFile(1:end-4) '.sin'];         % method file path
    data.spec2.acqpFile = [data.spec2.fidFile(1:end-4) '.lab'];         % acqp file path
elseif strcmp(data.spec2.fidFile(end-4:end),'.SDAT')                    % Philips collapsed
    fprintf('Data format: Philips (.SDAT)\n')
    flag.dataManu = 8;
    data.spec2.methFile = [data.spec2.fidFile(1:end-5) '.SPAR'];        % method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'philAcq'];                % fake acqp file path
elseif strcmp(data.spec2.fidFile(end-3:end),'.IMA')                     % DICOM
    fprintf('Data format: DICOM (.IMA)\n')
    flag.dataManu = 9;
    data.spec2.methFile = [data.spec2.fidDir 'dcmMeth'];                % fake method file path
    data.spec2.acqpFile = [data.spec2.fidDir 'dcmAcq'];                 % fake acqp file path
else
    fprintf('%s ->\nData format not valid. File assignment aborted.\n',FCTNAME)
    return
end

%--- update flag display ---
SP2_Data_DataWinUpdate

%--- check pars file existence
% Varian OR Bruker OR Philips .raw OR Philips .sdat
if flag.dataManu==1 || flag.dataManu==2 || flag.dataManu==7 || flag.dataManu==8           
    if ~SP2_CheckFileExistence(data.spec2.methFile)
        return
    end
end
% Bruker OR Philips .raw
if flag.dataManu==2 || flag.dataManu==7           
    if ~SP2_CheckFileExistence(data.spec2.acqpFile)
        return
    end
end

%--- update success flag ---
f_succ = 1;




