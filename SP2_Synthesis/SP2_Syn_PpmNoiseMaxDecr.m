%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmNoiseMaxDecr
%% 
%%  0.1ppm increase of maximum ppm noise window.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm syn

%--- update window limit ---
syn.ppmNoiseMax = syn.ppmNoiseMax - 0.1;
set(fm.syn.ppmNoiseMax,'String',sprintf('%.2f',syn.ppmNoiseMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
