%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmOffsetMaxDecr
%% 
%%  0.1ppm decrease of maximum ppm offset window.
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc

%--- update window limit ---
proc.ppmOffsetMax = proc.ppmOffsetMax - 0.1;
set(fm.proc.ppmOffsetMax,'String',sprintf('%.2f',proc.ppmOffsetMax))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
