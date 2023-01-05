%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_ResultPlotIncludeResidUpdate
%% 
%%  Switching on/off display of fit residual in single/superposition 
%%  display of LCM results
%%
%%  03-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmPlotInclResid = get(fm.lcm.plotInclResid,'Value');
set(fm.lcm.plotInclResid,'Value',flag.lcmPlotInclResid)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

