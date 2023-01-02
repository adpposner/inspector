%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PlotLineWidthUpdate
%% 
%%  Update line width of spectral displays.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- retrieve value ---
lcm.lineWidth = str2double(get(fm.lcm.plotLineWidth,'String'));

%--- consistency check ---
lcm.lineWidth = max(min(lcm.lineWidth,10),0.1);

%--- window update ---
set(fm.lcm.plotLineWidth,'String',num2str(lcm.lineWidth));

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
