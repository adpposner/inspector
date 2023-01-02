%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2DataSelect
%% 
%%  Data selection of spectrum 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_Spec2DataSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(proc.spec2.dataDir)
    if ispc
        proc.spec2.dataDir = 'C:\';
    elseif ismac
        proc.spec2.dataDir = '/Users/';
    else
        proc.spec2.dataDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(proc.spec2.dataDir);
    if ~f_succ
        proc.spec2.dataDir = maxPath;
    end
end

%--- browse the fid file ---
if flag.procDataFormat==1            % matlab format
    [procSpec2DataFileMat, procSpec2DataDir] = uigetfile('*.mat','Select FID file 2',proc.spec2.dataDir);       % select data file
    if ~ischar(procSpec2DataFileMat)             % buffer select cancelation
        if ~procSpec2DataFileMat            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec2.dataFileMat   = procSpec2DataFileMat;
    proc.spec2.dataDir       = procSpec2DataDir;
    proc.spec2.dataFileTxt   = [proc.spec2.dataFileMat(1:end-4) '.txt'];
    proc.spec2.dataFilePar   = [proc.spec2.dataFileMat(1:end-4) '.par'];
    proc.spec2.dataFileRaw   = [proc.spec2.dataFileMat(1:end-4) '.raw'];
    proc.spec2.dataFileCoord = [proc.spec2.dataFileMat(1:end-4) '.coord'];
elseif flag.procDataFormat==2        % RAG text format 
%     [procSpec2DataFileTxt, procSpec2DataDir] = uigetfile('*.txt','Select FID file',proc.spec2.dataDir);       % select data file
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [procSpec2DataFileTxt, procSpec2DataDir] = uigetfile(extCell,'Select FID file 2',proc.spec2.dataDir);       % select data file
    if ~ischar(procSpec2DataFileTxt)             % buffer select cancelation
        if ~procSpec2DataFileTxt            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec2.dataFileTxt = procSpec2DataFileTxt;
    proc.spec2.dataDir     = procSpec2DataDir;
    dotInd = find(proc.spec2.dataFileTxt=='.');
    if isempty(dotInd)
        proc.spec2.dataFileMat   = [proc.spec2.dataFileTxt '.mat'];
        proc.spec2.dataFilePar   = [proc.spec2.dataFileTxt '.par'];
        proc.spec2.dataFileRaw   = [proc.spec2.dataFileTxt '.raw'];
        proc.spec2.dataFileCoord = [proc.spec2.dataFileTxt '.coord'];
    else
        proc.spec2.dataFileMat   = [proc.spec2.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
        proc.spec2.dataFilePar   = [proc.spec2.dataFileTxt(1:(dotInd(end)-1)) '.par'];
        proc.spec2.dataFileRaw   = [proc.spec2.dataFileTxt(1:(dotInd(end)-1)) '.raw'];
        proc.spec2.dataFileCoord = [proc.spec2.dataFileTxt(1:(dotInd(end)-1)) '.coord'];
    end
elseif flag.procDataFormat==3       % metabolite (.par) text format
    %--- retrieve parameter file ---
    [procSpec2DataFilePar, procSpec2DataDir] = uigetfile('*.par','Select metabolite parameter file 2',proc.spec2.dataDir);       % select data file
    if ~ischar(procSpec2DataFilePar)             % buffer select cancelation
        if ~procSpec2DataFilePar            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    
    %--- parameter handling ---
    proc.spec2.dataFilePar   = procSpec2DataFilePar;
    proc.spec2.dataDir       = procSpec2DataDir;
    proc.spec2.dataFileTxt   = [proc.spec2.dataFilePar(1:end-4) '.txt'];
    proc.spec2.dataFileMat   = [proc.spec2.dataFilePar(1:end-4) '.mat'];
    proc.spec2.dataFileCoord = [proc.spec2.dataFilePar(1:end-4) '.coord'];
elseif flag.procDataFormat==4       % LCModel data format
    [procSpec2DataFileRaw, procSpec2DataDir] = uigetfile('*.raw;*.RAW,*.h2o;*.H2O','Select FID file 2',proc.spec2.dataDir);       % select data file
    if ~ischar(procSpec2DataFileRaw)             % buffer select cancelation
        if ~procSpec2DataFileRaw            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec2.dataFileRaw   = procSpec2DataFileRaw;
    proc.spec2.dataDir       = procSpec2DataDir;
    proc.spec2.dataFileMat   = [proc.spec2.dataFileRaw(1:end-4) '.mat'];
    proc.spec2.dataFileTxt   = [proc.spec2.dataFileRaw(1:end-4) '.txt'];
    proc.spec2.dataFilePar   = [proc.spec2.dataFileRaw(1:end-4) '.par'];
    proc.spec2.dataFileCoord = [proc.spec2.dataFileRaw(1:end-4) '.coord'];
else                                % LCModel result/output format (NOT SUPPORTED...)
    [procSpec2DataFileCoord, procSpec2DataDir] = uigetfile('*.coord;*.COORD','Select FID file 2',proc.spec2.dataDir);       % select data file
    if ~ischar(procSpec2DataFileCoord)             % buffer select cancelation
        if ~procSpec2DataFileCoord            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    proc.spec2.dataFileCoord = procSpec2DataFileCoord;
    proc.spec2.dataDir       = procSpec2DataDir;
    proc.spec2.dataFileMat   = [proc.spec2.dataFileCoord(1:end-6) '.mat'];
    proc.spec2.dataFileTxt   = [proc.spec2.dataFileCoord(1:end-6) '.txt'];
    proc.spec2.dataFilePar   = [proc.spec2.dataFileCoord(1:end-6) '.par'];
    proc.spec2.dataFileRaw   = [proc.spec2.dataFileCoord(1:end-6) '.raw'];
end

%--- update paths ---
proc.spec2.dataPathTxt   = [proc.spec2.dataDir proc.spec2.dataFileTxt];         % update .txt path
proc.spec2.dataPathMat   = [proc.spec2.dataDir proc.spec2.dataFileMat];         % update .mat path
proc.spec2.dataPathPar   = [proc.spec2.dataDir proc.spec2.dataFilePar];         % update .par path
proc.spec2.dataPathRaw   = [proc.spec2.dataDir proc.spec2.dataFileRaw];         % update .raw path
proc.spec2.dataPathCoord = [proc.spec2.dataDir proc.spec2.dataFileCoord];       % update .coord path

%--- update display ---
SP2_Proc_ProcessWinUpdate
