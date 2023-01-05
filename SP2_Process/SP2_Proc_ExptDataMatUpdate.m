%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ExptDataMatUpdate
%% 
%%  Update function for data path to export FID data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag

FCTNAME = 'SP2_Proc_ExptDataMatUpdate';


%--- init success flag ---
f_succ = 0;

%--- fid file assignment ---
exptFidFileTmp = get(fm.proc.exptDataPath,'String');
exptFidFileTmp = exptFidFileTmp;      % substitute / by \
if isempty(exptFidFileTmp)
    fprintf('%s ->\nAn empty entry is useless.\n',FCTNAME);
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathMat)
    return
end
if ~strcmp(exptFidFileTmp(end-3:end),'.mat') && ~isempty(strfind(exptFidFileTmp,'.'))
    if strcmp(exptFidFileTmp(end-3:end),'.par')
        fprintf('%s ->\n<.par> files are not supported for data export.\nUse another format instead.\n',FCTNAME);
    else
        fprintf('%s ->\nAssigned file is not a <.mat> file.\nPlease try again...\n',FCTNAME);
    end
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathMat)
    return
end
set(fm.proc.exptDataPath,'String',exptFidFileTmp)
if isempty(strfind(exptFidFileTmp,'.'))
    proc.expt.dataPathMat = [get(fm.proc.exptDataPath,'String') '.mat'];
else
    proc.expt.dataPathMat = get(fm.proc.exptDataPath,'String');
end
proc.expt.dataPathTxt = [proc.expt.dataPathMat(1:end-4) '.txt'];
proc.expt.dataPathRaw = [proc.expt.dataPathMat(1:end-4) '.raw'];

%--- update paths ---
if flag.OS>0                    % 1: linux, 2: mac
    slInd = find(proc.expt.dataPathMat=='/');
else                            % 0: PC
    slInd = find(proc.expt.dataPathMat=='\');
end
proc.expt.dataDir     = proc.expt.dataPathMat(1:slInd(end));
proc.expt.dataFileMat = proc.expt.dataPathMat(slInd(end)+1:end);
proc.expt.dataFileTxt = proc.expt.dataPathTxt(slInd(end)+1:end);
proc.expt.dataFileRaw = proc.expt.dataPathRaw(slInd(end)+1:end);

%--- update flag display ---
SP2_Proc_ProcessWinUpdate

%--- update success flag ---
f_succ = 1;


