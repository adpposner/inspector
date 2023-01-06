%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmNoiseWinUpdate
%% 
%%  Update of target frequency window.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update ppm window ---
lcm.ppmNoiseMin = str2num(get(fm.lcm.ppmNoiseMin,'String'));
lcm.ppmNoiseMax = str2num(get(fm.lcm.ppmNoiseMax,'String'));
set(fm.lcm.ppmNoiseMin,'String',sprintf('%.2f',lcm.ppmNoiseMin))
set(fm.lcm.ppmNoiseMax,'String',sprintf('%.2f',lcm.ppmNoiseMax))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
