%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmTargetMinIncr
%% 
%%  0.1ppm increase of minimum ppm target window.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn

%--- update window limit ---
syn.ppmTargetMin = syn.ppmTargetMin + 0.1;
set(fm.syn.ppmTargetMin,'String',sprintf('%.2f',syn.ppmTargetMin))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
