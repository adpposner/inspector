%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_PpmShowFullUpdate
%% 
%%  Updates radiobutton setting: full sweep width visualization
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.mmPpmShow = get(fm.mm.ppmShowFull,'Value');

%--- switch radiobutton ---
set(fm.mm.ppmShowFull,'Value',flag.mmPpmShow)
set(fm.mm.ppmShowDirect,'Value',~flag.mmPpmShow)

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

