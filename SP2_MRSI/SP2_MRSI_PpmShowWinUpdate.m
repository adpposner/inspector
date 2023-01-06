%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmShowWinUpdate
%% 
%%  Update frequency window for visualization.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- update ppm window ---
mrsi.ppmShowMin = str2num(get(fm.mrsi.ppmShowMin,'String'));
mrsi.ppmShowMax = str2num(get(fm.mrsi.ppmShowMax,'String'));
set(fm.mrsi.ppmShowMin,'String',sprintf('%.2f',mrsi.ppmShowMin))
set(fm.mrsi.ppmShowMax,'String',sprintf('%.2f',mrsi.ppmShowMax))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
