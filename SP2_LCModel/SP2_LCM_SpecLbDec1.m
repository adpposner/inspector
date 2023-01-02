%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SpecLbDec1
%% 
%%  0.1Hz reduction of exponential line broadenin.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- update percentage value spec 1 ---
lcm.specLb = lcm.specLb - 0.1;
set(fm.lcm.specLbVal,'String',sprintf('%.2f',lcm.specLb))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate
