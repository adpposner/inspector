%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ExptDataRawUpdate
%% 
%%  Update function for data path to export FID data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag

FCTNAME = 'SP2_Proc_ExptDataRawUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
exptFidFileTmp = get(fm.proc.exptDataPath,'String');
exptFidFileTmp = exptFidFileTmp;      % substitute / by \
if isempty(exptFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathRaw)
    return
end
if ~strcmp(exptFidFileTmp(end-3:end),'.raw')  && ~strcmp(exptFidFileTmp(end-3:end),'.RAW')
    fprintf('%s ->\nAssigned file is not a <.raw> file. Please try again...\n',FCTNAME);
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathRaw)
    return
end
set(fm.proc.exptDataPath,'String',exptFidFileTmp)
proc.expt.dataPathRaw = get(fm.proc.exptDataPath,'String');
proc.expt.dataPathTxt = [proc.expt.dataPathRaw(1:end-4) '.txt'];
proc.expt.dataPathMat = [proc.expt.dataPathRaw(1:end-4) '.mat'];

%--- update paths ---
if flag.OS>0                % 1: linux, 2: mac
    slInd = find(proc.expt.dataPathRaw=='/');
else                        % 0: PC
    slInd = find(proc.expt.dataPathRaw=='\');
end
proc.expt.dataDir     = proc.expt.dataPathRaw(1:slInd(end));
proc.expt.dataFileRaw = proc.expt.dataPathRaw(slInd(end)+1:end);
proc.expt.dataFileTxt = proc.expt.dataPathTxt(slInd(end)+1:end);
proc.expt.dataFileMat = proc.expt.dataPathMat(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate

%--- update success flag ---
f_succ = 1;



