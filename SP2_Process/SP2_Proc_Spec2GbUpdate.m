%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2GbUpdate
%% 
%%  Update Gaussian line broadening for spectrum 2
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update percentage value ---
proc.spec2.gb = str2num(get(fm.proc.spec2GbVal,'String'));
set(fm.proc.spec2GbVal,'String',sprintf('%.2f',proc.spec2.gb))

%--- update value spec 1 ---
if flag.procSpec1Gb && flag.procSyncGb
    proc.spec1.gb = proc.spec2.gb;
    set(fm.proc.spec1GbVal,'String',sprintf('%.2f',proc.spec1.gb))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
