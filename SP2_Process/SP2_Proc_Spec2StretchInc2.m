%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2StretchInc2
%% 
%%  Increase of spectral stretch of spectrum 2 by 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.stretch = proc.spec2.stretch + 0.1;
set(fm.proc.spec2StretchVal,'String',num2str(proc.spec2.stretch))

%--- update value spec 1 ---
if flag.procSpec1Stretch && flag.procSyncStretch
    proc.spec1.stretch = proc.spec1.stretch + 0.1;
    set(fm.proc.spec1StretchVal,'String',num2str(proc.spec1.stretch))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
