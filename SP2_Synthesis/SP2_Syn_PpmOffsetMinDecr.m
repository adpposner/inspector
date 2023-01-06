%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmOffsetMinDecr
%% 
%%  0.1ppm decrease of minimum ppm offset window.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn

%--- update window limit ---
syn.ppmOffsetMin = syn.ppmOffsetMin - 0.1;
set(fm.syn.ppmOffsetMin,'String',sprintf('%.2f',syn.ppmOffsetMin))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
