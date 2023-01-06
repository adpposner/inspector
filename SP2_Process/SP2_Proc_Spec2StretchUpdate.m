%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2StretchUpdate
%% 
%%  Update of spectral stretch for spectrum 2.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.stretch = str2num(get(fm.proc.spec2StretchVal,'String'));
set(fm.proc.spec2StretchVal,'String',num2str(proc.spec2.stretch))

%--- update value spec 1 ---
if flag.procSpec1Stretch && flag.procSyncStretch
    proc.spec1.stretch = proc.spec2.stretch;
    set(fm.proc.spec1StretchVal,'String',num2str(proc.spec1.stretch))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
