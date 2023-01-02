%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmShowMinIncr
%% 
%%  0.1ppm increase of minimum ppm frequency window.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm

%--- update window limit ---
lcm.ppmShowMin = lcm.ppmShowMin + 0.1;
set(fm.lcm.ppmShowMin,'String',sprintf('%.2f',lcm.ppmShowMin))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
