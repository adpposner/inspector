%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_OffsetPpmWinFlagUpdate
%% 
%%  Updates radiobutton setting: baseline offset mode
%%  1: mean of ppm range
%%  0: direct assignment of offset value
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- retrieve parameter ---
flag.procOffset = get(fm.proc.offsetPpmFlag,'Value');

%--- switch radiobutton ---
set(fm.proc.offsetPpmFlag,'Value',flag.procOffset)
set(fm.proc.offsetValFlag,'Value',~flag.procOffset)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
