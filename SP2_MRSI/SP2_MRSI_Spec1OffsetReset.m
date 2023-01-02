%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1OffsetReset
%% 
%%  Reset baseline offset of spectrum 1.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.offset = 1;      % note that the offset parameter refers to a scaling
set(fm.mrsi.spec1OffsetVal,'String',num2str(mrsi.spec1.offset))

%--- update value spec 2 ---
if flag.mrsiSpec2Offset && flag.mrsiSyncOffset
    mrsi.spec2.offset = 1;
    set(fm.mrsi.spec2OffsetVal,'String',num2str(mrsi.spec2.offset))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
