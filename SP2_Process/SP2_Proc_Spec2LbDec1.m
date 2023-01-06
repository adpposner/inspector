%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2LbDec1
%% 
%%  0.1Hz reduction of exponential line broadenin.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.lb = proc.spec2.lb - 0.1;
set(fm.proc.spec2LbVal,'String',sprintf('%.2f',proc.spec2.lb))

%--- update value spec 1 ---
if flag.procSpec1Lb && flag.procSyncLb
    proc.spec1.lb = proc.spec1.lb - 0.1;
    set(fm.proc.spec1LbVal,'String',sprintf('%.2f',proc.spec1.lb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
