%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AmplShowDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignmen of amplitude limits
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


flag.mmAmplShow = ~get(fm.mm.amplShowDirect,'Value');

%--- switch radiobutton ---
set(fm.mm.amplShowAuto,'Value',flag.mmAmplShow)
set(fm.mm.amplShowDirect,'Value',~flag.mmAmplShow)

%--- figure update ---
SP2_MM_SatRecShowFidSingle(0);
SP2_MM_SatRecShowSpecSingle(0);
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_SatRecShowSpecArray(0);
SP2_MM_SatRecShowSpecSum(0);
SP2_MM_SatRecShowSpecSubtract(0);
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);
SP2_MM_T1ShowSpecSubtract(0);
SP2_MM_T1ShowSpec2D(0);

%--- update window ---
SP2_MM_MacroWinUpdate


