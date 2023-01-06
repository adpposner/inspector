%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_AmplWinMinIncr
%% 
%%  10,000 [a.u.] amplitude increase.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- update window limit ---
syn.amplMin = syn.amplMin + 10000;
set(fm.syn.amplMin,'String',sprintf('%.0f',syn.amplMin))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate



end
