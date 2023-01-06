%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_ExptDataSelect
%% 
%%  Data selection of data set (FID) to be exported.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_ExptDataSelect';


%--- check directory access ---
[f_succ,maxPath] = SP2_CheckDirAccessR(mrsi.expt.dataDir);
if ~f_succ
    mrsi.expt.dataDir = maxPath;
end

%--- browse the fid file ---
if flag.mrsiDatFormat       % matlab format
    [procExptDataFileMat, procExptDataDir] = uigetfile('*.mat','Select export FID file',mrsi.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileMat)             % buffer select cancelation
        if ~procExptDataFileMat            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    mrsi.expt.dataFileMat = procExptDataFileMat;
    mrsi.expt.dataDir     = procExptDataDir;
    mrsi.expt.dataFileTxt = [mrsi.expt.dataFileMat(1:end-4) '.txt'];
else                        % RAG text format 
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [procExptDataFileTxt, procExptDataDir] = uigetfile(extCell,'Select export FID file',mrsi.expt.dataDir);       % select data file
    if ~ischar(procExptDataFileTxt)             % buffer select cancelation
        if ~procExptDataFileTxt            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    mrsi.expt.dataFileTxt = procExptDataFileTxt;
    mrsi.expt.dataDir     = procExptDataDir;
    dotInd = find(mrsi.expt.dataFileTxt=='.');
    if isempty(dotInd)
        mrsi.expt.dataFileMat = [mrsi.expt.dataFileTxt '.mat'];
    else
        mrsi.expt.dataFileMat = [mrsi.expt.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
    end
end

%--- update paths ---
mrsi.expt.dataPathTxt = [mrsi.expt.dataDir mrsi.expt.dataFileTxt];          % update fid path
mrsi.expt.dataPathMat = [mrsi.expt.dataDir mrsi.expt.dataFileMat];          % update fid path

%--- update display ---
SP2_MRSI_MrsiWinUpdate

end
