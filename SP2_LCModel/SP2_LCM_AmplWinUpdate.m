%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AmplWinUpdate
%% 
%%  Update amplitude window
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update amplitude window ---
lcm.amplMin = str2num(get(fm.lcm.amplMin,'String'));
lcm.amplMax = str2num(get(fm.lcm.amplMax,'String'));
set(fm.lcm.amplMin,'String',sprintf('%.0f',lcm.amplMin))
set(fm.lcm.amplMax,'String',sprintf('%.0f',lcm.amplMax))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
