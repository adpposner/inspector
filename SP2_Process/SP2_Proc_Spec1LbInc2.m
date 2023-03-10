%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1LbInc2
%% 
%%  1Hz reduction of exponential line broadening.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag

%--- update percentage value spec 1 ---
proc.spec1.lb = proc.spec1.lb + 1;
set(fm.proc.spec1LbVal,'String',sprintf('%.2f',proc.spec1.lb))

%--- update percentage value spec 2 ---
if flag.procSpec2Lb && flag.procSyncLb
    proc.spec2.lb = proc.spec2.lb + 1;
    set(fm.proc.spec2LbVal,'String',sprintf('%.2f',proc.spec2.lb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
