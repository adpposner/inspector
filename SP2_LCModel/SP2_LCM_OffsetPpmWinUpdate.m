%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_OffsetPpmWinUpdate
%% 
%%  Update offset entries.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update amplitude window ---
lcm.ppmOffsetMin = str2double(get(fm.lcm.ppmOffsetMin,'String'));
lcm.ppmOffsetMax = str2double(get(fm.lcm.ppmOffsetMax,'String'));
set(fm.lcm.ppmOffsetMin,'String',sprintf('%.2f',lcm.ppmOffsetMin))
set(fm.lcm.ppmOffsetMax,'String',sprintf('%.2f',lcm.ppmOffsetMax))

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
