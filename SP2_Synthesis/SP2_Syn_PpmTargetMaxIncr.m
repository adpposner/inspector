%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmTargetMaxIncr
%% 
%%  0.1ppm increase of maximum ppm target window.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn

%--- update window limit ---
syn.ppmTargetMax = syn.ppmTargetMax + 0.1;
set(fm.syn.ppmTargetMax,'String',sprintf('%.2f',syn.ppmTargetMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
