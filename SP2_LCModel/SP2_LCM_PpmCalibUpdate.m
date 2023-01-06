%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmCalibUpdate
%% 
%%  Update frequency calibration
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm flag


%--- update percentage value ---
lcm.ppmCalib = str2num(get(fm.lcm.ppmCalib,'String'));
set(fm.lcm.ppmCalib,'String',num2str(lcm.ppmCalib))

%--- ppm position update ---
if flag.lcmPpmShowPos
    SP2_LCM_PpmShowPosValUpdate
end

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

end
