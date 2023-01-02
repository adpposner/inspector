%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmShowDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignment of (zoomed) ppm range
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.procPpmShow = get(fm.proc.ppmShowDirect,'Value');

%--- switch radiobutton ---
set(fm.proc.ppmShowFull,'Value',~flag.procPpmShow)
set(fm.proc.ppmShowDirect,'Value',flag.procPpmShow)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
