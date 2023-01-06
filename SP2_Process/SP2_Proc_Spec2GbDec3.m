%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2GbDec3
%% 
%%  10Hz reduction of Gaussian line broadening.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update percentage value ---
proc.spec2.gb = proc.spec2.gb - 10;
set(fm.proc.spec2GbVal,'String',sprintf('%.2f',proc.spec2.gb))

%--- update value spec 1 ---
if flag.procSpec1Gb && flag.procSyncGb
    proc.spec1.gb = proc.spec1.gb - 10;
    set(fm.proc.spec1GbVal,'String',sprintf('%.2f',proc.spec1.gb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
