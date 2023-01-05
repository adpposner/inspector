%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2CutUpdate
%% 
%%  Update cut-off point of FID data apodization for spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.cut = str2num(get(fm.proc.spec2CutVal,'String'));
set(fm.proc.spec2CutVal,'String',sprintf('%.0f',proc.spec2.cut))

%--- update value spec 1 ---
if flag.procSpec1Cut && flag.procSyncCut
    proc.spec1.cut = proc.spec2.cut;
    set(fm.proc.spec1CutVal,'String',sprintf('%.0f',proc.spec1.cut))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
