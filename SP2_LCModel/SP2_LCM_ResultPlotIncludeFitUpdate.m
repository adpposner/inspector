%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ResultPlotIncludeFitUpdate
%% 
%%  Switching on/off display of total fit sum in single/superposition 
%%  display of LCM results
%%
%%  03-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmPlotInclFit = get(fm.lcm.plotInclFit,'Value');
set(fm.lcm.plotInclFit,'Value',flag.lcmPlotInclFit)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

