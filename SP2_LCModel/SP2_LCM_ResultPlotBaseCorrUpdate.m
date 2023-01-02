%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ResultPlotBaseCorrUpdate
%% 
%%  Switching on/off inclusion and consideration of polynomial baseline in the
%%  display of LCM results
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.lcmPlotBaseCorr = get(fm.lcm.plotBaseCorr,'Value');
set(fm.lcm.plotBaseCorr,'Value',flag.lcmPlotBaseCorr)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

