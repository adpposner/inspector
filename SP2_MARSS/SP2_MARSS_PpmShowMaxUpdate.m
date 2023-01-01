%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_PpmShowMaxUpdate
%% 
%%  Update maximum ppm frequency to display.
%%
%%  11-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss

%--- maximum amplitude ---
marss.ppmShowMax = str2num(get(fm.marss.ppmShowMax,'String'));
if isempty(marss.ppmShowMax)
    marss.ppmShowMax = 5;
end
marss.ppmShowMax = max(marss.ppmShowMin(1),marss.ppmShowMax);
set(fm.marss.ppmShowMax,'String',sprintf('%.2f',marss.ppmShowMax))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
