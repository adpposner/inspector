%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1SeriesLoad
%% 
%%  Load experiment series.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data procpar fm

FCTNAME = 'SP2_Data_Dat1SeriesLoad';


%--- init success flag ---
f_succ = 0;
flag.dataCorrAppl = 0;

%--- confirm data format ---
if strcmp(data.spec1.fidDir(end-4:end-1),'.fid')                % Varian
    fprintf('Data format: Varian\n');
    flag.dataManu = 1;        
elseif strcmp(data.spec1.fidFile(end-2:end),'fid') || strcmp(data.spec1.fidName,'rawdata.job0')                         % Bruker
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
elseif strcmp(data.spec1.fidFile(end-3:end),'.dat')             % Siemens
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

%--- vendor-specfic path handling and data loading ---
switch flag.dataManu                                            
    case 1                                                      % Varian
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

        %--- info printout ---
        fprintf('\nFile and parameter consistency check ...\n');
        
        %--- parameter file handling and consistency ---
        seriesDirs = {};
        for expCnt = 1:data.spec1.seriesN
    
            %--- assignment of experiment directory ---
            if SP2_CheckDirAccessR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.fid\'])
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesDirs{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.fid\'];
            else
                % try to extract/deduce scan number and path from alternative
                % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesDirs{expCnt} = [studyDir altStruct(altCnt).name '\'];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\n\n\nNo scan could be attributed to number %i. Program aborted\n\n\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end

            %--- parameter handling ---
            if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'procpar'])
                return
            end
            if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'fid'])
                return
            end
            if expCnt==1
                [procpar,f_read] = SP2_Data_VnmrReadProcpar([seriesDirs{expCnt} 'procpar'],1);
                if ~f_read
                    return
                end
                [procpar.dHeader,procpar.bHeader,f_read] = SP2_Data_VnmrReadHeaders([seriesDirs{expCnt} 'fid']);
                if ~f_read
                    return
                end
            else
                [procparTmp,f_read] = SP2_Data_VnmrReadProcpar([seriesDirs{expCnt} 'procpar'],1);
                if ~f_read
                    return
                end
                [procparTmp.dHeader,procparTmp.bHeader,f_read] = SP2_Data_VnmrReadHeaders([seriesDirs{expCnt} 'fid']);
                if ~f_read
                    return
                end
            end

            %--- parameter consistency checks --- 
            if expCnt~=1
                %--- init accept all option ---
                if expCnt==2
                    f_yesAll = 0;         % default: not selected, i.e. individual checks
                end

                %--- acqp parameter consistency checks ---
                [f_err,msg] = SP2_Data_ProcparConsistency(procpar,procparTmp);
                if f_err && ~f_yesAll
                    msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                    button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                    if strcmp(button,'No')
                        fprintf('\n%s aborted.\n',FCTNAME);
                        return       % terminate program execution
                    elseif strcmp(button,'Yes (All)')
                        f_yesAll = 1;       % disable subsequent checks
                    end
                end    
            end
        end
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        data.spec1.fidFile  = [seriesDirs{expCnt} 'fid'];           % current fid file
        data.spec1.methFile = [seriesDirs{expCnt} 'procpar'];       % current procpar file
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
        end
        % end of Varian
        
    case 2                                                      % Bruker
        if flag.dataBrukerFormat==3                         % new <rawdata.job0> format
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
            for sCnt = 1:dirLen             % all elements in folder
                if dirStruct(sCnt).isdir==1 && ~strcmp(dirStruct(sCnt).name,'.') && ~strcmp(dirStruct(sCnt).name,'..')      % is directory
                    if SP2_CheckFileExistenceR([studyDir dirStruct(sCnt).name '/rawdata.job0']),0           % contains rawdata.job0 file
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

            %--- info printout ---
            fprintf('\nFile and parameter consistency check ...\n');

            %--- parameter file handling and consistency ---
            seriesDirs = {};
            for expCnt = 1:data.spec1.seriesN

                %--- assignment of experiment directory ---
                if SP2_CheckDirAccessR([studyDir num2str(data.spec1.seriesVec(expCnt)) '\'])
                    % direct assignment of 1.fid, 2.fid, 3.fid, ...
                    seriesDirs{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '\'];
                else
                    % try to extract/deduce scan number and path from alternative
                    % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                    f_done = 0;     % init alternative path success flag
                    for altCnt = 1:altN
                        if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                            seriesDirs{expCnt} = [studyDir altStruct(altCnt).name '\'];
                            if f_done       % check for multiple options
                                fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                                fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                            else            % update success flag
                                f_done = 1;
                            end
                        end
                    end
                    %--- check if unique alternative was found ---
                    if ~f_done
                        fprintf('%s ->\n\n\nNo scan could be attributed to number %i. Program aborted\n\n\n',...
                                FCTNAME,data.spec1.seriesVec(expCnt))
                        return
                    end
                end

                %--- parameter handling ---
                if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'method'])
                    return
                end
                if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'acqp'])
                    return
                end
                if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'rawdata.job0'])
                    return
                end
                if expCnt==1
                    %--- read acqp/method parameter files ---
                    [acqp,f_done] = SP2_Data_PvReadAcqp([seriesDirs{expCnt} 'acqp']);
                    if ~f_done
                        fprintf('%s -> Reading <acqp> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'acqp']);
                        return
                    end
                    [method,f_done] = SP2_Data_PvReadMethod([seriesDirs{expCnt} 'method']);
                    if ~f_done
                        fprintf('%s -> Reading <method> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'method']);
                        return
                    end
                else
                    %--- read acqp/method parameter files ---
                    [acqpTmp,f_done] = SP2_Data_PvReadAcqp([seriesDirs{expCnt} 'acqp']);
                    if ~f_done
                        fprintf('%s -> Reading <acqp> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'acqp']);
                        return
                    end
                    [methodTmp,f_done] = SP2_Data_PvReadMethod([seriesDirs{expCnt} 'method']);
                    if ~f_done
                        fprintf('%s -> Reading <method> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'method']);
                        return
                    end
                end

                %--- parameter consistency checks --- 
                if expCnt~=1
                    %--- init accept all option ---
                    if expCnt==2
                        f_yesAll = 0;         % default: not selected, i.e. individual checks
                    end
                    
                    %--- acqp parameter consistency checks ---
                    [f_err,msg] = SP2_Data_PvMethodConsistency(method,methodTmp);
                    if f_err && ~f_yesAll
                        msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                        button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                        if strcmp(button,'No')
                            fprintf('\n%s aborted\n',FCTNAME);
                            return       % terminate program execution
                        elseif strcmp(button,'Yes (All)')
                            f_yesAll = 1;       % disable subsequent checks
                        end
                    end    
                    %--- acqp parameter consistency checks ---
                    [f_err,msg] = SP2_Data_PvAcqpConsistency(acqp,acqpTmp);
                    if f_err && ~f_yesAll
                        msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                        button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                        if strcmp(button,'No')
                            fprintf('\n%s aborted\n',FCTNAME);
                            return       % terminate program execution
                        elseif strcmp(button,'Yes (All)')
                            f_yesAll = 1;       % disable subsequent checks
                        end
                    end    
                end
            end

            %--- keep original spec1 experiment paths ---
            dataSpec1MethFile = data.spec1.methFile;
            dataSpec1FidFile  = data.spec1.fidFile;

            %--- load 1st data set for format checks ---
            data.spec1.fidFile  = [seriesDirs{expCnt} 'rawdata.job0'];           % current fid file
            data.spec1.methFile = [seriesDirs{expCnt} 'method'];        % current method file
        else                                                % old/new <fid> file
            %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
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

            %--- info printout ---
            fprintf('\nFile and parameter consistency check ...\n');

            %--- parameter file handling and consistency ---
            seriesDirs = {};
            for expCnt = 1:data.spec1.seriesN;

                %--- assignment of experiment directory ---
                if SP2_CheckDirAccessR([studyDir num2str(data.spec1.seriesVec(expCnt)) '\'])
                    % direct assignment of 1.fid, 2.fid, 3.fid, ...
                    seriesDirs{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '\'];
                else
                    % try to extract/deduce scan number and path from alternative
                    % directory structure (like 005_matXXX_fovXXX_dateXXX.fid)
                    f_done = 0;     % init alternative path success flag
                    for altCnt = 1:altN
                        if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                            seriesDirs{expCnt} = [studyDir altStruct(altCnt).name '\'];
                            if f_done       % check for multiple options
                                fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                                fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                            else            % update success flag
                                f_done = 1;
                            end
                        end
                    end
                    %--- check if unique alternative was found ---
                    if ~f_done
                        fprintf('%s ->\n\n\nNo scan could be attributed to number %i. Program aborted\n\n\n',...
                                FCTNAME,data.spec1.seriesVec(expCnt))
                        return
                    end
                end

                %--- parameter handling ---
                if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'method'])
                    return
                end
                if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'acqp'])
                    return
                end
                if ~SP2_CheckFileExistenceR([seriesDirs{expCnt} 'fid'])
                    return
                end
                if expCnt==1
                    %--- read acqp/method parameter files ---
                    [acqp,f_done] = SP2_Data_PvReadAcqp([seriesDirs{expCnt} 'acqp']);
                    if ~f_done
                        fprintf('%s -> Reading <acqp> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'acqp']);
                        return
                    end
                    [method,f_done] = SP2_Data_PvReadMethod([seriesDirs{expCnt} 'method']);
                    if ~f_done
                        fprintf('%s -> Reading <method> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'method']);
                        return
                    end
                else
                    %--- read acqp/method parameter files ---
                    [acqpTmp,f_done] = SP2_Data_PvReadAcqp([seriesDirs{expCnt} 'acqp']);
                    if ~f_done
                        fprintf('%s -> Reading <acqp> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'acqp']);
                        return
                    end
                    [methodTmp,f_done] = SP2_Data_PvReadMethod([seriesDirs{expCnt} 'method']);
                    if ~f_done
                        fprintf('%s -> Reading <method> file failed:\n<%s>\n',FCTNAME,[seriesDirs{expCnt} 'method']);
                        return
                    end
                end

                %--- parameter consistency checks --- 
                if expCnt~=1
                    %--- init accept all option ---
                    if expCnt==2
                        f_yesAll = 0;         % default: not selected, i.e. individual checks
                    end
                    
                    %--- acqp parameter consistency checks ---
                    [f_err,msg] = SP2_Data_PvMethodConsistency(method,methodTmp);
                    if f_err && ~f_yesAll
                        msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                        button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                        if strcmp(button,'No')
                            fprintf('\n%s aborted.\n',FCTNAME);
                            return       % terminate program execution
                        elseif strcmp(button,'Yes (All)')
                            f_yesAll = 1;       % disable subsequent checks
                        end
                    end    
                    %--- acqp parameter consistency checks ---
                    [f_err,msg] = SP2_Data_PvAcqpConsistency(acqp,acqpTmp);
                    if f_err && ~f_yesAll
                        msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                        button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                        if strcmp(button,'No')
                            fprintf('\n%s aborted.\n',FCTNAME);
                            return       % terminate program execution
                        elseif strcmp(button,'Yes (All)')
                            f_yesAll = 1;       % disable subsequent checks
                        end
                    end    
                end
            end

            %--- keep original spec1 experiment paths ---
            dataSpec1MethFile = data.spec1.methFile;
            dataSpec1FidFile  = data.spec1.fidFile;

            %--- load 1st data set for format checks ---
            data.spec1.fidFile  = [seriesDirs{expCnt} 'fid'];           % current fid file
            data.spec1.methFile = [seriesDirs{expCnt} 'method'];        % current method file
        end
        
        %--- test read and init ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
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
        
        %--- info printout ---
        fprintf('\nFile and parameter consistency check ...\n');
        
        %--- parameter file handling and consistency ---
        seriesFiles = {};
        for expCnt = 1:data.spec1.seriesN;
            
            if SP2_CheckFileExistenceR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.7']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesFiles{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.7'];
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesFiles{expCnt} = [studyDir altStruct(altCnt).name];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end            

            %--- parameter handling ---
            if expCnt==1
                [header,f_read] = SP2_Data_GEReadHeader(seriesFiles{expCnt});
                if ~f_read
                    return
                end
            else
                [headerTmp,f_read] = SP2_Data_GEReadHeader(seriesFiles{expCnt});
                if ~f_read
                    return
                end
            end
            
            %--- parameter consistency checks --- 
            if expCnt~=1
                %--- init accept all option ---
                if expCnt==2
                    f_yesAll = 0;         % default: not selected, i.e. individual checks
                end
                
                %--- acqp parameter consistency checks ---
                [f_err,msg] = SP2_Data_GEParsConsistency(header,headerTmp);
                if f_err && ~f_yesAll
                    msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                    button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                    if strcmp(button,'No')
                        fprintf('\n%s aborted.\n',FCTNAME);
                        return              % terminate program execution
                    elseif strcmp(button,'Yes (All)')
                        f_yesAll = 1;       % disable subsequent checks
                    end
                end    
            end
        end
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
        end
        % end of GE
        
    case 4                                                      % Siemens .rda
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
        
        %--- info printout ---
        fprintf('\nFile and parameter consistency check ...\n');
        
        %--- parameter file handling and consistency ---
        seriesFiles = {};
        for expCnt = 1:data.spec1.seriesN
            
            if SP2_CheckFileExistenceR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.rda']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesFiles{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.rda'];
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesFiles{expCnt} = [studyDir altStruct(altCnt).name];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end            

            %--- parameter handling ---
            if expCnt==1
                %--- read header from file ---
                [procpar,f_done] = SP2_Data_SiemensRdaReadHeader(seriesFiles{expCnt});
                if ~f_done
                    fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                            FCTNAME,seriesFiles{expCnt})
                    return
                end
            else
                %--- read header from file ---
                [procparTmp,f_done] = SP2_Data_SiemensRdaReadHeader(seriesFiles{expCnt});
                if ~f_done
                    fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                            FCTNAME,seriesFiles{expCnt})
                    return
                end
            end

            %--- parameter consistency checks --- 
            if expCnt~=1
                %--- init accept all option ---
                if expCnt==2
                    f_yesAll = 0;         % default: not selected, i.e. individual checks
                end
                
                %--- acqp parameter consistency checks ---
                [f_err,msg] = SP2_Data_SiemensRdaParsConsistency(procpar,procparTmp);
                if f_err && ~f_yesAll
                    msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                    button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                    if strcmp(button,'No')
                        fprintf('\n%s aborted.\n',FCTNAME);
                        return       % terminate program execution
                    elseif strcmp(button,'Yes (All)')
                        f_yesAll = 1;       % disable subsequent checks
                    end
                end    
            end
        end
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
        end
        % end of Siemens .rda
        
    case 5                                                      % DICOM (.dcm)
        
        %--- extract alternative scan directories (like 005_fovXXX_matXXX_dateXXX.fid) ---
        for sCnt = 1:dirLen             % all elements in folder
            if any(strfind(dirStruct(sCnt).name,'.dcm') & dirStruct(sCnt).isdir==0);    % all .fid directories
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
        
        %--- info printout ---
        fprintf('\nFile and parameter consistency check ...\n');
        
        %--- parameter file handling and consistency ---
        seriesFiles = {};
        for expCnt = 1:data.spec1.seriesN
            
            if SP2_CheckFileExistenceR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.dcm']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesFiles{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.dcm'];
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesFiles{expCnt} = [studyDir altStruct(altCnt).name];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end            

            %--- parameter handling ---
            if expCnt==1
                %--- read header from file ---
                [procpar,f_done] = SP2_Data_SiemensDatReadHeader(seriesFiles{expCnt});
                if ~f_done
                    fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                            FCTNAME,seriesFiles{expCnt})
                    return
                end
            else
                %--- read header from file ---
                [procparTmp,f_done] = SP2_Data_SiemensDatReadHeader(seriesFiles{expCnt});
                if ~f_done
                    fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                            FCTNAME,seriesFiles{expCnt})
                    return
                end
            end

            %--- parameter consistency checks --- 
            if expCnt~=1
                %--- init accept all option ---
                if expCnt==2
                    f_yesAll = 0;         % default: not selected, i.e. individual checks
                end

                %--- acqp parameter consistency checks ---
                [f_err,msg] = SP2_Data_SiemensDatParsConsistency(procpar,procparTmp);
                if f_err && ~f_yesAll
                    msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                    button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                    if strcmp(button,'No')
                        fprintf('\n%s aborted.\n',FCTNAME);
                        return              % terminate program execution
                    elseif strcmp(button,'Yes (All)')
                        f_yesAll = 1;       % disable subsequent checks
                    end
                end    
            end
        end
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
        end
        % end of DICOM .dcm

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

        %--- info printout ---
        if flag.verbose        
            fprintf('\nFile and parameter consistency check ...\n');
        else
            fprintf('\nFile consistency check ...\n');
            fprintf('For parameter consistency check select ''Verbose'' flag and reload.\n');
        end
        
        %--- parameter file handling and consistency ---
        seriesFiles = {};
        for expCnt = 1:data.spec1.seriesN

            if SP2_CheckFileExistenceR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.dat']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesFiles{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.dat'];
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesFiles{expCnt} = [studyDir altStruct(altCnt).name];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end            

            % perform (lengthy) consistency checks only if requested
            if flag.verbose
                %--- parameter handling ---
                if expCnt==1
                    %--- read header from file ---
                    [procpar,f_done] = SP2_Data_SiemensDatReadHeader(seriesFiles{expCnt});
                    if ~f_done
                        fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                                FCTNAME,seriesFiles{expCnt})
                        return
                    end
                else
                    %--- read header from file ---
                    [procparTmp,f_done] = SP2_Data_SiemensDatReadHeader(seriesFiles{expCnt});
                    if ~f_done
                        fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                                FCTNAME,seriesFiles{expCnt})
                        return
                    end
                end

                %--- parameter consistency checks --- 
                if expCnt~=1
                    %--- init accept all option ---
                    if expCnt==2
                        f_yesAll = 0;         % default: not selected, i.e. individual checks
                    end

                    %--- acqp parameter consistency checks ---
                    [f_err,msg] = SP2_Data_SiemensDatParsConsistency(procpar,procparTmp);
                    if f_err && ~f_yesAll
                        msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                        button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                        if strcmp(button,'No')
                            fprintf('\n%s aborted.\n',FCTNAME);
                            return              % terminate program execution
                        elseif strcmp(button,'Yes (All)')
                            f_yesAll = 1;       % disable subsequent checks
                        end
                    end    
                end
            end                 % end of verbose flag
        end                     % end of file series
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
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
        
        %--- info printout ---
        fprintf('\nFile and parameter consistency check ...\n');
        
        %--- parameter file handling and consistency ---
        seriesFiles = {};
        for expCnt = 1:data.spec1.seriesN
            
            if SP2_CheckFileExistenceR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.raw']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesFiles{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.raw'];
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesFiles{expCnt} = [studyDir altStruct(altCnt).name];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end            

            %--- parameter handling ---
            if ~SP2_CheckFileExistenceR([seriesFiles{1}(1:end-4) '.sin'])
                return
            end
            if expCnt==1
                [procpar,f_read] = SP2_Data_PhilipsRawReadSinLabFiles([seriesFiles{1}(1:end-4) '.sin'],[seriesFiles{1}(1:end-4) '.lab']);
                if ~f_read
                    return
                end
            else
                [procparTmp,f_read] = SP2_Data_PhilipsRawReadSinLabFiles([seriesFiles{1}(1:end-4) '.sin'],[seriesFiles{1}(1:end-4) '.lab']);
                if ~f_read
                    return
                end
            end

            %--- parameter consistency checks --- 
            if expCnt~=1
                %--- init accept all option ---
                if expCnt==2
                    f_yesAll = 0;         % default: not selected, i.e. individual checks
                end

                %--- acqp parameter consistency checks ---
                [f_err,msg] = SP2_Data_PhilipsRawParsConsistency(procpar,procparTmp);
                if f_err && ~f_yesAll
                    msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                    button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                    if strcmp(button,'No')
                        fprintf('\n%s aborted.\n',FCTNAME);
                        return       % terminate program execution
                    elseif strcmp(button,'Yes (All)')
                        f_yesAll = 1;       % disable subsequent checks
                    end
                end    
            end
        end
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
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
        
        %--- info printout ---
        fprintf('\nFile and parameter consistency check ...\n');
        
        %--- parameter file handling and consistency ---
        seriesFiles = {};
        for expCnt = 1:data.spec1.seriesN
            
            if SP2_CheckFileExistenceR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.SDAT']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesFiles{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.SDAT'];
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesFiles{expCnt} = [studyDir altStruct(altCnt).name];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end            
            
            %--- parameter handling ---
            if ~SP2_CheckFileExistenceR([seriesFiles{1}(1:end-4) '.sin'])
                return
            end
            if ~SP2_CheckFileExistenceR([seriesFiles{1}(1:end-4) '.lab'])
                return
            end
            if expCnt==1
                [procpar,f_read] = SP2_Data_PhilipsSdatReadSparFile([seriesFiles{1}(1:end-5) '.SPAR']);
                if ~f_read
                    return
                end
            else
                [procparTmp,f_read] = SP2_Data_PhilipsSdatReadSparFile([seriesFiles{1}(1:end-5) '.SPAR']);
                if ~f_read
                    return
                end
            end

            %--- parameter consistency checks --- 
            if expCnt~=1
                %--- init accept all option ---
                if expCnt==2
                    f_yesAll = 0;         % default: not selected, i.e. individual checks
                end

                %--- acqp parameter consistency checks ---
                [f_err,msg] = SP2_Data_PhilipsSdatParsConsistency(procpar,procparTmp);
                if f_err && ~f_yesAll
                    msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                    button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                    if strcmp(button,'No')
                        fprintf('\n%s aborted.\n',FCTNAME);
                        return              % terminate program execution
                    elseif strcmp(button,'Yes (All)')
                        f_yesAll = 1;       % disable subsequent checks
                    end
                end    
            end
        end
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
        end
        % end of Philips .SDAT
        
    case 9                                                      % DICOM .IMA
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
        
        %--- info printout ---
        fprintf('\nFile and parameter consistency check ...\n');
        
        %--- parameter file handling and consistency ---
        seriesFiles = {};
        for expCnt = 1:data.spec1.seriesN
            
            if SP2_CheckFileExistenceR([studyDir num2str(data.spec1.seriesVec(expCnt)) '.IMA']),flag.verbose
                % direct assignment of 1.fid, 2.fid, 3.fid, ...
                seriesFiles{expCnt} = [studyDir num2str(data.spec1.seriesVec(expCnt)) '.IMA'];
            else
                % try to extract/deduce scan number and path from alternative
                % file structure (like 005_matXXX_fovXXX_dateXXX.fid)
                f_done = 0;     % init alternative path success flag
                for altCnt = 1:altN
                    if data.spec1.seriesVec(expCnt)==altStruct(altCnt).number
                        seriesFiles{expCnt} = [studyDir altStruct(altCnt).name];
                        if f_done       % check for multiple options
                            fprintf('%s ->\nNo direct scan, but multiple alternatives were found for\n',FCTNAME);
                            fprintf('scan number %i. Program aborted.\n',data.spec1.seriesVec(expCnt));
                        else            % update success flag
                            f_done = 1;
                        end
                    end
                end
                %--- check if unique alternative was found ---
                if ~f_done
                    fprintf('%s ->\nNo scan could be attributed to number %i. Program aborted\n',...
                            FCTNAME,data.spec1.seriesVec(expCnt))
                    return
                end
            end            

            %--- parameter handling ---
            if expCnt==1
                %--- read header from file ---
                [procpar,f_done] = SP2_Data_SiemensDatReadHeader(seriesFiles{expCnt});
                if ~f_done
                    fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                            FCTNAME,seriesFiles{expCnt})
                    return
                end
            else
                %--- read header from file ---
                [procparTmp,f_done] = SP2_Data_SiemensDatReadHeader(seriesFiles{expCnt});
                if ~f_done
                    fprintf('%s ->\nReading Siemens header from file failed for:\n%s\nProgram aborted.\n',...
                            FCTNAME,seriesFiles{expCnt})
                    return
                end
            end

            %--- parameter consistency checks --- 
            if expCnt~=1
                %--- init accept all option ---
                if expCnt==2
                    f_yesAll = 0;         % default: not selected, i.e. individual checks
                end

                %--- acqp parameter consistency checks ---
                [f_err,msg] = SP2_Data_SiemensDatParsConsistency(procpar,procparTmp);
                if f_err && ~f_yesAll
                    msgAndQuest = sprintf('%s\nContinue program execution?\n',msg);
                    button = questdlg(msgAndQuest,'Inconsistency Dialog','Yes','Yes (All)','No','No');
                    if strcmp(button,'No')
                        fprintf('\n%s aborted.\n',FCTNAME);
                        return              % terminate program execution
                    elseif strcmp(button,'Yes (All)')
                        f_yesAll = 1;       % disable subsequent checks
                    end
                end    
            end
        end
        
        %--- keep original spec1 experiment paths ---
        dataSpec1MethFile = data.spec1.methFile;
        dataSpec1FidFile  = data.spec1.fidFile;

        %--- load 1st data set for format checks ---
        if ~SP2_Data_Dat1FidFileLoad(1,0)
            return
        end
        % end of DICOM .IMA

