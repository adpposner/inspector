%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_ConvertPar2Mat
%% 
%%  Perform data conversion from .par to .mat for all data sets found in the
%%  directory of data set 1. The results are written to the export directory.
%%  The processing selected for data set 1 is applied.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag fm

FCTNAME = 'SP2_Proc_ConvertPar2Mat';


%--- init success flag ---
f_done = 0;

%--- check access of data directory ---
if ~SP2_CheckDirAccessR(proc.spec1.dataDir)
    return
end

%--- check access of export directory ---
if ~SP2_CheckDirAccessR(proc.expt.dataDir)
    return
end

%--- file handling ---
dataFidPaths = SP2_FindFiles('par',proc.spec1.dataDir);
nPar         = length(dataFidPaths);
dataFidFiles = {};          % full file names (including .par)
dataFidNames = {};          % core file names (i.e. metabolite name only)
for parCnt = 1:nPar
    slInd = strfind(dataFidPaths{parCnt},'\');
    dataFidFiles{parCnt} = dataFidPaths{parCnt}(slInd(end)+1:end);
    dataFidNames{parCnt} = dataFidPaths{parCnt}(slInd(end)+1:end-4);
end

%--- keep parameter settings ---
procSpec1DataDir     = proc.spec1.dataDir;              % .par only
procSpec1DataFilePar = proc.spec1.dataFilePar;
procSpec1DataPathPar = proc.spec1.dataPathPar;
procExptDataDir      = proc.expt.dataDir;               % .mat only
procExptDataFileMat  = proc.expt.dataFileMat;
procExptDataPathMat  = proc.expt.dataPathMat;
flagProcData         = flag.procData;
flagProcDataFormat   = flag.procDataFormat;

%--- assign parameter settings ---
flagProcData        = flag.procData;
flagProcDataFormat  = flag.procDataFormat;
flag.procData       = 2;                                % processing page
flag.procDataFormat = 3;                                % .par format


%--- basis creation and basis FID handling ---
convCnt = 0;                                            % FID conversion counter
for parCnt = 1:nPar
    %--- path assignment ---
    proc.spec1.dataPathPar = dataFidPaths{parCnt};
    proc.spec1.dataFilePar = [dataFidNames{parCnt} '.par'];
    
    %--- load and process FID ---
    if SP2_Proc_DataAndParsAssign1
        %--- info printout ---
        if flag.verbose
            fprintf('\nLoading <%s> completed\n',dataFidNames{parCnt});
        end
        
        %--- update conversion counter ---
        convCnt = convCnt + 1;
    
        %--- create basis structure ---
        if SP2_Proc_ProcData1
            if flag.verbose
                fprintf('\nProcessing <%s> completed\n',dataFidNames{parCnt});
            end
        else
            fprintf('\nProcessing <%s> failed. Data conversion aborted.\n',dataFidNames{parCnt});
            return
        end
        
        %--- export assignment ---
        proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
        proc.expt.sf     = proc.spec1.sf;
        proc.expt.sw_h   = proc.spec1.sw_h;
        proc.expt.nspecC = proc.spec1.nspecC;        
        
        %--- export path handling ---
        proc.expt.dataPathMat = [proc.expt.dataDir dataFidNames{parCnt} proc.convExtStr '.mat'];
        set(fm.proc.exptDataPath,'String',proc.expt.dataPathMat)
        
        %--- data export ---
        flag.procDataFormat = 1;                                % .mat format
        if SP2_Proc_ExptDataSave
            fprintf('\n<%s> saved to file .mat format\n',dataFidNames{parCnt});
        else
            fprintf('\nSaving <%s> to .mat format failed. Data conversion aborted.\n',dataFidNames{parCnt});
            return
        end
        flag.procDataFormat = 3;                                % .par format

        
        %--- keep glucose anomers for potential combination ---
        if strcmp(dataFidNames{parCnt},'GlcA') || strcmp(dataFidNames{parCnt},'GlucoseA') || ...
           strcmp(dataFidNames{parCnt},'GlcB') || strcmp(dataFidNames{parCnt},'GlucoseB')
            eval([dataFidNames{parCnt} '.fid    = proc.expt.fid;'])
            eval([dataFidNames{parCnt} '.sf     = proc.expt.sf;'])
            eval([dataFidNames{parCnt} '.sw_h   = proc.expt.sw_h;'])
            eval([dataFidNames{parCnt} '.nspecC = proc.expt.nspecC;'])
        end
    else
        fprintf('\nLoading <%s> failed\n',dataFidNames{parCnt});
    end
end

%--- consistency check ---
if convCnt>0
    fprintf('%.0f spectra converted from .par to .mat format\n',convCnt);
else
    fprintf('Zero spectra converted.\n');
    return
end

%--- combine GlucoseA/GlucoseB ---
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
if any(cellfun(cellfind('GlcA'),dataFidNames)) && any(cellfun(cellfind('GlcB'),dataFidNames))
    %--- open yes/no dialog ---
    choice = questdlg('Would you like to combine GlcA/B?','Glucose Handling Dialog', ...
                      'Yes','No','Yes');
    
    %--- combination of GlucoseA/B ---
    if strcmp(choice,'Yes')
        %--- index handling ---
        GlcAInd = find(cellfun(cellfind('GlcA'),dataFidNames));
        GlcBInd = find(cellfun(cellfind('GlcB'),dataFidNames));

        %--- parameter consistency checks ---
        f_consistent = 1;
        if eval([dataFidNames{GlcAInd} '.sf ~= ' dataFidNames{GlcBInd} '.sf'])
            fprintf('Incompatible Larmor frequencies detected: %.1f MHz ~= %.1f MHz.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.sf']),eval([dataFidNames{GlcBInd} '.sf']))
            f_consistent = 0;
        end
        if eval([dataFidNames{GlcAInd} '.sw_h ~= ' dataFidNames{GlcBInd} '.sw_h'])
            fprintf('Incompatible bandwidths detected: %.0f MHz ~= %.0f Hz.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.sw_h']),eval([dataFidNames{GlcBInd} '.sw_h']))
            f_consistent = 0;
        end
        if eval([dataFidNames{GlcAInd} '.nspecC ~= ' dataFidNames{GlcBInd} '.nspecC'])
            fprintf('Incompatible FID lengths detected: %.0f pts ~= %.0f pts.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.nspecC']),eval([dataFidNames{GlcBInd} '.nspecC']))
            f_consistent = 0;
        end
    
        %--- data processing and export ---
        if f_consistent
            %--- export assignment ---
            eval(['proc.expt.fid    = 0.36*' dataFidNames{GlcAInd} '.fid + 0.64*' dataFidNames{GlcBInd} '.fid;']);
            eval(['proc.expt.sf     = ' dataFidNames{GlcAInd} '.sf;']);
            eval(['proc.expt.sw_h   = ' dataFidNames{GlcAInd} '.sw_h;']);
            eval(['proc.expt.nspecC = ' dataFidNames{GlcAInd} '.nspecC;']);

            %--- export path handling ---
            proc.expt.dataPathMat = [proc.expt.dataDir 'Glc' proc.convExtStr '.mat'];

            %--- data export ---
            if SP2_Proc_ExptDataSave
                fprintf('\n<Glc> saved to file .mat format\n');
            else
                fprintf('\nSaving <Glc> to .mat format failed. Data conversion aborted.\n');
                return
            end

            %--- info output ---
            fprintf('\nGlucose anomers combined as 0.36*GlcA + 0.64*GlcB\n');
        end
    end
