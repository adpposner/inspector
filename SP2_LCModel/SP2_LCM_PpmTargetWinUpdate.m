%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmTargetWinUpdate
%% 
%%  Update of target frequency window.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update ppm window ---
lcm.ppmTargetMin = str2num(get(fm.lcm.ppmTargetMin,'String'));
lcm.ppmTargetMax = str2num(get(fm.lcm.ppmTargetMax,'String'));
set(fm.lcm.ppmTargetMin,'String',sprintf('%.2f',lcm.ppmTargetMin))
set(fm.lcm.ppmTargetMax,'String',sprintf('%.2f',lcm.ppmTargetMax))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
