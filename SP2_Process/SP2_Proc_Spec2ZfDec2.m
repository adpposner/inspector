%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ZfDec2
%% 
%%  100 point reduction of ZF for spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 2 ---
proc.spec2.zf = max(proc.spec2.zf - 128,1);
set(fm.proc.spec2ZfVal,'String',sprintf('%.0f',proc.spec2.zf))

%--- update value spec 1 ---
if flag.procSpec1Zf && flag.procSyncZf
    proc.spec1.zf = max(proc.spec1.zf - 128,1);
    set(fm.proc.spec1ZfVal,'String',sprintf('%.0f',proc.spec1.zf))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
