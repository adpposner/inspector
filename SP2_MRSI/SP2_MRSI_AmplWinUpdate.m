%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_AmplWinUpdate
%% 
%%  Update amplitude window
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi


%--- update amplitude window ---
mrsi.amplMin = str2num(get(fm.mrsi.amplMin,'String'));
mrsi.amplMax = str2num(get(fm.mrsi.amplMax,'String'));
set(fm.mrsi.amplMin,'String',sprintf('%.0f',mrsi.amplMin))
set(fm.mrsi.amplMax,'String',sprintf('%.0f',mrsi.amplMax))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
