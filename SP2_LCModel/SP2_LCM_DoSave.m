%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_DoSave
%% 
%%  Temporary batch processing option.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_LCM_DoSave';


%--- init success flag ---
f_done = 0;

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
f_done = 1;

   