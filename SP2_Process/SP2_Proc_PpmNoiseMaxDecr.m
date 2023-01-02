%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmNoiseMaxDecr
%% 
%%  0.1ppm increase of maximum ppm noise window.
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc

%--- update window limit ---
proc.ppmNoiseMax = proc.ppmNoiseMax - 0.1;
set(fm.proc.ppmNoiseMax,'String',sprintf('%.2f',proc.ppmNoiseMax))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
