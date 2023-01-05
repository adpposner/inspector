%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_PpmNoiseWinUpdate
%% 
%%  Update of noise frequency window.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm syn


%--- update ppm window ---
syn.ppmNoiseMin = str2num(get(fm.syn.ppmNoiseMin,'String'));
syn.ppmNoiseMax = str2num(get(fm.syn.ppmNoiseMax,'String'));
set(fm.syn.ppmNoiseMin,'String',sprintf('%.2f',syn.ppmNoiseMin))
set(fm.syn.ppmNoiseMax,'String',sprintf('%.2f',syn.ppmNoiseMax))

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- analysis update ---
SP2_Syn_ProcAndPlotUpdate
