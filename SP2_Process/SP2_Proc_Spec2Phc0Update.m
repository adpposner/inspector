%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2Phc0Update
%% 
%%  Update of zero order phase correction value for spectrum 2
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.phc0 = str2num(get(fm.proc.spec2Phc0Val,'String'));
set(fm.proc.spec2Phc0Val,'String',sprintf('%.1f',proc.spec2.phc0))

%--- update value spec 1 ---
if flag.procSpec1Phc0 && flag.procSyncPhc0
    proc.spec1.phc0 = proc.spec2.phc0;
    set(fm.proc.spec1Phc0Val,'String',sprintf('%.1f',proc.spec1.phc0))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
