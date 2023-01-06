%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1OffsetUpdate
%% 
%%  Update of baseline offset for spectrum 1.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag


%--- update value spec 1 ---
proc.spec1.offset = str2num(get(fm.proc.spec1OffsetVal,'String'));
set(fm.proc.spec1OffsetVal,'String',num2str(proc.spec1.offset))

%--- update value spec 2 ---
if flag.procSpec2Offset && flag.procSyncOffset
    proc.spec2.offset = proc.spec1.offset;
    set(fm.proc.spec2OffsetVal,'String',num2str(proc.spec2.offset))
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
