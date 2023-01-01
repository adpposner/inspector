%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ScaleDec3
%% 
%%  0.1 reduced scaling of spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.scale = proc.spec1.scale - 0.1;
set(fm.proc.spec1ScaleVal,'String',sprintf('%.3f',proc.spec1.scale))

%--- update value spec 2 ---
if flag.procSpec2Scale && flag.procSyncScale
    proc.spec2.scale = proc.spec2.scale - 0.1;
    set(fm.proc.spec2ScaleVal,'String',sprintf('%.3f',proc.spec2.scale))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
