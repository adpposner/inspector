%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1Phc1Reset
%% 
%%  Reset first order phase correction
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.phc1 = 0;
set(fm.proc.spec1Phc1Val,'String',sprintf('%.1f',proc.spec1.phc1))

%--- update value spec 2 ---
if flag.procSpec2Phc1 && flag.procSyncPhc1
    proc.spec2.phc1 = 0;
    set(fm.proc.spec2Phc1Val,'String',sprintf('%.1f',proc.spec2.phc1))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
