%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmNoiseWinUpdate
%% 
%%  Update of noise frequency window.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- update ppm window ---
mrsi.ppmNoiseMin = str2num(get(fm.mrsi.ppmNoiseMin,'String'));
mrsi.ppmNoiseMax = str2num(get(fm.mrsi.ppmNoiseMax,'String'));
set(fm.mrsi.ppmNoiseMin,'String',sprintf('%.2f',mrsi.ppmNoiseMin))
set(fm.mrsi.ppmNoiseMax,'String',sprintf('%.2f',mrsi.ppmNoiseMax))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
