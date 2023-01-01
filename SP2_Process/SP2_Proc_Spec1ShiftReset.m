%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ShiftReset
%% 
%%  Reset frequency shift of spectrum 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.shift = 0;
set(fm.proc.spec1ShiftVal,'String',sprintf('%.3f',proc.spec1.shift))

%--- update value spec 2 ---
if flag.procSpec2Shift && flag.procSyncShift
    proc.spec2.shift = 0;
    set(fm.proc.spec2ShiftVal,'String',sprintf('%.3f',proc.spec2.shift))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
