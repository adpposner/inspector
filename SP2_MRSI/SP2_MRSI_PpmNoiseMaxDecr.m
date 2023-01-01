%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmNoiseMaxDecr
%% 
%%  0.1ppm increase of maximum ppm noise window.
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi

%--- update window limit ---
mrsi.ppmNoiseMax = mrsi.ppmNoiseMax - 0.1;
set(fm.mrsi.ppmNoiseMax,'String',sprintf('%.2f',mrsi.ppmNoiseMax))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
