%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2StretchReset
%% 
%%  Reset spectral stretch of spectrum 2.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 2 ---
proc.spec2.stretch = 0;      % note that the offset parameter refers to a scaling
set(fm.proc.spec2StretchVal,'String',num2str(proc.spec2.stretch))

%--- update value spec 1 ---
if flag.procSpec1Stretch && flag.procSyncStretch
    proc.spec1.stretch = 0;
    set(fm.proc.spec1StretchVal,'String',num2str(proc.spec1.stretch))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
