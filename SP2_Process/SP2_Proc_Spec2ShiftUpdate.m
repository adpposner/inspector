%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ShiftUpdate
%% 
%%  Update line frequency shift [Hz] for spectrum 2
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.shift = str2num(get(fm.proc.spec2ShiftVal,'String'));
set(fm.proc.spec2ShiftVal,'String',sprintf('%.3f',proc.spec2.shift))

%--- update value spec 1 ---
if flag.procSpec1Shift && flag.procSyncShift
    proc.spec1.shift = proc.spec2.shift;
    set(fm.proc.spec1ShiftVal,'String',sprintf('%.3f',proc.spec1.shift))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
