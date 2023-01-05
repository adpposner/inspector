%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmTargetWinUpdate
%% 
%%  Update of target frequency window.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- update ppm window ---
mrsi.ppmTargetMin = str2num(get(fm.mrsi.ppmTargetMin,'String'));
mrsi.ppmTargetMax = str2num(get(fm.mrsi.ppmTargetMax,'String'));
set(fm.mrsi.ppmTargetMin,'String',sprintf('%.2f',mrsi.ppmTargetMin))
set(fm.mrsi.ppmTargetMax,'String',sprintf('%.2f',mrsi.ppmTargetMax))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
