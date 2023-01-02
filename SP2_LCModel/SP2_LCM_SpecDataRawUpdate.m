%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecDataRawUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm flag


FCTNAME = 'SP2_LCM_SpecDataRawUpdate';

%--- fid file assignment ---
datFidFileTmp = get(fm.lcm.dataPath,'String');
datFidFileTmp = SP2_SlashWinLin(datFidFileTmp);
if isempty(datFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathRaw)
    return
end
if ~strcmp(datFidFileTmp(end-3:end),'.raw') && ~strcmp(datFidFileTmp(end-3:end),'.RAW')
    fprintf('%s ->\nAssigned file is not a <.raw> file. Please try again...\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathRaw)
    return
end
if ~SP2_CheckFileExistenceR(datFidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathRaw)
    return
end
set(fm.lcm.dataPath,'String',datFidFileTmp)
lcm.dataPathRaw   = get(fm.lcm.dataPath,'String');
lcm.dataPathTxt   = [lcm.dataPathRaw(1:end-4) '.txt'];
lcm.dataPathPar   = [lcm.dataPathRaw(1:end-4) '.par'];
lcm.dataPathMat   = [lcm.dataPathRaw(1:end-4) '.mat'];
lcm.dataPathJmrui = [lcm.dataPathRaw(1:end-4) '.mrui'];

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(lcm.dataPathRaw=='/');
else                        % 0: PC
    slInd = find(lcm.dataPathRaw=='\');
end
lcm.dataDir       = lcm.dataPathRaw(1:slInd(end));
lcm.dataFileRaw   = lcm.dataPathRaw(slInd(end)+1:end);
lcm.dataFileTxt   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFilePar   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFileMat   = lcm.dataPathMat(slInd(end)+1:end);
lcm.dataFileJmrui = lcm.dataPathJmrui(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate




