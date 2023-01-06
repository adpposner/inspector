%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AssignProtRel2Data
%% 
%%  Reassign paths of both data sets to maintain directory structure relative to protocol file.
%%  Note that the data is assumed to be in the protocol directory or below.
%%
%%  04-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag data


FCTNAME = 'SP2_Data_AssignProtRel2Data';

%--- info ---
% dataProtDirOld is the previous protocol diretory used to derive the
% file location relative to the data file location
% data.spec1/2.fidFile is the current data file location. This one is
% adopted according to the previous, relative file structure (in order to 
% maintain it.

%--- keep previous protocol information ---
dataProtFileOld     = data.protFile;                % protocol containing all FMAP parameters
dataProtDirOld      = data.protDir;                 % protocol directory, a study
dataProtPathOld     = data.protPath;                % protocol path (.mat)
dataProtPathMatOld  = data.protPathMat;             % protocol path for text export/output (.txt)
dataProtPathTxtOld  = data.protPathTxt;             % protocol path for text export/output (.txt)

%--- load current protocol ---
if ~SP2_Data_ProtocolLoad
    return
end

%--- determine relative directory structure ---
if flag.OS>0            % 1: Linux, 2: Mac
    slashProtInd = find(data.protDir=='/');
    slashDat1Ind = find(data.spec1.fidDir=='/');
    slashDat2Ind = find(data.spec2.fidDir=='/');
else                    % PC
    slashProtInd = find(data.protDir=='\');
    slashDat1Ind = find(data.spec1.fidDir=='\');
    slashDat2Ind = find(data.spec2.fidDir=='\');
end

%--- DATA SET 1 ---
%--- maximum identical directory ---
dat1MaxMatchInd = 0;
for sCnt = 1:min(length(slashProtInd),length(slashDat1Ind))
    if strcmp(data.protDir(1:slashProtInd(sCnt)),data.spec1.fidFile(1:slashDat1Ind(sCnt)))
        dat1MaxMatchInd = slashDat1Ind(sCnt);
    end
end
%--- derive/assign relative directory structure ---
if dat1MaxMatchInd>0
    %--- consistency check: make sure data file is at the same level or below
    if length(data.protDir(dat1MaxMatchInd:end))>1            % more than single slash only
        fprintf('Data file is not in same directory or below. Program aborted.\n');
        return
    end
    
    %--- path update ---
    dat1PathExtra = data.spec1.fidFile(dat1MaxMatchInd+1:end);
    data.spec1.fidFile = [dataProtDirOld dat1PathExtra];
    
    %--- window and parameter update ---
    set(fm.data.spec1FidFile,'String',data.spec1.fidFile)
    SP2_Data_Dat1FidFileUpdate
    
    % info printout 
    fprintf('%s ->\nPaths of data set 1 reassigned relative to SPX protocol directory.\n',FCTNAME);
else
    fprintf('No directory consistency found. Path of data set 1 not updated.\n');
end

%--- DATA SET 2 ---
%--- maximum identical directory ---
dat2MaxMatchInd = 0;
for sCnt = 1:min(length(slashProtInd),length(slashDat2Ind))
    if strcmp(data.protDir(1:slashProtInd(sCnt)),data.spec2.fidFile(1:slashDat2Ind(sCnt)))
        dat2MaxMatchInd = slashDat2Ind(sCnt);
    end
end
%--- derive/assign relative directory structure ---
if dat2MaxMatchInd>0
    %--- consistency check: make sure data file is at the same level or below
    if length(data.protDir(dat2MaxMatchInd:end))>1            % more than single slash only
        fprintf('Data file is not in same directory or below. Program aborted.\n');
        return
    end
    
    %--- path update ---
    dat2PathExtra = data.spec2.fidFile(dat2MaxMatchInd+1:end);
    data.spec2.fidFile = [dataProtDirOld dat2PathExtra];
    
    %--- window and parameter update ---
    set(fm.data.spec2FidFile,'String',data.spec2.fidFile)
    SP2_Data_Dat2FidFileUpdate
    
    % info printout 
    fprintf('%s ->\nPaths of data set 2 reassigned relative to SPX protocol directory.\n',FCTNAME);
else
    fprintf('No directory consistency found. Path of data set 1 not updated.\n');
end

%--- reassign previous protocol path instead of the one that is inside the
%    protocol itself. Note that the previous one is also the new current one
%    as it describes the actual location of the protocol file
data.protFile     = dataProtFileOld;                   % protocol containing all FMAP parameters
data.protDir      = dataProtDirOld;                    % protocol directory, a study
data.protPath     = dataProtPathOld;                   % protocol path (.mat)
data.protPathMat  = dataProtPathMatOld;                % protocol path for text export/output (.txt)
data.protPathTxt  = dataProtPathTxtOld;                % protocol path for text export/output (.txt)
set(fm.data.protPath,'String',data.protPath)           % adopt image path
data.protPath = get(fm.data.protPath,'String');        % update path parameter

%--- update flag display ---
SP2_Data_DataWinUpdate

%--- check pars file existence
SP2_CheckFileExistence(data.spec1.fidFile)
SP2_CheckFileExistence(data.spec2.fidFile)



end
