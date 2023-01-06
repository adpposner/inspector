%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1ZfUpdate
%% 
%%  Update time-domain zero-filling number of points for spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update ZF value ---
proc.spec1.zf = str2num(get(fm.proc.spec1ZfVal,'String'));
set(fm.proc.spec1ZfVal,'String',sprintf('%.0f',proc.spec1.zf))

%--- update value spec 2 ---
if flag.procSpec2Zf && flag.procSyncZf
    proc.spec2.zf = proc.spec1.zf;
    set(fm.proc.spec2ZfVal,'String',sprintf('%.0f',proc.spec2.zf))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
