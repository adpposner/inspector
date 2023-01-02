%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PlotFidFlagUpdate
%% 
%%  Switching on/off FID visualization
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.procPlotFid = get(fm.proc.plotFidFlag,'Value');
set(fm.proc.plotFidFlag,'Value',flag.procPlotFid)

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
