%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AnaFrequglobal loggingfileUpdate
%% 
%%  Updates radiobutton setting: global loggingfile frequency range
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.mmAnaFrequMode = get(fm.mm.anaFrequglobal loggingfile,'Value');

%--- switch radiobutton ---
set(fm.mm.anaFrequglobal loggingfile,'Value',flag.mmAnaFrequMode)
set(fm.mm.anaFrequDirect,'Value',~flag.mmAnaFrequMode)

%--- update window ---
SP2_MM_MacroWinUpdate

