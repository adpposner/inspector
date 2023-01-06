%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1StretchDec3
%% 
%%  Decrease of spectral stretch of spectrum 1 by 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag

%--- update value spec 1 ---
proc.spec1.stretch = proc.spec1.stretch - 1;
set(fm.proc.spec1StretchVal,'String',num2str(proc.spec1.stretch))

%--- update value spec 2 ---
if flag.procSpec2Stretch && flag.procSyncStretch
    proc.spec2.stretch = proc.spec2.stretch - 1;
    set(fm.proc.spec2StretchVal,'String',num2str(proc.spec2.stretch))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
