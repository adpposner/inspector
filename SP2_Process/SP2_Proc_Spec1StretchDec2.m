%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%0.%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1StretchDec2
%% 
%%  Decrease of spectral stretch of spectrum 1 by 0.1.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 1 ---
proc.spec1.stretch = proc.spec1.stretch - 0.1;
set(fm.proc.spec1StretchVal,'String',num2str(proc.spec1.stretch))

%--- update value spec 2 ---
if flag.procSpec2Stretch && flag.procSyncStretch
    proc.spec2.stretch = proc.spec2.stretch - 0.1;
    set(fm.proc.spec2StretchVal,'String',num2str(proc.spec2.stretch))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
