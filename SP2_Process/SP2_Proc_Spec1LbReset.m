%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1LbReset
%% 
%%  Reset exponential line broadening.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag

%--- update percentage value spec 1 ---
proc.spec1.lb = 0;
set(fm.proc.spec1LbVal,'String',sprintf('%.2f',proc.spec1.lb))

%--- update percentage value spec 2 ---
if flag.procSpec2Lb && flag.procSyncLb
    proc.spec2.lb = 0;
    set(fm.proc.spec2LbVal,'String',sprintf('%.2f',proc.spec2.lb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