end
        
%--- consistency check and parameter init ---
switch flag.dataExpType
    case 1          % single spectrum
        if length(size(data.spec1.fid))~=2 && length(size(data.spec1.fid))~=3
            fprintf('%s ->\nData format incompatibility detected.\nIs the experiment type correct?!\n',FCTNAME);
            return
        end
        
        if length(size(data.spec1.fid))==2 && any(size(data.spec1.fid)==1)      % only 1 non-singleton dimension (i.e. nspecC)
            data.spec1.fidArr = complex(zeros(data.spec1.seriesN,data.spec1.nspecC));
        elseif length(size(data.spec1.fid))==2 && data.spec1.nRcvrs>1
            data.spec1.fidArr = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs));
        else
            data.spec1.fidArr = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs,data.spec1.nr));
        end
    case 2          % saturation-recovery
        if length(size(data.spec1.fid))~=3 && length(size(data.spec1.fid))~=4
            fprintf('%s / Saturation-recovery:\nData format incompatibility detected.\nIs the experiment type correct?!\n',FCTNAME);
            return
        end
        if length(size(data.spec1.fid))==3
            data.spec1.fidArr = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs));
        else        % length=4
            data.spec1.fidArr = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs,data.spec1.nv,data.spec1.nSatRec));
        end
    case 3          % JDE experiment
        if data.spec1.njde>0
            data.spec1.fidArr = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs,2*data.spec1.nr/data.spec1.njde));
        else
            fprintf('\n%s ->\nnjde is undefined. Make sure that this is indeed a JDE experiment.\nProgram aborted.\n',FCTNAME);
        end
    case 4          % stability mode
        fprintf('\n%s ->\nData series are not supported in Stability (QA) mode.\nProgram aborted.\n',FCTNAME);
        fprintf('(Are you sure you did not mean to load a single experiment?)\n');
        return
    case 5          % T1 / T2 
        fprintf('%s ->\nT1 / T2 mode is not supported by this application.\nProgram aborted.\n',FCTNAME);
        return
    case 6          % MRSI
        fprintf('%s ->\nMRSI is not supported by this application.\nProgram aborted.\n',FCTNAME);
        return
    case 7          % JDE - array
        % data handling
        data.spec1.fidArr = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs,2*data.spec1.nr/data.spec1.njde));
        
        % info printout
        fprintf('\nExtra TE delays:\n%s s\n\n',SP2_Vec2PrintStr(data.spec1.t2TeExtra,3));
    otherwise
        fprintf('%s ->\nInvalid value for <flag.dataExpType>.\nProgram aborted.\n',FCTNAME);
        return
