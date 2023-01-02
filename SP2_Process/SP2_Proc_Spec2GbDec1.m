%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2GbDec1
%% 
%%  0.1Hz reduction of Gaussian line broadening.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 2 ---
proc.spec2.gb = proc.spec2.gb - 0.1;
set(fm.proc.spec2GbVal,'String',sprintf('%.2f',proc.spec2.gb))

%--- update value spec 1 ---
if flag.procSpec1Gb && flag.procSyncGb
    proc.spec1.gb = proc.spec1.gb - 0.1;
    set(fm.proc.spec1GbVal,'String',sprintf('%.2f',proc.spec1.gb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
