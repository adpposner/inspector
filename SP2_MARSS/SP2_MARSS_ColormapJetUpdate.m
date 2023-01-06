%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ColormapJetUpdate
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
flag.marssColorMap = 1;

%--- update flag displays ---
set(fm.marss.cmapUni,'Value',flag.marssColorMap==0)
set(fm.marss.cmapJet,'Value',flag.marssColorMap==1)
set(fm.marss.cmapHsv,'Value',flag.marssColorMap==2)
set(fm.marss.cmapHot,'Value',flag.marssColorMap==3)

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate

end
