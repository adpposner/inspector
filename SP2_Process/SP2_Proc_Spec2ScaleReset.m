%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ScaleReset
%% 
%%  Reset scaling of spectrum 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.scale = 1;
set(fm.proc.spec2ScaleVal,'String',sprintf('%.3f',proc.spec2.scale))

%--- update value spec 1 ---
if flag.procSpec1Scale && flag.procSyncScale
    proc.spec1.scale = 1;
    set(fm.proc.spec1ScaleVal,'String',sprintf('%.3f',proc.spec1.scale))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
