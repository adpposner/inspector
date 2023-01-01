%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ExptDataSelect
%% 
%%  Data selection of data set (FID) to be exported.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_ExptDataSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(proc.expt.dataDir)
    if ispc
        proc.expt.dataDir = 'C:\';
    elseif ismac
        proc.expt.dataDir = '/Users/';
    else
        proc.expt.dataDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(proc.expt.dataDir);
    if ~f_succ
        proc.expt.dataDir = maxPath;
    end
end

%--- browse the fid file ---
if flag.procDataFormat==1 || flag.procDataFormat==3     % matlab format (for .mat and .par selection)
    [procExptDataFileMat, procExptDataDir] = uigetfile('*.mat','Select export FID file',proc.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileMat)             % buffer select cancelation
        if ~procExptDataFileMat            
            fprintf('%s aborted.\n',FCTNAME)
            return
        end
    end
    proc.expt.dataFileMat = procExptDataFileMat;
    proc.expt.dataDir     = procExptDataDir;
    proc.expt.dataFileTxt = [proc.expt.dataFileMat(1:end-4) '.txt'];
    proc.expt.dataFileRaw = [proc.expt.dataFileMat(1:end-4) '.raw'];
elseif flag.procDataFormat==2                           % RAG text format 
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [procExptDataFileTxt, procExptDataDir] = uigetfile(extCell,'Select export FID file',proc.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileTxt)             % buffer select cancelation
        if ~procExptDataFileTxt            
            fprintf('%s aborted.\n',FCTNAME)
            return
        end
    end
    proc.expt.dataFileTxt = procExptDataFileTxt;
    proc.expt.dataDir     = procExptDataDir;
    dotInd = find(proc.expt.dataFileTxt=='.');
    if isempty(dotInd)
        proc.expt.dataFileMat = [proc.expt.dataFileTxt '.mat'];
        proc.expt.dataFileRaw = [proc.expt.dataFileTxt '.raw'];
    else
        proc.expt.dataFileMat = [proc.expt.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
        proc.expt.dataFileRaw = [proc.expt.dataFileTxt(1:(dotInd(end)-1)) '.raw'];
    end
else                                                    % Provencher LCModel
    [procExptDataFileRaw, procExptDataDir] = uigetfile('*.raw','Select export FID file',proc.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileRaw)             % buffer select cancelation
        if ~procExptDataFileRaw            
            fprintf('%s aborted.\n',FCTNAME)
            return
        end
    end
    proc.expt.dataFileRaw = procExptDataFileRaw;
    proc.expt.dataDir     = procExptDataDir;
    proc.expt.dataFileMat = [proc.expt.dataFileRaw(1:end-4) '.mat'];
    proc.expt.dataFileTxt = [proc.expt.dataFileRaw(1:end-4) '.txt'];
end

%--- update paths ---
proc.expt.dataPathTxt = [proc.expt.dataDir proc.expt.dataFileTxt];          % update fid path
proc.expt.dataPathMat = [proc.expt.dataDir proc.expt.dataFileMat];          % update fid path
proc.expt.dataPathRaw = [proc.expt.dataDir proc.expt.dataFileRaw];          % update fid path

%--- update display ---
SP2_Proc_ProcessWinUpdate
