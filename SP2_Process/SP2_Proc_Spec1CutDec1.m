%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1CutDec1
%% 
%%  1 point reduced apodization of FID from spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update cut-off value spec 1 ---
proc.spec1.cut = max(proc.spec1.cut - 16,1);
set(fm.proc.spec1CutVal,'String',sprintf('%.0f',proc.spec1.cut))

%--- update cut-off value spec 2 ---
if flag.procSpec2Cut && flag.procSyncCut
    proc.spec2.cut = max(proc.spec2.cut - 16,1);
    set(fm.proc.spec2CutVal,'String',sprintf('%.0f',proc.spec2.cut))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
