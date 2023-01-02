%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_ProtocolPathUpdate
%% 
%%  Update of FMAP protocol path
%%
%%  10-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag data

FCTNAME = 'SP2_Data_ProtocolPathUpdate';


%--- init success flag ---
f_succ = 0;

%--- (temporary) file assignment ---
protPathTmp = get(fm.data.protPath,'String');
if isempty(protPathTmp)
    fprintf('%s -> An empty entry is useless.\n',FCTNAME);
    set(fm.data.protPath,'String',data.protPath)
    return
end
protPathTmp = SP2_SlashWinLin(protPathTmp);

%--- (temporary) file and directory extraction ---
if flag.OS>0            % 1: linux, 2: mac
    iSlash = find(protPathTmp=='/');
else                    % 0: PC
    iSlash = find(protPathTmp=='\');
end
if isempty(iSlash)
    fprintf('%s -> Unknown directory format.\n',FCTNAME);
    set(fm.data.protPath,'String',data.protPath)
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
    set(fm.data.protPath,'String',data.protPath)
    return
end

%--- adopt names and paths ---
set(fm.data.protPath,'String',protPathTmp(1:end-4))      % adopt image path
data.protPath = get(fm.data.protPath,'String');          % update path parameter

%--- file and directory extraction ---
if flag.OS>0            % 1: linux, 2: mac
    iSlash = find(data.protPath=='/');
else                    % 0: PC
    iSlash = find(data.protPath=='\');
end
data.protDir     = data.protPath(1:iSlash(end));
data.protFile    = data.protPath(iSlash(end)+1:end);
data.protPathMat = [data.protPath '.mat'];
data.protPathTxt = [data.protPath '.txt'];

%--- update success flag ---
f_succ = 1;


