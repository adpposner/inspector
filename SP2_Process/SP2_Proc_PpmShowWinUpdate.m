%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmShowWinUpdate
%% 
%%  Update frequency window for visualization.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- update ppm window ---
proc.ppmShowMin = str2num(get(fm.proc.ppmShowMin,'String'));
proc.ppmShowMax = str2num(get(fm.proc.ppmShowMax,'String'));
set(fm.proc.ppmShowMin,'String',sprintf('%.2f',proc.ppmShowMin))
set(fm.proc.ppmShowMax,'String',sprintf('%.2f',proc.ppmShowMax))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
