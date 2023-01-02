%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AnaIntegralUpdate
%% 
%%  Switching on/off integral analysis.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.procAnaIntegr = get(fm.proc.anaIntegr,'Value');

%--- window update ---
set(fm.proc.anaIntegr,'Value',flag.procAnaIntegr)

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
