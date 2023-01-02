%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SimNoiseUpdate
%% 
%%  Include complex noise in simulated saturation-recovery spectra.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- direct assignment ---
flag.mmSimNoise = get(fm.mm.simNoise,'Value');

%--- switch radiobutton ---
set(fm.mm.simNoise,'Value',flag.mmSimNoise)

%--- update window ---
SP2_MM_MacroWinUpdate


