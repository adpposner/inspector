%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecGbDec2
%% 
%%  1Hz reduction of Gaussian line broadening.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- update GB value spec 1 ---
lcm.specGb = lcm.specGb - 1;
set(fm.lcm.specGbVal,'String',sprintf('%.2f',lcm.specGb))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate
