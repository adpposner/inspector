%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ScaleUpdate
%% 
%%  Update of scaling factor for spectrum 1
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 1 ---
proc.spec1.scale = str2num(get(fm.proc.spec1ScaleVal,'String'));
set(fm.proc.spec1ScaleVal,'String',sprintf('%.3f',proc.spec1.scale))

%--- update value spec 2 ---
if flag.procSpec2Scale && flag.procSyncScale
    proc.spec2.scale = proc.spec1.scale;
    set(fm.proc.spec2ScaleVal,'String',sprintf('%.3f',proc.spec2.scale))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
