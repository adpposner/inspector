%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecDataParUpdate
%% 
%%  Update function for data path update of metabolite (.par) file.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm flag


FCTNAME = 'SP2_LCM_SpecDataParUpdate';

%--- fid file assignment ---
datFidFileTmp = get(fm.lcm.dataPath,'String');
datFidFileTmp = SP2_SlashWinLin(datFidFileTmp);
if isempty(datFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathPar)
    return
end
if ~strcmp(datFidFileTmp(end-3:end),'.par')
    fprintf('%s ->\nAssigned file is not a <.par> file. Please try again...\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathPar)
    return
end
if ~SP2_CheckFileExistenceR(datFidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathPar)
    return
end
set(fm.lcm.dataPath,'String',datFidFileTmp)
lcm.dataPathPar   = get(fm.lcm.dataPath,'String');
lcm.dataPathTxt   = [lcm.dataPathPar(1:end-4) '.txt'];
lcm.dataPathMat   = [lcm.dataPathPar(1:end-4) '.mat'];
lcm.dataPathRaw   = [lcm.dataPathPar(1:end-4) '.raw'];
lcm.dataPathJmrui = [lcm.dataPathPar(1:end-4) '.mrui'];

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(lcm.dataPathPar=='/');
else                        % 0: PC
    slInd = find(lcm.dataPathPar=='\');
end
lcm.dataDir       = lcm.dataPathPar(1:slInd(end));
lcm.dataFileMat   = lcm.dataPathMat(slInd(end)+1:end);
lcm.dataFileTxt   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFilePar   = lcm.dataPathPar(slInd(end)+1:end);
lcm.dataFileRaw   = lcm.dataPathRaw(slInd(end)+1:end);
lcm.dataFileJmrui = lcm.dataPathJmrui(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate




