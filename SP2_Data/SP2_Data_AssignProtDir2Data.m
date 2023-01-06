%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_AssignProtDir2Data
%% 
%%  Search data in protocol directory and reassing data paths for both data sets.
%%
%%  04-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag data


FCTNAME = 'SP2_Data_AssignProtDir2Data';


%--- init success flag ---
f_succ = 0;

%--- derive name of scan directory ---
if flag.OS==1            % Linux
    slashInd = find(data.spec1.fidDir=='/');
elseif flag.OS==2        % Mac
    slashInd = find(data.spec1.fidDir=='/');
else                     % PC
    slashInd = find(data.spec1.fidDir=='\');
end

%--- fid and method path creation ---
% note that the acqp file 'text' is not checked (since not essential), but
% also reassigned if the fid/procpar reassignment is done
dat1FidFileTmp  = [data.protDir data.spec1.fidFile(slashInd(end-1)+1:end)];
dat1MethFileTmp = [data.protDir data.spec1.methFile(slashInd(end-1)+1:end)];
dat2FidFileTmp  = [data.protDir data.spec2.fidFile(slashInd(end-1)+1:end)];
dat2MethFileTmp = [data.protDir data.spec2.methFile(slashInd(end-1)+1:end)];

%--- check file existence and reassign paths of data set 1 (if possible) ---
if SP2_CheckFileExistenceR(dat1FidFileTmp) && SP2_CheckFileExistenceR(dat1MethFileTmp)
    %--- derive name of scan directory ---
    if flag.OS==1            % Linux
        slashInd = find(data.spec1.fidDir=='/');
    elseif flag.OS==2        % Mac
        slashInd = find(data.spec1.fidDir=='/');
    else                        % PC
        slashInd = find(data.spec1.fidDir=='\');
    end
    
    if length(slashInd)<2
        fprintf('%s ->\nInvalid parent directory for data set 1. Program aborted.\n',FCTNAME);
        return
    end
    scanDirName = data.spec1.fidDir(slashInd(end-1)+1:slashInd(end));
    
    % path reassignment
    data.spec1.fidDir   = [data.protDir scanDirName];
    data.spec1.fidFile  = dat1FidFileTmp;
    data.spec1.methFile = dat1MethFileTmp;
    data.spec1.acqpFile = [data.protDir data.spec1.acqpFile(length(data.protDir)+1:end)];
    
    % window update    
    set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
    data.spec1.fidFile = get(fm.data.spec1FidFile,'String');
    
    % info printout 
    fprintf('%s ->\nPaths of data set 1 reassigned to SPX protocol directory.\n',FCTNAME);
else
    fprintf('%s ->\nNo equivalent data set 1 found in SPX protocol directory.\nPath reassignment of data set 1 not applied\n\n',FCTNAME);
end
clear dat1FidFileTmp dat1MethFileTmp

%--- check file existence and reassign paths of data set 2 (if possible) ---
if SP2_CheckFileExistenceR(dat2FidFileTmp) && SP2_CheckFileExistenceR(dat2MethFileTmp)
    %--- derive name of scan directory ---
    if flag.OS==1            % Linux
        slashInd = find(data.spec2.fidDir=='/');
    elseif flag.OS==2        % Mac
        slashInd = find(data.spec2.fidDir=='/');
    else                     % PC
        slashInd = find(data.spec2.fidDir=='\');
    end
    
    if length(slashInd)<2
        fprintf('%s ->\nInvalid parent directory for data set 2. Program aborted.\n',FCTNAME);
        return
    end
    scanDirName = data.spec2.fidDir(slashInd(end-1)+1:slashInd(end));
    
    % path reassignment
    data.spec2.fidDir   = [data.protDir scanDirName];
    data.spec2.fidFile  = dat2FidFileTmp;
    data.spec2.methFile = dat2MethFileTmp;
    data.spec2.acqpFile = [data.protDir data.spec2.acqpFile(length(data.protDir)+1:end)];
    
    % window update    
    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
    data.spec2.fidFile = get(fm.data.spec2FidFile,'String');
    
    % info printout 
    fprintf('%s ->\nPaths of data set 2 reassigned to SPX protocol directory.\n',FCTNAME);
else
    fprintf('%s ->\nNo equivalent data set 2 found in SPX protocol directory.\nPath reassignment of data set 2 not applied\n\n',FCTNAME);
end
clear dat2FidFileTmp dat2MethFileTmp

%--- (pro forma) retrieval of data format ---
if isempty(findstr(data.spec1.fidDir,'.fid'))                   % Bruker
    flag.dataManu = 0;     
    data.spec1.methFile = [data.spec1.fidDir 'method'];         % adopt method file path
    data.spec1.acqpFile = [data.spec1.fidDir 'acqp'];           % adopt acqp file path
else                                                            % Varian
    flag.dataManu = 1;        
    data.spec1.methFile = [data.spec1.fidDir 'procpar'];        % adopt procpar (/method) file path
    data.spec1.acqpFile = [data.spec1.fidDir 'text'];           % adopt text (/acqp) file path
end

%--- update flag display ---
SP2_Data_DataWinUpdate

%--- check pars file existence
SP2_CheckFileExistence(data.spec1.methFile)
SP2_CheckFileExistence(data.spec2.methFile)

%--- update success flag ---
f_succ = 1;

end
