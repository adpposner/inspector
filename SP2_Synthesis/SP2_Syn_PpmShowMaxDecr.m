%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmShowMaxDecr
%% 
%%  0.1ppm decrease of maximum ppm frequency window.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn

%--- update window limit ---
syn.ppmShowMax = syn.ppmShowMax - 0.1;
set(fm.syn.ppmShowMax,'String',sprintf('%.2f',syn.ppmShowMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
