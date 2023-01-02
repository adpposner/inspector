%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecDataMatUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm flag


FCTNAME = 'SP2_LCM_SpecDataMatUpdate';

%--- fid file assignment ---
datFidFileTmp = get(fm.lcm.dataPath,'String');
datFidFileTmp = SP2_SlashWinLin(datFidFileTmp);
if isempty(datFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathMat)
    return
end
if ~strcmp(datFidFileTmp(end-3:end),'.mat')
    fprintf('%s ->\nAssigned file is not a <.mat> file. Please try again...\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathMat)
    return
end
if ~SP2_CheckFileExistenceR(datFidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathMat)
    return
end
set(fm.lcm.dataPath,'String',datFidFileTmp)
lcm.dataPathMat   = get(fm.lcm.dataPath,'String');
lcm.dataPathTxt   = [lcm.dataPathMat(1:end-4) '.txt'];
lcm.dataPathPar   = [lcm.dataPathMat(1:end-4) '.par'];
lcm.dataPathRaw   = [lcm.dataPathMat(1:end-4) '.raw'];
lcm.dataPathJmrui = [lcm.dataPathMat(1:end-4) '.mrui'];

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(lcm.dataPathMat=='/');
else                        % 0: PC
    slInd = find(lcm.dataPathMat=='\');
end
lcm.dataDir       = lcm.dataPathMat(1:slInd(end));
lcm.dataFileMat   = lcm.dataPathMat(slInd(end)+1:end);
lcm.dataFileTxt   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFilePar   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFileRaw   = lcm.dataPathRaw(slInd(end)+1:end);
lcm.dataFileJmrui = lcm.dataPathJmrui(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate




