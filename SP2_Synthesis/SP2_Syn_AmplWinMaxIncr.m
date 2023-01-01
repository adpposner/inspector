%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_AmplWinMaxIncr
%% 
%%  10,000 [a.u.] amplitude increase.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- update window limit ---
syn.amplMax = syn.amplMax + 10000;
set(fm.syn.amplMax,'String',sprintf('%.0f',syn.amplMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate


