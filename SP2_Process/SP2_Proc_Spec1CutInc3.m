%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1CutInc3
%% 
%%  100 point increased apodization of FID from spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update cut-off value spec 1 ---
if proc.spec1.cut==1
    proc.spec1.cut = 256;
else
    proc.spec1.cut = proc.spec1.cut + 256;
end
set(fm.proc.spec1CutVal,'String',sprintf('%.0f',proc.spec1.cut))

%--- update cut-off value spec 2 ---
if flag.procSpec2Cut && flag.procSyncCut
    if proc.spec2.cut==1
        proc.spec2.cut = 256;
    else
        proc.spec2.cut = max(proc.spec2.cut + 256,1);
    end
    set(fm.proc.spec2CutVal,'String',sprintf('%.0f',proc.spec2.cut))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
