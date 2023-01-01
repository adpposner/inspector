%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1CutReset
%% 
%%  Reset apodization of FID from spectrum 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.cut = 1024;
set(fm.proc.spec1CutVal,'String',sprintf('%.0f',proc.spec1.cut))

%--- update value spec 2 ---
if flag.procSpec2Cut && flag.procSyncCut
    proc.spec2.cut = 1024;
    set(fm.proc.spec2CutVal,'String',sprintf('%.0f',proc.spec2.cut))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
