%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmShowFullUpdate
%% 
%%  Updates radiobutton setting: full sweep width visualization
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.procPpmShow = ~get(fm.proc.ppmShowFull,'Value');

%--- switch radiobutton ---
set(fm.proc.ppmShowFull,'Value',~flag.procPpmShow)
set(fm.proc.ppmShowDirect,'Value',flag.procPpmShow)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
