%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1Phc1Inc1
%% 
%%  0.1deg increase of first order phase correction
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 1 ---
proc.spec1.phc1 = proc.spec1.phc1 + 0.1;
set(fm.proc.spec1Phc1Val,'String',sprintf('%.1f',proc.spec1.phc1))

%--- update value spec 2 ---
if flag.procSpec2Phc1 && flag.procSyncPhc1
    proc.spec2.phc1 = proc.spec2.phc1 + 0.1;
    set(fm.proc.spec2Phc1Val,'String',sprintf('%.1f',proc.spec2.phc1))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
