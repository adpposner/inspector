%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1GbInc3
%% 
%%  10Hz increase of Gaussian line broadening.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag

%--- update percentage value spec 1 ---
proc.spec1.gb = proc.spec1.gb + 10;
set(fm.proc.spec1GbVal,'String',sprintf('%.2f',proc.spec1.gb))

%--- update percentage value spec 2 ---
if flag.procSpec2Gb && flag.procSyncGb
    proc.spec2.gb = proc.spec2.gb + 10;
    set(fm.proc.spec2GbVal,'String',sprintf('%.2f',proc.spec2.gb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
