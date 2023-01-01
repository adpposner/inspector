%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_FormatMagnUpdate
%% 
%%  Visualization mode:
%%  1) real
%%  2) imaginary
%%  3) magnitude
%%  4) phase
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- direct assignment ---
flag.mmFormat = 3;

%--- switch radiobutton ---
set(fm.mm.formatReal,'Value',flag.mmFormat==1)
set(fm.mm.formatImag,'Value',flag.mmFormat==2)
set(fm.mm.formatMagn,'Value',flag.mmFormat==3)
set(fm.mm.formatPhase,'Value',flag.mmFormat==4)

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

%--- update window ---
SP2_MM_MacroWinUpdate


