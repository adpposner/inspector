%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1GbReset
%% 
%%  Reset Gaussian line broadening.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag

%--- update percentage value spec 1 ---
proc.spec1.gb = 0;
set(fm.proc.spec1GbVal,'String',sprintf('%.2f',proc.spec1.gb))

%--- update percentage value spec 2 ---
if flag.procSpec2Gb && flag.procSyncGb
    proc.spec2.gb = 0;
    set(fm.proc.spec2GbVal,'String',sprintf('%.2f',proc.spec2.gb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
