%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_PpmShowMinUpdate
%% 
%%  Update minimum ppm frequency to display.
%%
%%  11-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss

%--- minimum amplitude ---
marss.ppmShowMin = str2num(get(fm.marss.ppmShowMin,'String'));
if isempty(marss.ppmShowMin)
    marss.ppmShowMin = 0;
end
marss.ppmShowMin = min(marss.ppmShowMin,marss.ppmShowMax(1));
set(fm.marss.ppmShowMin,'String',sprintf('%.2f',marss.ppmShowMin))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
