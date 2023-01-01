%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1StretchInc1
%% 
%%  Increase of spectral stretch of spectrum 2 by 0.01.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.stretch = proc.spec1.stretch + 0.01;
set(fm.proc.spec1StretchVal,'String',num2str(proc.spec1.stretch))

%--- update value spec 2 ---
if flag.procSpec2Stretch && flag.procSyncStretch
    proc.spec2.stretch = proc.spec2.stretch + 0.01;
    set(fm.proc.spec2StretchVal,'String',num2str(proc.spec2.stretch))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
