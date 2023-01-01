%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_PpmShowMinDecr
%% 
%%  0.1 ppm decrease of minimum ppm frequency window.
%%
%%  02-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss

%--- update window limit ---
marss.ppmShowMin = marss.ppmShowMin - 0.1;
set(fm.marss.ppmShowMin,'String',sprintf('%.2f',marss.ppmShowMin))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
