%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_ProtocolPathUpdate(protPath)
%% 
%%  Update of FMAP protocol path
%%
%%  10-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag data

FCTNAME = 'SP2_Data_ProtocolPathUpdate';


%--- init success flag ---
f_succ = 0;

%--- (temporary) file assignment ---
protPathTmp = get(fm.protPath,'String');
if isempty(protPathTmp)
    fprintf('%s -> An empty entry is useless.\n',FCTNAME);
    set(fm.protPath,'String',protPath)
    return
end
protPathTmp = protPathTmp;

%--- (temporary) file and directory extraction ---

    iSlash = find(protPathTmp==filesep);

if isempty(iSlash)
    fprintf('%s -> Unknown directory format.\n',FCTNAME);
    set(fm.protPath,'String',protPath)
    return
end
protDirTmp  = protPathTmp(1:iSlash(end)-1);
protFileTmp = protPathTmp(iSlash(end)+1:end);
% add extension if necessary
if ~any(protFileTmp=='.')
    protPathTmp = [protPathTmp '.mat'];
    protFileTmp = [protFileTmp '.mat'];
end
% check file format
if ~strcmp(protFileTmp(end-3:end),'.mat')
    fprintf('%s -> Assigned file is not a .mat file. Please try again...\n',FCTNAME);
    set(fm.protPath,'String',protPath)
    return
end

%--- adopt names and paths ---
set(fm.protPath,'String',protPathTmp(1:end-4))      % adopt image path
protPath = get(fm.protPath,'String');          % update path parameter

[protDir,protFile,protPathMat,protPathTxt] = SP2_FileHelper.protocolPaths(protPath);
%--- update success flag ---
f_succ = 1;


