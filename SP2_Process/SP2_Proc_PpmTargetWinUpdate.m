%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmTargetWinUpdate
%% 
%%  Update of target frequency window.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- update ppm window ---
proc.ppmTargetMin = str2num(get(fm.proc.ppmTargetMin,'String'));
proc.ppmTargetMax = str2num(get(fm.proc.ppmTargetMax,'String'));
set(fm.proc.ppmTargetMin,'String',sprintf('%.2f',proc.ppmTargetMin))
set(fm.proc.ppmTargetMax,'String',sprintf('%.2f',proc.ppmTargetMax))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
