%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ScaleReset
%% 
%%  Reset scaling of spectrum 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value ---
proc.spec1.scale = 1;
set(fm.proc.spec1ScaleVal,'String',sprintf('%.3f',proc.spec1.scale))

%--- update value spec 2 ---
if flag.procSpec2Scale && flag.procSyncScale
    proc.spec2.scale = 1;
    set(fm.proc.spec2ScaleVal,'String',sprintf('%.3f',proc.spec2.scale))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
