%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1Phc0Update
%% 
%%  Update of zero order phase correction value for spectrum 1
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 1 ---
proc.spec1.phc0 = str2num(get(fm.proc.spec1Phc0Val,'String'));
set(fm.proc.spec1Phc0Val,'String',sprintf('%.1f',proc.spec1.phc0))

%--- update value spec 2 ---
if flag.procSpec2Phc0 && flag.procSyncPhc0
    proc.spec2.phc0 = proc.spec1.phc0;
    set(fm.proc.spec2Phc0Val,'String',sprintf('%.1f',proc.spec2.phc0))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
