%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_AmplShowMaxIncr
%% 
%%  10,000 [a.u.] amplitude increase.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss


%--- update window limit ---
marss.amplMax = marss.amplMax + 10000;
set(fm.marss.amplMax,'String',sprintf('%.0f',marss.amplMax))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate


