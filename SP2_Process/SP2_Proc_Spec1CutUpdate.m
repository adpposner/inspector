%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1CutUpdate
%% 
%%  Update cut-off point of FID data apodization for spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update cut-off value spec 1 ---
proc.spec1.cut = str2num(get(fm.proc.spec1CutVal,'String'));
set(fm.proc.spec1CutVal,'String',sprintf('%.0f',proc.spec1.cut))

%--- update cut-off value spec 2 ---
if flag.procSpec2Cut && flag.procSyncCut
    proc.spec2.cut = proc.spec1.cut;
    set(fm.proc.spec2CutVal,'String',sprintf('%.0f',proc.spec2.cut))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
