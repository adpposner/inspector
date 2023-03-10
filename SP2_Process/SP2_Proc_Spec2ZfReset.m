%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ZfReset
%% 
%%  Reset ZF for spectrum 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.zf = 16384;
set(fm.proc.spec2ZfVal,'String',sprintf('%.0f',proc.spec2.zf))

%--- update value spec 1 ---
if flag.procSpec1Zf && flag.procSyncZf
    proc.spec1.zf = 16384;
    set(fm.proc.spec1ZfVal,'String',sprintf('%.0f',proc.spec1.zf))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
