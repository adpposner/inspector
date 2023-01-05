%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmShowWinUpdate
%% 
%%  Update frequency window for visualization.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update ppm window ---
lcm.ppmShowMin = str2num(get(fm.lcm.ppmShowMin,'String'));
lcm.ppmShowMax = str2num(get(fm.lcm.ppmShowMax,'String'));
set(fm.lcm.ppmShowMin,'String',sprintf('%.2f',lcm.ppmShowMin))
set(fm.lcm.ppmShowMax,'String',sprintf('%.2f',lcm.ppmShowMax))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