end

%--- serial data loading ---
for expCnt = 1:data.spec1.seriesN
    %--- data file assignment ---
    switch flag.dataManu
        case 1                                                      % Varian
            data.spec1.fidFile  = [seriesDirs{expCnt} 'fid'];       % current fid file
            data.spec1.methFile = [seriesDirs{expCnt} 'procpar'];   % current procpar file
        case 2                                                      % Bruker
            if flag.dataBrukerFormat==3                             % new <rawdata.job0> format
                data.spec1.fidFile  = [seriesDirs{expCnt} 'rawdata.job0'];       % current rawdata.job0 file
            else                                                    % old/new <fid> file
                data.spec1.fidFile  = [seriesDirs{expCnt} 'fid'];   % current fid file
            end
            data.spec1.methFile = [seriesDirs{expCnt} 'method'];    % current procpar file
        case 3                                                      % GE, p-file
            data.spec1.fidFile  = seriesFiles{expCnt};           
        case 4                                                      % Siemens, .rda
            data.spec1.fidFile  = seriesFiles{expCnt};           
        case 5                                                      % DICOM
            data.spec1.fidFile  = seriesFiles{expCnt};           
        case 6                                                      % Siemens, .dat
            data.spec1.fidFile  = seriesFiles{expCnt};           
        case 7                                                      % Philips, .raw
            data.spec1.fidFile  = seriesFiles{expCnt};           
        case 8                                                      % Philips, .SDAT
            data.spec1.fidFile  = seriesFiles{expCnt};           
        case 9                                                      % DICOM (Siemens), .IMA
            data.spec1.fidFile  = seriesFiles{expCnt};           
    end

    %--- info printout ---
    fprintf('\nLoading file %.0f (of %.0f):\n%s\n',expCnt,data.spec1.seriesN,...
            data.spec1.fidFile)
        
    %--- file handling ---
    if ~SP2_Data_Dat1FidFileLoad(1,0)
        return
    end
    
    %--- spectra assignment ---
    if flag.dataExpType==1          % single spectrum
        if length(size(data.spec1.fid))==2 && any(size(data.spec1.fid)==1)      % only 1 non-singleton dimension (i.e. nspecC)
            data.spec1.fidArr(expCnt,:)     = data.spec1.fid;
        elseif length(size(data.spec1.fid))==2                                  % 2 non-singleton dimensions
            data.spec1.fidArr(expCnt,:,:)   = data.spec1.fid;
        else
            data.spec1.fidArr(expCnt,:,:,:) = data.spec1.fid;
        end
    elseif flag.dataExpType==2      % saturation-recovery series
        if length(size(data.spec1.fid))==3
            data.spec1.fidArr(expCnt,:,:,:)   = data.spec1.fid;
        else
            data.spec1.fidArr(expCnt,:,:,:,:) = data.spec1.fid;
        end
    else                            % JDE; simple (flag=3) or array (flag=7)
        if length(size(data.spec1.fid))~=3
            fprintf('%s ->\nData format incompatibility detected.\nIs the experiment type correct?!\n',FCTNAME);
            return
        end
        data.spec1.fidArr(expCnt,:,:,:) = data.spec1.fid;
    end
