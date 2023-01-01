%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_DoProcAndSave
%% 
%%  Temporary batch processing option.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_LCM_DoProcAndSave';


%--- init success flag ---
f_succ = 0;

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

%--- update success flag ---
f_succ = 1;

   