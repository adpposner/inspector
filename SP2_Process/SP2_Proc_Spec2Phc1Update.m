%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2Phc1Update
%% 
%%  Update of first order phase correction value for spectrum 2
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 2 ---
proc.spec2.phc1 = str2num(get(fm.proc.spec2Phc1Val,'String'));
set(fm.proc.spec2Phc1Val,'String',sprintf('%.1f',proc.spec2.phc1))

%--- update value spec 1 ---
if flag.procSpec1Phc1 && flag.procSyncPhc1
    proc.spec1.phc1 = proc.spec2.phc1;
    set(fm.proc.spec1Phc1Val,'String',sprintf('%.1f',proc.spec1.phc1))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate