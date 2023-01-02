%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ColormapUniUpdate
%% 
%%  Updates radiobutton settings to switch color modes:
%%  0) unicolor (blue only)
%%  1) JET
%%  2) Uns' Uwe
%%  3) HOT
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- flag handling ---
flag.mmCMap = 0;

%--- update flag displays ---
set(fm.mm.cmapUni,'Value',flag.mmCMap==0)
set(fm.mm.cmapJet,'Value',flag.mmCMap==1)
set(fm.mm.cmapHsv,'Value',flag.mmCMap==2)
set(fm.mm.cmapHot,'Value',flag.mmCMap==3)

%--- figure update ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);

%--- window update ---
SP2_MM_MacroWinUpdate

