%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmShowPosFlagUpdate
%% 
%%  Enable/disable visualization of frequency position as vertical line.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag lcm


%--- parameter update ---
flag.lcmPpmShowPos = get(fm.lcm.ppmShowPos,'Value');

%--- window update ---
set(fm.lcm.ppmShowPos,'Value',flag.lcmPpmShowPos)

%--- info printout ---
if flag.lcmPpmShowPos && isfield(lcm,'sf')
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

