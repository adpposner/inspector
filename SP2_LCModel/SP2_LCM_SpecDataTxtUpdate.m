%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecDataTxtUpdate
%% 
%%  Update function for data path of FID data set 1.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm flag


FCTNAME = 'SP2_LCM_SpecDataTxtUpdate';

%--- fid file assignment ---
datFidFileTmp = get(fm.lcm.dataPath,'String');
datFidFileTmp = SP2_SlashWinLin(datFidFileTmp);
if isempty(datFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathTxt)
    return
end
if ~strcmp(datFidFileTmp(end-3:end),'.txt') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin1') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin2') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin3') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin4') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin5') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin6') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin7') && ...
   ~strcmp(datFidFileTmp(end-5:end),'.spin8') && ...
   isempty(datFidFileTmp=='.')
    fprintf('%s ->\nAssigned file is not a <.txt/.spinN/no ext.> file. Please try again...\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathTxt)
    return
end
if ~SP2_CheckFileExistenceR(datFidFileTmp)
    fprintf('%s ->\nAssigned file can''t be found.\n',FCTNAME);
    set(fm.lcm.dataPath,'String',lcm.dataPathTxt)
    return
end
set(fm.lcm.dataPath,'String',datFidFileTmp)
lcm.dataPathTxt = get(fm.lcm.dataPath,'String');
dotInd = find(lcm.dataPathTxt=='.');
if isempty(dotInd)
    lcm.dataPathMat   = [lcm.dataPathTxt '.mat'];
    lcm.dataPathPar   = [lcm.dataPathTxt '.par'];
    lcm.dataPathRaw   = [lcm.dataPathTxt '.raw'];
    lcm.dataPathJmrui = [lcm.dataPathTxt '.mrui'];
else
    lcm.dataPathMat   = [lcm.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
    lcm.dataPathPar   = [lcm.dataPathTxt(1:(dotInd(end)-1)) '.par'];
    lcm.dataPathRaw   = [lcm.dataPathTxt(1:(dotInd(end)-1)) '.raw'];
    lcm.dataPathJmrui = [lcm.dataPathTxt(1:(dotInd(end)-1)) '.mrui'];
end

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(lcm.dataPathTxt=='/');
else                        % 0: PC
    slInd = find(lcm.dataPathTxt=='\');
end
lcm.dataDir       = lcm.dataPathTxt(1:slInd(end));
lcm.dataFileTxt   = lcm.dataPathTxt(slInd(end)+1:end);
lcm.dataFileMat   = lcm.dataPathMat(slInd(end)+1:end);
lcm.dataFilePar   = lcm.dataPathMat(slInd(end)+1:end);
lcm.dataFileRaw   = lcm.dataPathRaw(slInd(end)+1:end);
lcm.dataFileJmrui = lcm.dataPathJmrui(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate




