%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ZfInc2
%% 
%%  100 point increase of ZF for spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update percentage value ---
proc.spec1.zf = proc.spec1.zf + 128;
set(fm.proc.spec1ZfVal,'String',sprintf('%.0f',proc.spec1.zf))

%--- update value spec 2 ---
if flag.procSpec2Zf && flag.procSyncZf
    proc.spec2.zf = proc.spec2.zf + 128;
    set(fm.proc.spec2ZfVal,'String',sprintf('%.0f',proc.spec2.zf))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
