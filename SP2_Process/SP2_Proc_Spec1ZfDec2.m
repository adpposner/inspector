%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ZfDec2
%% 
%%  100 point reduction of ZF for spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.zf = max(proc.spec1.zf - 128,1);
set(fm.proc.spec1ZfVal,'String',sprintf('%.0f',proc.spec1.zf))

%--- update value spec 2 ---
if flag.procSpec2Zf && flag.procSyncZf
    proc.spec2.zf = max(proc.spec2.zf - 128,1);
    set(fm.proc.spec2ZfVal,'String',sprintf('%.0f',proc.spec2.zf))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
