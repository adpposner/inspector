%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ExptDataTxtUpdate
%% 
%%  Update function for data path to export FID data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag

FCTNAME = 'SP2_Proc_ExptDataTxtUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
exptFidFileTmp = get(fm.proc.exptDataPath,'String');
exptFidFileTmp = SP2_SlashWinLin(exptFidFileTmp);      % substitute / by \
if isempty(exptFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME)
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathTxt)
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
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathTxt)
    return
end
set(fm.proc.exptDataPath,'String',exptFidFileTmp)
proc.expt.dataPathTxt = get(fm.proc.exptDataPath,'String');
dotInd = find(proc.expt.dataPathTxt=='.');
if isempty(dotInd)
    proc.expt.dataPathMat = [proc.expt.dataPathTxt '.mat'];
    proc.expt.dataPathRaw = [proc.expt.dataPathTxt '.raw'];
else
    proc.expt.dataPathMat = [proc.expt.dataPathTxt(1:(dotInd(end)-1)) '.mat'];
    proc.expt.dataPathRaw = [proc.expt.dataPathTxt(1:(dotInd(end)-1)) '.raw'];
end

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(proc.expt.dataPathTxt=='/');
else                        % 0: PC
    slInd = find(proc.expt.dataPathTxt=='\');
end
proc.expt.dataDir     = proc.expt.dataPathTxt(1:slInd(end));
proc.expt.dataFileTxt = proc.expt.dataPathTxt(slInd(end)+1:end);
proc.expt.dataFileMat = proc.expt.dataPathMat(slInd(end)+1:end);
proc.expt.dataFileRaw = proc.expt.dataPathRaw(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate

%--- update flag ---
f_succ = 1;



