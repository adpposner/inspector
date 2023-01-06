%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaDoMonteCarloInVivoBatch
%%
%%  Serial Monte-Carlo simulations of LCM analysis.
%%
%%  03-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag lcm data fm pars

FCTNAME = 'SP2_LCM_AnaDoMonteCarloInVivoBatch';


%--- check directory access ---
[f_succ,maxPath] = SP2_CheckDirAccessR(lcm.batch.protDir);
if ~f_succ
    if isempty(maxPath)
        if ispc
            lcm.batch.protDir = 'C:\';
        elseif ismac
            lcm.batch.protDir = '/Users/';
        else
            lcm.batch.protDir = '/home/';
        end
    else
        if ispc
            lcm.batch.protDir = [maxPath '\'];
        else
            lcm.batch.protDir = [maxPath '/'];
        end
    end
end

%--- get SPX protocol directory ---
lcmBatchProtDir = uigetdir(lcm.batch.protDir,'Select batch protocol directory');       
if ~ischar(lcmBatchProtDir)                             % buffer select cancelation
    if ~lcmBatchProtDir            
        fprintf('%s aborted.\n',FCTNAME);
        return
    end
end
lcm.batch.protDir = SP2_PathWinLin([lcmBatchProtDir '/']);

%--- retrieve all potential protocols ---
matFilePaths = SP2_FindFiles('mat',lcm.batch.protDir);
spxFilePaths = {};              % full SPX protocol file paths (including .mat extension)
spxFileNames = {};              % SPX protocol file names (including .mat extension)
spxFilesN    = 0;               % init SPX protocol file counter
for matCnt = 1:length(matFilePaths)
    %--- load mat file ---
    spxTmp = load(matFilePaths{matCnt}); 
    
    %--- assign SPX protocol files ---  
    if isfield(spxTmp,'proc2save')
        if isfield(spxTmp.proc2save,'ppmCalib')
            spxFilesN = spxFilesN + 1;
            spxFilePaths{spxFilesN} = matFilePaths{matCnt};
            if ispc
                slInd = strfind(matFilePaths{matCnt},'\');
            else
                slInd = strfind(matFilePaths{matCnt},'/');
            end
            spxFileNames{spxFilesN} = matFilePaths{matCnt}(slInd(end)+1:end);
        end
    end
end

%--- consistency check ---
if spxFilesN>0
    fprintf('%.0f SPX protocols found:\n',spxFilesN);
    for spxCnt = 1:spxFilesN
        fprintf('%.0f) %s\n',spxCnt,spxFileNames{spxCnt});
    end
else
    fprintf('%s ->\nBatch directory does not contain any valid SPX protocols. Program aborted\n',FCTNAME);
    return
end


%--- save current SPX protocol ---
% keep original
dataProtFileOrig = data.protFile;           % original protocol file info
dataProtDirOrig  = data.protDir;
dataProtPathOrig = data.protPath;
lcmBatchN        = lcm.batch.n;
% update with tmp protocol name
data.protFile    = ['SPX_BatchTmp_' SP2_Vec2PrintStr(rand(1)*1e20,0,0) '.mat'];
data.protDir     = lcm.batch.protDir;           
data.protPath    = [data.protDir data.protFile];
dataProtFile     = data.protFile;           % original SPX protocol except the protocol file info
dataProtDir      = data.protDir;
dataProtPath     = data.protPath;
% save protocol
SP2_Exit_ExitFct(dataProtPath,0)
if isfield(pars,'spxOpen')
    pars = rmfield(pars,'spxOpen');
end
INSPECTOR(dataProtPath)


%--- check data and basis access for all protocols ---
fprintf('\n****************************************************************\nGeneral check of protocol, data and basis consistency:\n\n');
for spxCnt = 1:spxFilesN
    %--- info printout ---
    fprintf('%.0f) %s\n',spxCnt,spxFileNames{spxCnt});
    
    %--- protocol path handling ---
    SP2_Data_DataMain
    set(fm.data.protPath,'String',spxFilePaths{spxCnt})
    if ~SP2_Data_ProtocolPathUpdate
        fprintf('Protocol assignment failed. Batch processing aborted.\n');
        return
    end
    if ~SP2_Data_ProtocolLoad
        fprintf('Protocol loading failed. Batch processing aborted.\n');
        return
    end

    %--- LCM page ---
    SP2_LCM_LCModelMain
    if ~SP2_LCM_SpecDataAndParsAssign
        fprintf('Data loading failed. Batch processing aborted.\n');
        return
    end
    if ~SP2_LCM_LcmBasisLoad
        fprintf('Basis loading failed. Batch processing aborted.\n');
        return
    end
end
fprintf('Data consistency check completed.\n');


%--- check data and basis access for all protocols ---
fprintf('\nBatch Monte-Carlo processing started.\n');
for spxCnt = 1:spxFilesN
    %--- info printout ---
    fprintf('\n\nANALYSIS %.0f OF %.0f:\nProtocol: %s\n\n',spxCnt,spxFilesN,spxFileNames{spxCnt});
    
    %--- protocol path handling ---
    SP2_Data_DataMain
    set(fm.data.protPath,'String',spxFilePaths{spxCnt})
    if ~SP2_Data_ProtocolPathUpdate
        fprintf('\n\n---   WARNING   ---\nAssignment of SPX protocol path failed.\n\n\n');
    end
    if ~SP2_Data_ProtocolLoad
        fprintf('\n\n---   WARNING   ---\nLoading of SPX protocol failed.\n\n\n');
    end
    
    %--- parameter handling ---
    if lcmBatchN>0                  % global number of MC computations (identical to all cases)
        lcm.mc.n = lcmBatchN;
    end
    flag.lcmMCarloRef  = 0;         % do NOT perform (extra) initial analysis as reference since this is done explicitly as part of this script
    % flag.lcmMCarloInit            % not affected (yet)
    % lcm.mc.initSpread             % not affected (yet)
    flag.lcmMCarloCont = 0;         % start from scratch
    flag.lcmSaveLog    = 1;         % save log file
    flag.verbose       = 1;         % include details

    %--- LCM page ---
    SP2_LCM_LCModelMain
    if ~SP2_LCM_SpecDataAndParsAssign
        fprintf('\n\n---   WARNING   ---\nLoading of data and parameters failed.\n\n\n');
    end
    if ~SP2_LCM_LcmBasisLoad
        fprintf('\n\n---   WARNING   ---\nLoading of basis failed.\n\n\n');
    end    
    
    %--- LCM calculation ---
    if ~SP2_LCM_AnaDoAnalysis(1)
        fprintf('\n\n---   WARNING   ---\nLCM analysis failed.\n\n\n');
    end
    if ~SP2_LCM_AnaSaveXls
        fprintf('\n\n---   WARNING   ---\nSaving of results to XLS file failed.\n\n\n');
    end
    if ~SP2_LCM_AnaSaveSummaryFigure
        fprintf('\n\n---   WARNING   ---\nSaving of summary figure failed.\n\n\n');
    end
    if ~SP2_LCM_AnaSaveSpxFigures
        fprintf('\n\n---   WARNING   ---\nSaving of SPX figures failed.\n\n\n');
    end
    if ~SP2_LCM_AnaSaveCorrFigures
        fprintf('\n\n---   WARNING   ---\nSaving of correlation figures failed.\n\n\n');
    end
    
    %--- disable LCM log file during MC to keep original one ---
    flag.lcmSaveLog = 0;            % save log file
    
    if ~SP2_LCM_AnaDoMonteCarloInVivo
       fprintf('\n\n---   WARNING   ---\nMonte-Carlo simulation failed.\n\n\n');
    end 
end

%--- close figures ---
if ~SP2_LCM_CloseLcmFigures
   fprintf('\n\n---   WARNING   ---\nClosing of LCM figures failed.\n\n\n');
end 

%--- info printout ---
fprintf('Batch processing of %.0f MC computations done.\n',spxFilesN);

%--- restore original overall parameters ---
SP2_Data_DataMain
set(fm.data.protPath,'String',dataProtPath)
if ~SP2_Data_ProtocolPathUpdate
    fprintf('\n\n---   WARNING   ---\nPath handling of protocol restoration failed.\n\n\n');
end
if ~SP2_Data_ProtocolLoad
    fprintf('\n\n---   WARNING   ---\nProtocol restoration failed.\n\n\n');
end
% delete temporary SPX protocol
delete(data.protPath)
% restore original protocol file info
data.protFile = dataProtFileOrig;           % original protocol file info
data.protDir  = dataProtDirOrig;
data.protPath = dataProtPathOrig;
set(fm.data.protPath,'String',dataProtPathOrig)

%--- go back to LCM page ---
SP2_LCM_LCModelMain
    
%--- info printout ---
fprintf('%s completed.\n\n',FCTNAME);



end
