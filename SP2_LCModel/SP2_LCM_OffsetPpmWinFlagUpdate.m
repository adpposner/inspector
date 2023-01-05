%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_OffsetPpmWinFlagUpdate
%% 
%%  Updates radiobutton setting: baseline offset mode
%%  1: mean of ppm range
%%  0: direct assignment of offset value
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- retrieve parameter ---
flag.lcmOffset = get(fm.lcm.offsetPpmFlag,'Value');

%--- switch radiobutton ---
set(fm.lcm.offsetPpmFlag,'Value',flag.lcmOffset)
set(fm.lcm.offsetValFlag,'Value',~flag.lcmOffset)

%--- update window ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
