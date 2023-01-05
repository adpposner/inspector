%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ColormapUniUpdate
%% 
%%  Updates radiobutton settings to switch color modes:
%%  0) unicolor (blue only)
%%  1) JET
%%  2) Uns' Uwe
%%  3) HOT
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- flag handling ---
flag.lcmColorMap = 0;

%--- update flag displays ---
set(fm.lcm.cmapUni,'Value',flag.lcmColorMap==0)
set(fm.lcm.cmapJet,'Value',flag.lcmColorMap==1)
set(fm.lcm.cmapHsv,'Value',flag.lcmColorMap==2)
set(fm.lcm.cmapHot,'Value',flag.lcmColorMap==3)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
