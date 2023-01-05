%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_MmStructPathUpdate
%% 
%%  Update file path of mm structure.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mm flag


FCTNAME = 'SP2_MM_MmStructPathUpdate';

%--- fid file assignment ---
mmStructPathTmp = get(fm.mm.mmStructPath,'String');
mmStructPathTmp = mmStructPathTmp;
if isempty(mmStructPathTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.mm.mmStructPath,'String',mm.mmStructPath)
    return
end
if ~strcmp(mmStructPathTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME);
    set(fm.mm.mmStructPath,'String',mm.mmStructPath)
    return
end
if ~SP2_CheckFileExistenceR(mmStructPathTmp)
    fprintf('\n*** WARNING ***\n%s ->\nAssigned file can''t be opened...\n',FCTNAME);
    set(fm.mm.mmStructPath,'String',mm.mmStructPath)
end
set(fm.mm.mmStructPath,'String',mmStructPathTmp)
mm.mmStructPath = get(fm.mm.mmStructPath,'String');
clear mmStructPathTmp

%--- update file parameters ---
if flag.OS==1            % Linux
    slashInd = find(mm.mmStructPath=='/');
elseif flag.OS==2        % Mac
    slashInd = find(mm.mmStructPath=='/');
else                     % PC
    slashInd = find(mm.mmStructPath=='\');
end
mm.mmStructDir  = mm.mmStructPath(1:slashInd(end));
mm.mmStructFile = mm.mmStructPath(slashInd(end)+1:end);

%--- update flag display ---
SP2_MM_MacroWinUpdate



