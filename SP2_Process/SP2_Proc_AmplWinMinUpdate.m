%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AmplWinMinUpdate
%% 
%%  Update amplitude window: minimum
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc


%--- update amplitude window ---
proc.amplMin = str2num(get(fm.proc.amplMin,'String'));
set(fm.proc.amplMin,'String',sprintf('%.0f',proc.amplMin))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
