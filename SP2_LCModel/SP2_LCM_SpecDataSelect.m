%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecDataSelect
%% 
%%  Data selection of spectrum.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm flag

FCTNAME = 'SP2_LCM_SpecDataSelect';


%--- check directory access ---
if ~SP2_CheckDirAccessR(lcm.dataDir)
    if ispc
        lcm.dataDir = 'C:\';
    elseif ismac
        lcm.dataDir = '/Users/';
    else
        lcm.dataDir = '/home/';
    end
else
    [f_succ,maxPath] = SP2_CheckDirAccessR(lcm.dataDir);
    if ~f_succ
        lcm.dataDir = maxPath;
    end
end

%--- browse the fid file ---
if flag.lcmDataFormat==1            % matlab format
    [lcmDataFileMat, lcmDataDir] = uigetfile('*.mat','Select FID file',lcm.dataDir);       % select data file
    if ~ischar(lcmDataFileMat)             % buffer select cancelation
        if ~lcmDataFileMat            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    lcm.dataFileMat   = lcmDataFileMat;
    lcm.dataDir       = lcmDataDir;
    lcm.dataFileTxt   = [lcm.dataFileMat(1:end-4) '.txt'];
    lcm.dataFilePar   = [lcm.dataFileMat(1:end-4) '.par'];
    lcm.dataFileRaw   = [lcm.dataFileMat(1:end-4) '.raw'];
    lcm.dataFileJmrui = [lcm.dataFileMat(1:end-4) '.mrui'];
elseif flag.lcmDataFormat==2        % RAG text format 
    extCell = {'*.txt;*.spin1;*.spin2;*.spin3;*.spin4;*.spin5;*.spin6;*.spin7;*.spin8;'};
    [lcmDataFileTxt, lcmDataDir] = uigetfile(extCell,'Select FID file',lcm.dataDir);       % select data file
    if ~ischar(lcmDataFileTxt)             % buffer select cancelation
        if ~lcmDataFileTxt            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    lcm.dataFileTxt = lcmDataFileTxt;
    lcm.dataDir     = lcmDataDir;
    dotInd = find(lcm.dataFileTxt=='.');
    if isempty(dotInd)
        lcm.dataFileMat   = [lcm.dataFileTxt '.mat'];
        lcm.dataFilePar   = [lcm.dataFileTxt '.par'];
        lcm.dataFileRaw   = [lcm.dataFileTxt '.raw'];
        lcm.dataFileJmrui = [lcm.dataFileTxt '.mrui'];
    else
        lcm.dataFileMat   = [lcm.dataFileTxt(1:(dotInd(end)-1)) '.mat'];
        lcm.dataFilePar   = [lcm.dataFileTxt(1:(dotInd(end)-1)) '.par'];
        lcm.dataFileRaw   = [lcm.dataFileTxt(1:(dotInd(end)-1)) '.raw'];
        lcm.dataFileJmrui = [lcm.dataFileTxt(1:(dotInd(end)-1)) '.mrui'];
    end
elseif flag.lcmDataFormat==3       % metabolite (.par) text format
    %--- retrieve parameter file ---
    [lcmDataFilePar, lcmDataDir] = uigetfile('*.par','Select metabolite parameter file',lcm.dataDir);       % select data file
    if ~ischar(lcmDataFilePar)             % buffer select cancelation
        if ~lcmDataFilePar            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    
    %--- parameter handling ---
    lcm.dataFilePar   = lcmDataFilePar;
    lcm.dataDir       = lcmDataDir;
    lcm.dataFileTxt   = [lcm.dataFilePar(1:end-4) '.txt'];
    lcm.dataFileMat   = [lcm.dataFilePar(1:end-4) '.mat'];
    lcm.dataFileRaw   = [lcm.dataFilePar(1:end-4) '.raw'];
    lcm.dataFileJmrui = [lcm.dataFilePar(1:end-4) '.mrui'];
elseif flag.lcmDataFormat==4                                % LCModel format
    [lcmDataFileRaw, lcmDataDir] = uigetfile('*.raw','Select FID file 1',lcm.dataDir);       % select data file
    if ~ischar(lcmDataFileRaw)             % buffer select cancelation
        if ~lcmDataFileRaw            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    lcm.dataFileRaw   = lcmDataFileRaw;
    lcm.dataDir       = lcmDataDir;
    lcm.dataFileMat   = [lcm.dataFileRaw(1:end-4) '.mat'];
    lcm.dataFileTxt   = [lcm.dataFileRaw(1:end-4) '.txt'];
    lcm.dataFilePar   = [lcm.dataFileRaw(1:end-4) '.par'];
    lcm.dataFileJmrui = [lcm.dataFileRaw(1:end-4) '.mrui'];
else                                        % JMRUI format
    [lcmDataFileJmrui, lcmDataDir] = uigetfile('*.mrui','Select FID file 1',lcm.dataDir);       % select data file
    if ~ischar(lcmDataFileJmrui)              % buffer select cancelation
        if ~lcmDataFileJmrui            
            fprintf('%s aborted.\n',FCTNAME);
            return
        end
    end
    lcm.dataFileJmrui = lcmDataFileJmrui;
    lcm.dataDir       = lcmDataDir;
    lcm.dataFileMat   = [lcm.dataFileJmrui(1:end-5) '.mat'];
    lcm.dataFileTxt   = [lcm.dataFileJmrui(1:end-5) '.txt'];
    lcm.dataFilePar   = [lcm.dataFileJmrui(1:end-5) '.par'];
    lcm.dataFileRaw   = [lcm.dataFileJmrui(1:end-5) '.raw'];
end

%--- update paths ---
lcm.dataPathTxt   = [lcm.dataDir lcm.dataFileTxt];          % update .txt path
lcm.dataPathMat   = [lcm.dataDir lcm.dataFileMat];          % update .mat path
lcm.dataPathPar   = [lcm.dataDir lcm.dataFilePar];          % update .par path
lcm.dataPathRaw   = [lcm.dataDir lcm.dataFileRaw];          % update .raw path
lcm.dataPathJmrui = [lcm.dataDir lcm.dataFileJmrui];          % update .mrui path

%--- update display ---
SP2_LCM_LCModelWinUpdate
