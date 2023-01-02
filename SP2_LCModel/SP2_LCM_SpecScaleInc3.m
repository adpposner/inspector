%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecScaleInc3
%% 
%%  0.1 increased scaling of spectrum 1.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- update value spec 1 ---
lcm.specScale = lcm.specScale + 0.1;
set(fm.lcm.specScaleVal,'String',sprintf('%.3f',lcm.specScale))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate
