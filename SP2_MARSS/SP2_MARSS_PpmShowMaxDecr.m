%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_PpmShowMaxDecr
%% 
%%  0.1 ppm decrease of maximum ppm frequency window.
%%
%%  02-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss

%--- update window limit ---
marss.ppmShowMax = marss.ppmShowMax - 0.1;
set(fm.marss.ppmShowMax,'String',sprintf('%.2f',marss.ppmShowMax))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
