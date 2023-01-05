%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_ColormapHotUpdate
%% 
%%  Updates radiobutton settings to switch color modes:
%%  0) unicolor (blue only)
%%  1) JET
%%  2) Uns' Uwe
%%  3) HOT
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- flag handling ---
flag.synColorMap = 3;

%--- update flag displays ---
set(fm.syn.cmapUni,'Value',flag.synColorMap==0)
set(fm.syn.cmapJet,'Value',flag.synColorMap==1)
set(fm.syn.cmapHsv,'Value',flag.synColorMap==2)
set(fm.syn.cmapHot,'Value',flag.synColorMap==3)

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

