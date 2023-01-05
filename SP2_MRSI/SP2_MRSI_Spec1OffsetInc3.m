%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1OffsetInc3
%% 
%%  Increase of baseline offset of spectrum 1 by 10.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.offset = mrsi.spec1.offset + 10;
set(fm.mrsi.spec1OffsetVal,'String',num2str(mrsi.spec1.offset))

%--- update value spec 2 ---
if flag.mrsiSpec2Offset && flag.mrsiSyncOffset
    mrsi.spec2.offset = mrsi.spec2.offset + 10;
    set(fm.mrsi.spec2OffsetVal,'String',num2str(mrsi.spec2.offset))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
