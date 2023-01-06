%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AnaFrequglobalUpdate
%% 
%%  Updates radiobutton setting: global frequency range
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mmAnaFrequMode = get(fm.mm.anaFrequglobal,'Value');

%--- switch radiobutton ---
set(fm.mm.anaFrequglobal,'Value',flag.mmAnaFrequMode)
set(fm.mm.anaFrequDirect,'Value',~flag.mmAnaFrequMode)

%--- update window ---
SP2_MM_MacroWinUpdate