end

%--- combine GlcA/GlcB or GlucoseA/GlucoseB ---
if any(cellfun(cellfind('GlucoseA'),dataFidNames)) && any(cellfun(cellfind('GlucoseB'),dataFidNames))
    %--- open yes/no dialog ---
    choice = questdlg('Would you like to combine GlucoseA/B?','Glucose Handling Dialog', ...
                      'Yes','No','Yes');
    
    %--- combination of GlucoseA/B ---
    if strcmp(choice,'Yes')
        %--- index handling ---
        GlcAInd = find(cellfun(cellfind('GlucoseA'),dataFidNames));
        GlcBInd = find(cellfun(cellfind('GlucoseB'),dataFidNames));

        %--- parameter consistency checks ---
        f_consistent = 1;
        if eval([dataFidNames{GlcAInd} '.sf ~= ' dataFidNames{GlcBInd} '.sf'])
            fprintf('Incompatible Larmor frequencies detected: %.1f MHz ~= %.1f MHz.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.sf']),eval([dataFidNames{GlcBInd} '.sf']))
            f_consistent = 0;
        end
        if eval([dataFidNames{GlcAInd} '.sw_h ~= ' dataFidNames{GlcBInd} '.sw_h'])
            fprintf('Incompatible bandwidths detected: %.0f Hz ~= %.0f Hz.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.sw_h']),eval([dataFidNames{GlcBInd} '.sw_h']))
            f_consistent = 0;
        end
        if eval([dataFidNames{GlcAInd} '.nspecC ~= ' dataFidNames{GlcBInd} '.nspecC'])
            fprintf('Incompatible FID lengths detected: %.0f pts ~= %.0f pts.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.nspecC']),eval([dataFidNames{GlcBInd} '.nspecC']))
            f_consistent = 0;
        end
        
        %--- data processing and export ---
        if f_consistent
            %--- export assignment ---
            eval(['proc.expt.fid    = 0.36*' dataFidNames{GlcAInd} '.fid + 0.64*' dataFidNames{GlcBInd} '.fid;']);
            eval(['proc.expt.sf     = ' dataFidNames{GlcAInd} '.sf;']);
            eval(['proc.expt.sw_h   = ' dataFidNames{GlcAInd} '.sw_h;']);
            eval(['proc.expt.nspecC = ' dataFidNames{GlcAInd} '.nspecC;']);

            %--- export path handling ---
            proc.expt.dataPathMat = [proc.expt.dataDir 'Glucose' proc.convExtStr '.mat'];

            %--- data export ---
            if SP2_Proc_ExptDataSave
                fprintf('\n<Glucose> saved to file .mat format\n');
            else
                fprintf('\nSaving <Glucose> to .mat format failed. Data conversion aborted.\n');
                return
            end
            
            %--- remove individual glucose anomer files ---
            delete([proc.expt.dataDir dataFidNames{GlcAInd} '.mat'])
            delete([proc.expt.dataDir dataFidNames{GlcBInd} '.mat'])

            %--- info output ---
            fprintf('Glucose anomers combined as 0.36*GlucoseA + 0.64*GlucoseB\n\n');
        end
    end
end

%--- restore parameter settings ---
proc.spec1.dataDir     = procSpec1DataDir;              % .par only
proc.spec1.dataFilePar = procSpec1DataFilePar;
proc.spec1.dataPathPar = procSpec1DataPathPar;
proc.expt.dataDir      = procExptDataDir;               % .mat only
proc.expt.dataFileMat  = procExptDataFileMat;
proc.expt.dataPathMat  = procExptDataPathMat;
flag.procData          = flagProcData;
flag.procDataFormat    = flagProcDataFormat;

%--- reset parameters ---
flag.procData        = flagProcData;
flag.procDataFormat  = flagProcDataFormat;

%--- window update ---
SP2_Proc_ProcessMain

%--- info printout ---
fprintf('Data conversion from .par to .mat completed.\n');

%--- update success flag ---
f_done = 1;

