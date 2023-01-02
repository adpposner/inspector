%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaFwhmUpdate
%% 
%%  Switching on/off FWHM analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.lcmAnaFWHM = get(fm.lcm.anaFWHM,'Value');

%--- window update ---
set(fm.lcm.anaFWHM,'Value',flag.lcmAnaFWHM)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
