%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2DataSelect
%% 
%%  Data selection of spectrum 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

FCTNAME = 'SP2_MRSI_Spec2DataSelect';


%--- check directory access ---
[f_succ,maxPath] = SP2_CheckDirAccessR(mrsi.spec2.dataDir);
if ~f_succ
    mrsi.spec2.dataDir = maxPath;
end

%--- browse the fid file ---
if flag.mrsiDatFormat       % matlab format
    [procSpec2DataFileMat, procSpec2DataDir] = uigetfile('*.mat','Select FID file 2',mrsi.spec2.dataDir);       % select data file
    if ~ischar(procSpec2DataFileMat)             % buffer select cancelation
        if ~procSpec2DataFileMat            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    mrsi.spec2.dataFileMat = procSpec2DataFileMat;
    mrsi.spec2.dataDir     = procSpec2DataDir;
    mrsi.spec2.dataFileTxt = [mrsi.spec2.dataFileMat(1:end-4) '.txt'];
else                        % RAG text format 
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [procSpec2DataFileTxt, procSpec2DataDir] = uigetfile(extCell,'Select FID file 2',mrsi.spec2.dataDir);       % select data file
    if ~ischar(procSpec2DataFileTxt)             % buffer select cancelation
        if ~procSpec2DataFileTxt            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    mrsi.spec2.dataFileTxt = procSpec2DataFileTxt;
    mrsi.spec2.dataDir     = procSpec2DataDir;
    dotInd = find(mrsi.spec2.dataFileTxt=='.');
    if isempty(dotInd)
        mrsi.spec2.dataFileMat = [mrsi.spec2.dataFileTxt '.mat'];
    else
        mrsi.spec2.dataFileMat = [mrsi.spec2.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
    end
end

%--- update paths ---
mrsi.spec2.dataPathTxt = [mrsi.spec2.dataDir mrsi.spec2.dataFileTxt];          % update fid path
mrsi.spec2.dataPathMat = [mrsi.spec2.dataDir mrsi.spec2.dataFileMat];          % update fid path

%--- update display ---
SP2_MRSI_MrsiWinUpdate
