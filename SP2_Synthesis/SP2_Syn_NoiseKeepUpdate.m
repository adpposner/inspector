%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_NoiseKeepUpdate
%% 
%%  Keep noise for multiple simulations, i.e. do not recalculate/assign.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- direct assignment ---
flag.synNoiseKeep = get(fm.syn.noiseKeep,'Value');

%--- switch radiobutton ---
set(fm.syn.noiseKeep,'Value',flag.synNoiseKeep)

%--- update window ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate



end
