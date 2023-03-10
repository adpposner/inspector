%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_AmplShowAutoUpdate
%% 
%%  Updates radiobutton setting: automatic determination of reasonable
%%  amplitude limits
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.synAmplShow = ~get(fm.syn.amplShowAuto,'Value');

%--- switch radiobutton ---
set(fm.syn.amplShowAuto,'Value',~flag.synAmplShow)
set(fm.syn.amplShowDirect,'Value',flag.synAmplShow)

%--- update window ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate



end
