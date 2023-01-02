%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ScaleInc1
%% 
%%  0.001 increased scaling of spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update percentage value ---
proc.spec2.scale = proc.spec2.scale + 0.001;
set(fm.proc.spec2ScaleVal,'String',sprintf('%.3f',proc.spec2.scale))

%--- update value spec 1 ---
if flag.procSpec1Scale && flag.procSyncScale
    proc.spec1.scale = proc.spec1.scale + 0.001;
    set(fm.proc.spec1ScaleVal,'String',sprintf('%.3f',proc.spec1.scale))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
