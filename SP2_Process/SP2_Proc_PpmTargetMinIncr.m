%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmTargetMinIncr
%% 
%%  0.1ppm increase of minimum ppm target window.
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc

%--- update window limit ---
proc.ppmTargetMin = proc.ppmTargetMin + 0.1;
set(fm.proc.ppmTargetMin,'String',sprintf('%.2f',proc.ppmTargetMin))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
