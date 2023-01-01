%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SimFidPathUpdate
%% 
%%  Update file path of FID used for simulation of sat-rec. experiment.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm flag


FCTNAME = 'SP2_MM_SimFidPathUpdate';


%--- fid file assignment ---
mmSimFidPathTmp = get(fm.mm.simFidPath,'String');
mmSimFidPathTmp = SP2_SlashWinLin(mmSimFidPathTmp);
if isempty(mmSimFidPathTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
    set(fm.mm.simFidPath,'String',mm.sim.fidPath)
    return
end
if any(strfind(mmSimFidPathTmp,'.'))
    fprintf('%s ->\nAssigned file is not a text file without extension. Please try again...\n',FCTNAME)
    set(fm.mm.simFidPath,'String',mm.sim.fidPath)
    return
end
if ~SP2_CheckFileExistenceR(mmSimFidPathTmp)
    fprintf('\n*** WARNING ***\n%s ->\nAssigned file can''t be opened...\n',FCTNAME)
    set(fm.mm.simFidPath,'String',mm.sim.fidPath)
end
set(fm.mm.simFidPath,'String',mmSimFidPathTmp)
mm.sim.fidPath = get(fm.mm.simFidPath,'String');
clear mmSimFidPathTmp

%--- update file parameters ---
if flag.OS==1            % Linux
    slashInd = find(mm.mm.simFidPath=='/');
elseif flag.OS==2        % Mac
    slashInd = find(mm.mm.simFidPath=='/');
else                     % PC
    slashInd = find(mm.mm.simFidPath=='\');
end
mm.sim.fidDir  = mm.sim.fidPath(1:slashInd(end));
mm.sim.fidName = mm.sim.fidPath(slashInd(end)+1:end);

%--- update flag display ---
SP2_MM_MacroWinUpdate


