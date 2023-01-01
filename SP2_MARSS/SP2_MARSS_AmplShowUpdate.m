%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_AmplShowUpdate
%% 
%%  Update amplitude window
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- update amplitude window ---
marss.amplMin = str2num(get(fm.marss.amplMin,'String'));
marss.amplMax = str2num(get(fm.marss.amplMax,'String'));
set(fm.marss.amplMin,'String',sprintf('%.0f',marss.amplMin))
set(fm.marss.amplMax,'String',sprintf('%.0f',marss.amplMax))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate

