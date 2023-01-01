%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2CutInc1
%% 
%%  1 point increased apodization of FID from spectrum 2.
%%
%%  12-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
if proc.spec2.cut==1
    proc.spec2.cut = 16;
else
    proc.spec2.cut = proc.spec2.cut + 16;
end
set(fm.proc.spec2CutVal,'String',sprintf('%.0f',proc.spec2.cut))

%--- update value spec 1 ---
if flag.procSpec1Cut && flag.procSyncCut
    if proc.spec1.cut==1
        proc.spec1.cut = 16;
    else
        proc.spec1.cut = proc.spec1.cut + 16;
    end
    set(fm.proc.spec1CutVal,'String',sprintf('%.0f',proc.spec1.cut))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
