%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmAssignFromProc
%%
%%  Assign ppm value to value from Processing page.
%% 
%%  08-2016, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag proc

FCTNAME = 'SP2_LCM_PpmAssignFromProc';


%--- ppm assignment ---
lcm.ppmCalib = proc.ppmCalib;

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
SP2_LCM_FitFigureUpdate




