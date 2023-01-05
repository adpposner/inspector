%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1DataSelect
%% 
%%  Data selection of spectrum 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_Spec1DataSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(proc.spec1.dataDir)
    if ispc
        proc.spec1.dataDir = 'C:\';
    elseif ismac
        proc.spec1.dataDir = '/Users/';
    else
        proc.spec1.dataDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(proc.spec1.dataDir);
    if ~f_succ
        proc.spec1.dataDir = maxPath;
    end
end

%--- browse the fid file ---
if flag.procDataFormat==1            % matlab format
    [procSpec1DataFileMat, procSpec1DataDir] = uigetfile('*.mat','Select FID file 1',proc.spec1.dataDir);       % select data file
    if ~ischar(procSpec1DataFileMat)             % buffer select cancelation
        if ~procSpec1DataFileMat            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec1.dataFileMat   = procSpec1DataFileMat;
    proc.spec1.dataDir       = procSpec1DataDir;
    proc.spec1.dataFileTxt   = [proc.spec1.dataFileMat(1:end-4) '.txt'];
    proc.spec1.dataFilePar   = [proc.spec1.dataFileMat(1:end-4) '.par'];
    proc.spec1.dataFileRaw   = [proc.spec1.dataFileMat(1:end-4) '.raw'];
    proc.spec1.dataFileCoord = [proc.spec1.dataFileMat(1:end-4) '.coord'];
elseif flag.procDataFormat==2        % RAG text format 
%     [procSpec1DataFileTxt, procSpec1DataDir] = uigetfile('*.txt','Select FID file',proc.spec1.dataDir);       % select data file
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [procSpec1DataFileTxt, procSpec1DataDir] = uigetfile(extCell,'Select FID file 1',proc.spec1.dataDir);       % select data file
    if ~ischar(procSpec1DataFileTxt)             % buffer select cancelation
        if ~procSpec1DataFileTxt            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec1.dataFileTxt = procSpec1DataFileTxt;
    proc.spec1.dataDir     = procSpec1DataDir;
    dotInd = find(proc.spec1.dataFileTxt=='.');
    if isempty(dotInd)
        proc.spec1.dataFileMat   = [proc.spec1.dataFileTxt '.mat'];
        proc.spec1.dataFilePar   = [proc.spec1.dataFileTxt '.par'];
        proc.spec1.dataFileRaw   = [proc.spec1.dataFileTxt '.raw'];
        proc.spec1.dataFileCoord = [proc.spec1.dataFileTxt '.coord'];
    else
        proc.spec1.dataFileMat   = [proc.spec1.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
        proc.spec1.dataFilePar   = [proc.spec1.dataFileTxt(1:(dotInd(end)-1)) '.par'];
        proc.spec1.dataFileRaw   = [proc.spec1.dataFileTxt(1:(dotInd(end)-1)) '.raw'];
        proc.spec1.dataFileCoord = [proc.spec1.dataFileTxt(1:(dotInd(end)-1)) '.coord'];
    end
elseif flag.procDataFormat==3       % metabolite (.par) text format
    %--- retrieve parameter file ---
    [procSpec1DataFilePar, procSpec1DataDir] = uigetfile('*.par','Select metabolite parameter file 1',proc.spec1.dataDir);       % select data file
    if ~ischar(procSpec1DataFilePar)             % buffer select cancelation
        if ~procSpec1DataFilePar            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    
    %--- parameter handling ---
    proc.spec1.dataFilePar   = procSpec1DataFilePar;
    proc.spec1.dataDir       = procSpec1DataDir;
    proc.spec1.dataFileTxt   = [proc.spec1.dataFilePar(1:end-4) '.txt'];
    proc.spec1.dataFileMat   = [proc.spec1.dataFilePar(1:end-4) '.mat'];
    proc.spec1.dataFileRaw   = [proc.spec1.dataFilePar(1:end-4) '.raw'];
    proc.spec1.dataFileCoord = [proc.spec1.dataFilePar(1:end-4) '.coord'];
elseif flag.procDataFormat==4       % LCModel data format
    [procSpec1DataFileRaw, procSpec1DataDir] = uigetfile('*.raw;*.RAW,*.h2o;*.H2O','Select FID file 1',proc.spec1.dataDir);       % select data file
    if ~ischar(procSpec1DataFileRaw)             % buffer select cancelation
        if ~procSpec1DataFileRaw            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec1.dataFileRaw   = procSpec1DataFileRaw;
    proc.spec1.dataDir       = procSpec1DataDir;
    proc.spec1.dataFileMat   = [proc.spec1.dataFileRaw(1:end-4) '.mat'];
    proc.spec1.dataFileTxt   = [proc.spec1.dataFileRaw(1:end-4) '.txt'];
    proc.spec1.dataFilePar   = [proc.spec1.dataFileRaw(1:end-4) '.par'];
    proc.spec1.dataFileCoord = [proc.spec1.dataFileRaw(1:end-4) '.coord'];
else                                % LCModel result/output format
    [procSpec1DataFileCoord, procSpec1DataDir] = uigetfile('*.coord;*.COORD','Select FID file 1',proc.spec1.dataDir);       % select data file
    if ~ischar(procSpec1DataFileCoord)             % buffer select cancelation
        if ~procSpec1DataFileCoord            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec1.dataFileCoord = procSpec1DataFileCoord;
    proc.spec1.dataDir       = procSpec1DataDir;
    proc.spec1.dataFileMat   = [proc.spec1.dataFileCoord(1:end-6) '.mat'];
    proc.spec1.dataFileTxt   = [proc.spec1.dataFileCoord(1:end-6) '.txt'];
    proc.spec1.dataFilePar   = [proc.spec1.dataFileCoord(1:end-6) '.par'];
    proc.spec1.dataFileRaw   = [proc.spec1.dataFileCoord(1:end-6) '.raw'];
end

%--- update paths ---
proc.spec1.dataPathTxt   = [proc.spec1.dataDir proc.spec1.dataFileTxt];         % update .txt path
proc.spec1.dataPathMat   = [proc.spec1.dataDir proc.spec1.dataFileMat];         % update .mat path
proc.spec1.dataPathPar   = [proc.spec1.dataDir proc.spec1.dataFilePar];         % update .par path
proc.spec1.dataPathRaw   = [proc.spec1.dataDir proc.spec1.dataFileRaw];         % update .raw path
proc.spec1.dataPathCoord = [proc.spec1.dataDir proc.spec1.dataFileCoord];       % update .coord path

%--- update display ---
SP2_Proc_ProcessWinUpdate
