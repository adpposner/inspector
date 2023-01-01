%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1OffsetDec2
%% 
%%  Decrease of baseline offset of spectrum 1 by 1.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.offset = proc.spec1.offset - 1;
set(fm.proc.spec1OffsetVal,'String',num2str(proc.spec1.offset))

%--- update value spec 2 ---
if flag.procSpec2Offset && flag.procSyncOffset
    proc.spec2.offset = proc.spec2.offset - 1;
    set(fm.proc.spec2OffsetVal,'String',num2str(proc.spec2.offset))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