end

%--- restore origina spec1 experiment paths ---
data.spec1.methFile = dataSpec1MethFile;
data.spec1.fidFile  = dataSpec1FidFile;

%--- reset .nr for single edit condition of multi-edit experiment ---
% if flag.dataExpType== 1          % single spectrum
%     if length(size(data.spec1.fid))==2 && any(size(data.spec1.fid)==1)      % only 1 non-singleton dimension (i.e. nspecC)
%         data.spec1.nr = data.spec1.seriesN;
%         % i.e. data.spec1.nr = data.spec1.nr (=1) * data.spec1.seriesN
%     end
% end
if flag.dataExpType==3          % JDE experiment
    if data.spec1.njde>2
        fprintf('Total nr adopted from %.0f to %.0f\n',data.spec1.nr,2*data.spec1.nr/data.spec1.njde);
        data.spec1.nr = 2*data.spec1.nr/data.spec1.njde;
        
        %--- window update ---                           
        SP2_Data_DataWinUpdate
    end
end

%--- remove (old) Rx combination ---
if isfield(data.spec1,'fidArrRxComb')
    data.spec1 = rmfield(data.spec1,'fidArrRxComb');
end

%--- info printout ---
fprintf('\n%s done.\n',FCTNAME);
    
%--- update success flag ---
f_succ = 1;

