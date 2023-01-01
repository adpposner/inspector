%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2CutReset
%% 
%%  Reset apodization of FID from spectrum 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update percentage value ---
proc.spec2.cut = 1024;
set(fm.proc.spec2CutVal,'String',sprintf('%.0f',proc.spec2.cut))

%--- update value spec 1 ---
if flag.procSpec1Cut && flag.procSyncCut
    proc.spec1.cut = 1024;
    set(fm.proc.spec1CutVal,'String',sprintf('%.0f',proc.spec1.cut))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
