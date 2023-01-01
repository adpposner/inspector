%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ExptDataTxtUpdate
%% 
%%  Update function for data path to export FID data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm flag


FCTNAME = 'SP2_LCM_ExptDataTxtUpdate';

%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
exptFidFileTmp = get(fm.lcm.exptDataPath,'String');
exptFidFileTmp = SP2_SlashWinLin(exptFidFileTmp);      % substitute / by \
if isempty(exptFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathTxt)
    return
end
if ~strcmp(exptFidFileTmp(end-3:end),'.txt') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin1') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin2') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin3') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin4') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin5') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin6') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin7') && ...
   ~strcmp(exptFidFileTmp(end-5:end),'.spin8') && ...
   isempty(exptFidFileTmp=='.')
    fprintf('%s ->\nAssigned file is not a <.txt/.spinN/no ext.> file. Please try again...\n',FCTNAME)
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathTxt)
    return
end
set(fm.lcm.exptDataPath,'String',exptFidFileTmp)
lcm.expt.dataPathTxt = get(fm.lcm.exptDataPath,'String');
dotInd = find(lcm.expt.dataPathTxt=='.');
if isempty(dotInd)
    lcm.expt.dataPathMat = [lcm.expt.dataPathTxt '.mat'];
    lcm.expt.dataPathRaw = [lcm.expt.dataPathTxt '.raw'];
else
    lcm.expt.dataPathMat = [lcm.expt.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
    lcm.expt.dataPathRaw = [lcm.expt.dataPathTxt(1:(dotInd(end)-1)) '.raw'];
end

%--- update paths ---
if flag.OS>0                        % 1: linux, 2: mac
    slInd = find(lcm.expt.dataPathTxt=='/');
else                                % 0: PC
    slInd = find(lcm.expt.dataPathTxt=='\');
end
lcm.expt.dataDir     = lcm.expt.dataPathTxt(1:slInd(end));
lcm.expt.dataFileTxt = lcm.expt.dataPathTxt(slInd(end)+1:end);
lcm.expt.dataFileMat = lcm.expt.dataPathMat(slInd(end)+1:end);
lcm.expt.dataFileRaw = lcm.expt.dataPathRaw(slInd(end)+1:end);

%--- update flag display ---
SP2_LCM_LCModelWinUpdate

%--- update success flag ---
f_succ = 1;



