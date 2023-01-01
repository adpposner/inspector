%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AnaFrequGlobalUpdate
%% 
%%  Updates radiobutton setting: Global frequency range
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mmAnaFrequMode = get(fm.mm.anaFrequGlobal,'Value');

%--- switch radiobutton ---
set(fm.mm.anaFrequGlobal,'Value',flag.mmAnaFrequMode)
set(fm.mm.anaFrequDirect,'Value',~flag.mmAnaFrequMode)

%--- update window ---
SP2_MM_MacroWinUpdate

