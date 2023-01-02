%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecShiftInc2
%% 
%%  1Hz increased shift of spectrum 1.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- update value spec 1 ---
lcm.specShift = lcm.specShift + 0.01;
set(fm.lcm.specShiftVal,'String',sprintf('%.3f',lcm.specShift))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate
