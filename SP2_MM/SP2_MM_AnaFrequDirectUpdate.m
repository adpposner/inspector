%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AnaFrequDirectUpdate
%% 
%%  Updates radiobutton setting: Direct assignment of frequency range.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.mmAnaFrequMode = ~get(fm.mm.anaFrequDirect,'Value');

%--- switch radiobutton ---
set(fm.mm.anaFrequglobal loggingfile,'Value',flag.mmAnaFrequMode)
set(fm.mm.anaFrequDirect,'Value',~flag.mmAnaFrequMode)

%--- update window ---
SP2_MM_MacroWinUpdate

