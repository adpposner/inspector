%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AnaAbsOfRealUpdate
%% 
%%  Switching on/off magnitude of real part for analysis.
%%
%%  05-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.procAnaAbsOfReal = get(fm.proc.anaAbsOfReal,'Value');

%--- window update ---
set(fm.proc.anaAbsOfReal,'Value',flag.procAnaAbsOfReal)

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
