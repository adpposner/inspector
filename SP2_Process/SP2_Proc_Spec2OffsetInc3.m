%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec2OffsetInc3
%% 
%%  Increase of baseline offset of spectrum 2 by 10.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag


%--- update percentage value ---
proc.spec2.offset = proc.spec2.offset + 10;
set(fm.proc.spec2OffsetVal,'String',num2str(proc.spec2.offset))

%--- update value spec 1 ---
if flag.procSpec1Offset && flag.procSyncOffset
    proc.spec1.offset = proc.spec1.offset + 10;
    set(fm.proc.spec1OffsetVal,'String',num2str(proc.spec1.offset))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
