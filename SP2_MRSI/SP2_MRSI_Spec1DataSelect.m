%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1DataSelect
%% 
%%  Data selection of spectrum 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

FCTNAME = 'SP2_MRSI_Spec1DataSelect';


%--- check directory access ---
[f_succ,maxPath] = SP2_CheckDirAccessR(mrsi.spec1.dataDir);
if ~f_succ
    mrsi.spec1.dataDir = maxPath;
end

%--- browse the fid file ---
if flag.mrsiDatFormat       % matlab format
    [procSpec1DataFileMat, procSpec1DataDir] = uigetfile('*.mat','Select FID file 1',mrsi.spec1.dataDir);       % select data file
    if ~ischar(procSpec1DataFileMat)             % buffer select cancelation
        if ~procSpec1DataFileMat            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    mrsi.spec1.dataFileMat = procSpec1DataFileMat;
    mrsi.spec1.dataDir     = procSpec1DataDir;
    mrsi.spec1.dataFileTxt = [mrsi.spec1.dataFileMat(1:end-4) '.txt'];
else                        % RAG text format 
%     [procSpec1DataFileTxt, procSpec1DataDir] = uigetfile('*.txt','Select FID file',mrsi.spec1.dataDir);       % select data file
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [procSpec1DataFileTxt, procSpec1DataDir] = uigetfile(extCell,'Select FID file 1',mrsi.spec1.dataDir);       % select data file
    if ~ischar(procSpec1DataFileTxt)             % buffer select cancelation
        if ~procSpec1DataFileTxt            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    mrsi.spec1.dataFileTxt = procSpec1DataFileTxt;
    mrsi.spec1.dataDir     = procSpec1DataDir;
    dotInd = find(mrsi.spec1.dataFileTxt=='.');
    if isempty(dotInd)
        mrsi.spec1.dataFileMat = [mrsi.spec1.dataFileTxt '.mat'];
    else
        mrsi.spec1.dataFileMat = [mrsi.spec1.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
    end
end

%--- update paths ---
mrsi.spec1.dataPathTxt = [mrsi.spec1.dataDir mrsi.spec1.dataFileTxt];          % update fid path
mrsi.spec1.dataPathMat = [mrsi.spec1.dataDir mrsi.spec1.dataFileMat];          % update fid path

%--- update display ---
SP2_MRSI_MrsiWinUpdate
