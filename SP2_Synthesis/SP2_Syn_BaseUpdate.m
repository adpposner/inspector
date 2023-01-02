%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_BaseUpdate
%% 
%%  Include baseline in simulated spectra.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- direct assignment ---
flag.synBase = get(fm.syn.base,'Value');

%--- switch radiobutton ---
set(fm.syn.base,'Value',flag.synBase)

%--- update window ---
SP2_Syn_SynthesisWinUpdate


