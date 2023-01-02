%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2ZfUpdate
%% 
%%  Update time-domain zero-filling number of points for spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update value spec 2 ---
proc.spec2.zf = str2num(get(fm.proc.spec2ZfVal,'String'));
set(fm.proc.spec2ZfVal,'String',sprintf('%.0f',proc.spec2.zf))

%--- update value spec 1 ---
if flag.procSpec1Zf && flag.procSyncZf
    proc.spec1.zf = proc.spec2.zf;
    set(fm.proc.spec1ZfVal,'String',sprintf('%.0f',proc.spec1.zf))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
