%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2OffsetInc3
%% 
%%  Increase of baseline offset of spectrum 2 by 10.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update percentage value ---
mrsi.spec2.offset = mrsi.spec2.offset + 10;
set(fm.mrsi.spec2OffsetVal,'String',num2str(mrsi.spec2.offset))

%--- update value spec 1 ---
if flag.mrsiSpec1Offset && flag.mrsiSyncOffset
    mrsi.spec1.offset = mrsi.spec1.offset + 10;
    set(fm.mrsi.spec1OffsetVal,'String',num2str(mrsi.spec1.offset))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
