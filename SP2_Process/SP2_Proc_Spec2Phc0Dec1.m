%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2Phc0Dec1
%% 
%%  0.1deg decrease of zero order phase correction
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec2.phc0 = proc.spec2.phc0 - 0.1;
set(fm.proc.spec2Phc0Val,'String',sprintf('%.1f',proc.spec2.phc0))

%--- update value spec 1 ---
if flag.procSpec1Phc0 && flag.procSyncPhc0
    proc.spec1.phc0 = proc.spec1.phc0 - 0.1;
    set(fm.proc.spec1Phc0Val,'String',sprintf('%.1f',proc.spec1.phc0))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
