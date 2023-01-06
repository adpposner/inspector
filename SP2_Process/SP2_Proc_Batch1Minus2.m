%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_Batch1Minus2
%% 
%%  Perfrom batch calculuation and file handling:
%%  Data set 1 minus data set 2 (if both exist).
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_Batch1Minus2';


%--- init success flag ---
f_done = 0;

%--- check access of data directories ---
if ~SP2_CheckDirAccessR(proc.spec1.dataDir)
    return
end
if ~SP2_CheckDirAccessR(proc.spec2.dataDir)
    return
end

%--- check access of export directory ---
if ~SP2_CheckDirAccessR(proc.expt.dataDir)
    return
end

%--- file handling: directory 1 ---
dat1FidPaths = SP2_FindFiles('mat',proc.spec1.dataDir);
dat1n        = length(dat1FidPaths);
dat1FidFiles = {};          % full file names (including .par)
dat1FidNames = {};          % core file names (i.e. metabolite name only)
for fCnt = 1:dat1n
    slInd = strfind(dat1FidPaths{fCnt},'\');
    dat1FidFiles{fCnt} = dat1FidPaths{fCnt}(slInd(end)+1:end);
    dat1FidNames{fCnt} = dat1FidPaths{fCnt}(slInd(end)+1:end-4);
end

%--- file handling: directory 2 ---
dat2FidPaths = SP2_FindFiles('mat',proc.spec2.dataDir);
dat2n        = length(dat2FidPaths);
dat2FidFiles = {};          % full file names (including .par)
dat2FidNames = {};          % core file names (i.e. metabolite name only)
for fCnt = 1:dat2n
    slInd = strfind(dat2FidPaths{fCnt},'\');
    dat2FidFiles{fCnt} = dat2FidPaths{fCnt}(slInd(end)+1:end);
    dat2FidNames{fCnt} = dat2FidPaths{fCnt}(slInd(end)+1:end-4);
end

%--- keep parameter settings ---
procSpec1DataDir     = proc.spec1.dataDir;              % .par only
procSpec1DataFileMat = proc.spec1.dataFileMat;
procSpec1DataPathMat = proc.spec1.dataPathMat;
procSpec2DataDir     = proc.spec2.dataDir;              % .par only
procSpec2DataFileMat = proc.spec2.dataFileMat;
procSpec2DataPathMat = proc.spec2.dataPathMat;
procExptDataDir      = proc.expt.dataDir;               % .mat only
procExptDataFileMat  = proc.expt.dataFileMat;
procExptDataPathMat  = proc.expt.dataPathMat;
flagProcNumSpec      = flag.procNumSpec;
flagProcData         = flag.procData;
flagProcDataFormat   = flag.procDataFormat;

%--- assign parameter settings ---
flag.procNumSpec    = 2;                                % 2 spectra mode
flag.procData       = 2;                                % processing page
flag.procDataFormat = 1;                                % .mat format

%--- basis creation and basis FID handling ---
cellfind = @(string)(@(cell_contents)(strcmp(string,cell_contents)));
matchCnt = 0;                                            % matches found
for fCnt = 1:dat1n
    %--- check for matching files ---
    if any(cellfun(cellfind(dat1FidNames{fCnt}),dat2FidNames))
        %--- path assignment: data directory 1  ---
        proc.spec1.dataPathMat = dat1FidPaths{fCnt};
        proc.spec1.dataFileMat = [dat1FidNames{fCnt} '.mat'];
        
        %--- path assignment: data directory 2 ---
        dat2Ind = find(cellfun(cellfind(dat1FidNames{fCnt}),dat2FidNames));
        proc.spec2.dataPathMat = dat2FidPaths{dat2Ind};
        proc.spec2.dataFileMat = [dat2FidNames{dat2Ind} '.mat'];

        %--- load data from file ---
        f_consistent = 1;
        if SP2_Proc_DataAndParsAssign1 && SP2_Proc_DataAndParsAssign2
            %--- parameter consistency checks ---
            if proc.spec1.sf~=proc.spec2.sf
                fprintf('Incompatible Larmor frequencies detected: %.1f MHz ~= %.1f MHz.\nProgram aborted.\n',...
                        proc.spec1.sf,proc.spec2.sf)
                f_consistent = 0;
            end
            if proc.spec1.sw_h~=proc.spec2.sw_h
                fprintf('Incompatible bandwidths detected: %.0f Hz ~= %.0f Hz.\nProgram aborted.\n',...
                        proc.spec1.sw_h,proc.spec2.sw_h)
                f_consistent = 0;
            end
            if proc.spec1.nspecC~=proc.spec2.nspecC
                fprintf('Incompatible FID lengths detected: %.0f pts ~= %.0f pts.\nProgram aborted.\n',...
                        proc.spec1.nspecC,proc.spec2.nspecC)
                f_consistent = 0;
            end
            
            %--- data processing and export ---
            if f_consistent
                %--- data processing ---
                if ~SP2_Proc_ProcData1
                    fprintf('%s ->\nProcessing of data set 1 failed. Program aborted.\n\n',FCTNAME);
                    return
                end
                if ~SP2_Proc_ProcData2
                    fprintf('%s ->\nProcessing of data set 2 failed. Program aborted.\n\n',FCTNAME);
                    return
                end
                
                %--- export assignment ---
                proc.expt.fid    = ifft(ifftshift(proc.spec1.spec-proc.spec2.spec,1),[],1);
                proc.expt.sf     = proc.spec1.sf;
                proc.expt.sw_h   = proc.spec1.sw_h;
                proc.expt.nspecC = proc.spec1.nspecC;

                %--- update conversion counter ---
                matchCnt = matchCnt + 1;

                %--- export path handling ---
                proc.expt.dataPathMat = [proc.expt.dataDir dat1FidNames{fCnt} proc.convExtStr '.mat'];

                %--- data export ---
                if SP2_Proc_ExptDataSave
                    fprintf('\n<%s> saved to file .mat format\n',dat1FidNames{fCnt});
                else
                    fprintf('\nSaving <%s> to .mat format failed. Data conversion aborted.\n',dat1FidNames{fCnt});
                    return
                end
            end
        else
            fprintf('\nLoading of at least one <%s> files failed\n',dat1FidNames{fCnt});
        end
    end
end

%--- consistency check ---
if matchCnt>0
    fprintf('%.0f matching files found and spectra subtracted\n',matchCnt);
else
    fprintf('Zero matching spectra found.\n');
    return
end

%--- combine GlucoseA/GlucoseB ---
if any(cellfun(cellfind('GlcA'),dat1FidNames)) && any(cellfun(cellfind('GlcB'),dataFidNames))
    %--- open yes/no dialog ---
    choice = questdlg('Would you like to combine GlcA/B?','Glucose Handling Dialog', ...
                      'Yes','No','Yes');
    
    %--- combination of GlucoseA/B ---
    if strcmp(choice,'Yes')
        %--- index handling ---
        GlcAInd = find(cellfun(cellfind('GlcA'),dataFidNames));
        GlcBInd = find(cellfun(cellfind('GlcB'),dataFidNames));

        %--- parameter consistency checks ---
        if eval([dataFidNames{GlcAInd} '.sf ~= ' dataFidNames{GlcBInd} '.sf'])
            fprintf('Incompatible Larmor frequencies detected: %.1f MHz ~= %.1f MHz.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.sf']),eval([dataFidNames{GlcBInd} '.sf']))
        end
        if eval([dataFidNames{GlcAInd} '.sw_h ~= ' dataFidNames{GlcBInd} '.sw_h'])
            fprintf('Incompatible bandwidths detected: %.0f MHz ~= %.0f Hz.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.sw_h']),eval([dataFidNames{GlcBInd} '.sw_h']))
        end
        if eval([dataFidNames{GlcAInd} '.nspecC ~= ' dataFidNames{GlcBInd} '.nspecC'])
            fprintf('Incompatible FID lengths detected: %.0f pts ~= %.0f pts.\nProgram aborted.\n',...
                    eval([dataFidNames{GlcAInd} '.nspecC']),eval([dataFidNames{GlcBInd} '.nspecC']))
        end

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

%--- restore parameter settings ---
proc.spec1.dataDir     = procSpec1DataDir;              % .mat only
proc.spec1.dataFileMat = procSpec1DataFileMat;
proc.spec1.dataPathMat = procSpec1DataPathMat;
proc.spec2.dataDir     = procSpec2DataDir;              % .mat only
proc.spec2.dataFileMat = procSpec2DataFileMat;
proc.spec2.dataPathMat = procSpec2DataPathMat;
proc.expt.dataDir      = procExptDataDir;               % .mat only
proc.expt.dataFileMat  = procExptDataFileMat;
proc.expt.dataPathMat  = procExptDataPathMat;
flag.procNumSpec       = flagProcNumSpec;
flag.procData          = flagProcData;
flag.procDataFormat    = flagProcDataFormat;

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- info printout ---
fprintf('Difference calculation of data sets 1 and 2 completed.\n');

%--- update success flag ---
f_done = 1;


end
