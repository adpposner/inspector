%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_OffsetPpmWinUpdate
%% 
%%  Update offset entries.
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi


%--- update amplitude window ---
mrsi.ppmOffsetMin = str2double(get(fm.mrsi.ppmOffsetMin,'String'));
mrsi.ppmOffsetMax = str2double(get(fm.mrsi.ppmOffsetMax,'String'));
set(fm.mrsi.ppmOffsetMin,'String',sprintf('%.2f',mrsi.ppmOffsetMin))
set(fm.mrsi.ppmOffsetMax,'String',sprintf('%.2f',mrsi.ppmOffsetMax))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
