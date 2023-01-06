%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecDataJmruiUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm flag


FCTNAME = 'SP2_LCM_SpecDataJmruiUpdate';

%--- fid file assignment ---
datFidFileTmp = get(fm.lcm.dataPath,'String');
datFidFileTmp = datFidFileTmp;
if isempty(datFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathJmrui)
    return
end
if ~strcmp(datFidFileTmp(end-4:end),'.mrui')
    fprintf('%s ->\nAssigned file is not a <.mrui> file. Please try again...\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathJmrui)
    return
end
if ~SP2_CheckFileExistenceR(datFidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathJmrui)
    return
end
set(fm.lcm.dataPath,'String',datFidFileTmp)
lcm.dataPathJmrui = get(fm.lcm.dataPath,'String');
lcm.dataPathTxt   = [lcm.dataPathJmrui(1:end-5) '.txt'];
lcm.dataPathPar   = [lcm.dataPathJmrui(1:end-5) '.par'];
lcm.dataPathMat   = [lcm.dataPathJmrui(1:end-5) '.mat'];
lcm.dataPathRaw   = [lcm.dataPathJmrui(1:end-5) '.raw'];

%--- update paths ---
if flag.OS>0            % 1: linux, 2: mac
    slInd = find(lcm.dataPathJmrui=='/');
else                    % 0: PC
    slInd = find(lcm.dataPathJmrui=='\');
end
lcm.dataDir       = lcm.dataPathRaw(1:slInd(end));
lcm.dataFileRaw   = lcm.dataPathRaw(slInd(end)+1:end);
lcm.dataFileTxt   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFilePar   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFileMat   = lcm.dataPathMat(slInd(end)+1:end);
lcm.dataFileJmrui = lcm.dataPathJmrui(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate





end
