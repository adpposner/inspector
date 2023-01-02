%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_DoProcTmp
%% 
%%  Temporary batch processing option.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data lcm fm

FCTNAME = 'SP2_Data_DoProcTmp';


%--- init success flag ---
f_done = 0;

%--- Data page ---
set(fm.data.spec2FidFile,'String',data.spec1.fidFile)
SP2_Data_Dat2FidFileUpdate

if ~SP2_Data_Dat1FidFileLoadButton
    return
end
if ~SP2_Data_Dat2FidFileLoadButton
    return
end
if ~SP2_Data_DoPhaseCorr
    return
end
if ~SP2_Data_DoSumRcvrs
    return
end


%--- Processing page ---
SP2_Proc_ProcessMain
if ~SP2_Proc_DataAndParsAssign1
    return
end
SP2_Proc_ProcAndPlotSpec1(1)

% update fid data path
fidPath = [data.protDir 'fid.mat'];
if ~SP2_CheckFileExistenceR(fidPath)
    return
end
set(fm.proc.exptDataPath,'String',fidPath);
SP2_Proc_ExptDataMatUpdate

if ~SP2_Proc_ExptDataSave
    return
end

if ~SP2_Proc_CloseProcFigures
    return
end

%--- LCM page ---
SP2_LCM_LCModelMain

% data path
set(fm.lcm.dataPath,'String',fidPath)
SP2_LCM_SpecDataPathUpdate

% save path
set(fm.lcm.exptDataPath,'String',fidPath)
SP2_LCM_ExptDataPathUpdate

if ~SP2_LCM_SpecDataAndParsAssign
    return
end
if ~SP2_LCM_LcmBasisLoad
    return
end
if ~SP2_LCM_AnaDoAnalysis(1)
    return
end
if ~SP2_LCM_AnaSaveXls
    return
end
if ~SP2_LCM_AnaSaveSummaryFigure
    return
end
if ~SP2_LCM_AnaSaveSpxFigures
    return
end
if ~SP2_LCM_AnaSaveCorrFigures
    return
end

%--- Data page ---
SP2_Data_DataMain

%--- update success flag ---
f_done = 1;

   