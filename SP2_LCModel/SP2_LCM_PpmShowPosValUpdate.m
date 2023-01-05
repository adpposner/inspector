%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmShowPosValUpdate
%% 
%%  Update value for frequency visualization.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- update percentage value ---
lcm.ppmShowPos = str2num(get(fm.lcm.ppmShowPosVal,'String'));         % frequency update
lcm.ppmShowPosMirr = lcm.ppmCalib+(lcm.ppmCalib-lcm.ppmShowPos);    % mirrored frequency position

%--- display update ---
set(fm.lcm.ppmShowPosVal,'String',num2str(lcm.ppmShowPos))

%--- info printout ---
if isfield(lcm,'sf')
    fprintf('Frequency position:\n%.3fppm - %.3fppm = %.3fppm/%.2fHz\n',lcm.ppmShowPos,...
            lcm.ppmCalib,lcm.ppmShowPos-lcm.ppmCalib,lcm.sf*(lcm.ppmShowPos-lcm.ppmCalib))
end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate