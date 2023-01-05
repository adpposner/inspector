%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ShiftDec1
%% 
%%  0.1Hz decreased shift of spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.shift = proc.spec2.shift - 0.001;
set(fm.proc.spec2ShiftVal,'String',sprintf('%.3f',proc.spec2.shift))

%--- update value spec 1 ---
if flag.procSpec1Shift && flag.procSyncShift
    proc.spec1.shift = proc.spec1.shift - 0.001;
    set(fm.proc.spec1ShiftVal,'String',sprintf('%.3f',proc.spec1.shift))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
