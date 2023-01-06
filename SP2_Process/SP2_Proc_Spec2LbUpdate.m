%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2LbUpdate
%% 
%%  Update line broadening for spectrum 2
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.lb = str2num(get(fm.proc.spec2LbVal,'String'));
set(fm.proc.spec2LbVal,'String',sprintf('%.2f',proc.spec2.lb))

%--- update value spec 1 ---
if flag.procSpec1Lb && flag.procSyncLb
    proc.spec1.lb = proc.spec2.lb;
    set(fm.proc.spec1LbVal,'String',sprintf('%.2f',proc.spec1.lb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
