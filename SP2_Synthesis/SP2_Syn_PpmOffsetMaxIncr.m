%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmOffsetMaxIncr
%% 
%%  0.1ppm decrease of maximum ppm offset window.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn

%--- update window limit ---
syn.ppmOffsetMax = syn.ppmOffsetMax + 0.1;
set(fm.syn.ppmOffsetMax,'String',sprintf('%.2f',syn.ppmOffsetMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
