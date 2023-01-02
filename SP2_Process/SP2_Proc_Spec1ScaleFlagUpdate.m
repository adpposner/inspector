%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ScaleFlagUpdate
%% 
%%  Switching on/off amplitude scaling for spectrum 1
%%
%%  09-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.procSpec1Scale = get(fm.proc.spec1ScaleFlag,'Value');
set(fm.proc.spec1ScaleFlag,'Value',flag.procSpec1Scale)

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
