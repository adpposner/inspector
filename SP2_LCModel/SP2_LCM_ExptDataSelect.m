%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ExptDataSelect
%% 
%%  Data selection of data set (FID) to be exported.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_ExptDataSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.expt.dataDir)
    if ispc
        lcm.expt.dataDir = 'C:\';
    elseif ismac
        lcm.expt.dataDir = '/Users/';
    else
        lcm.expt.dataDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(lcm.expt.dataDir);
    if ~f_succ
        lcm.expt.dataDir = maxPath;
    end
end

%--- browse the fid file ---
if flag.lcmDataFormat==1 || flag.lcmDataFormat==3 || flag.lcmDataFormat==5    % matlab format (for .mat, .par and .mrui selection)
    [procExptDataFileMat, procExptDataDir] = uigetfile('*.mat','Select export FID file',lcm.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileMat)             % buffer select cancelation
        if ~procExptDataFileMat            
            fprintf('%s aborted.\n',FCTNAME)
            return
        end
    end
    lcm.expt.dataFileMat = procExptDataFileMat;
    lcm.expt.dataDir     = procExptDataDir;
    lcm.expt.dataFileTxt = [lcm.expt.dataFileMat(1:end-4) '.txt'];
    lcm.expt.dataFileRaw = [lcm.expt.dataFileMat(1:end-4) '.raw'];
elseif flag.lcmDataFormat==2                           % RAG text format 
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [procExptDataFileTxt, procExptDataDir] = uigetfile(extCell,'Select export FID file',lcm.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileTxt)             % buffer select cancelation
        if ~procExptDataFileTxt            
            fprintf('%s aborted.\n',FCTNAME)
            return
        end
    end
    lcm.expt.dataFileTxt = procExptDataFileTxt;
    lcm.expt.dataDir     = procExptDataDir;
    dotInd = find(lcm.expt.dataFileTxt=='.');
    if isempty(dotInd)
        lcm.expt.dataFileMat = [lcm.expt.dataFileTxt '.mat'];
        lcm.expt.dataFileRaw = [lcm.expt.dataFileTxt '.raw'];
    else
        lcm.expt.dataFileMat = [lcm.expt.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
        lcm.expt.dataFileRaw = [lcm.expt.dataFileTxt(1:(dotInd(end)-1)) '.raw'];
    end
else                                                    % Provencher LCModel
    [procExptDataFileRaw, procExptDataDir] = uigetfile('*.raw','Select export FID file',lcm.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileRaw)             % buffer select cancelation
        if ~procExptDataFileRaw            
            fprintf('%s aborted.\n',FCTNAME)
            return
        end
    end
    lcm.expt.dataFileRaw = procExptDataFileRaw;
    lcm.expt.dataDir     = procExptDataDir;
    lcm.expt.dataFileMat = [lcm.expt.dataFileRaw(1:end-4) '.mat'];
    lcm.expt.dataFileTxt = [lcm.expt.dataFileRaw(1:end-4) '.txt'];
end

%--- update paths ---
lcm.expt.dataPathTxt = [lcm.expt.dataDir lcm.expt.dataFileTxt];          % update fid path
lcm.expt.dataPathMat = [lcm.expt.dataDir lcm.expt.dataFileMat];          % update fid path
lcm.expt.dataPathRaw = [lcm.expt.dataDir lcm.expt.dataFileRaw];          % update fid path

%--- update display ---
SP2_LCM_LCModelWinUpdate
