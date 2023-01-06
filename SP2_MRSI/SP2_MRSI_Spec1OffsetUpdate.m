%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1OffsetUpdate
%% 
%%  Update of baseline offset for spectrum 1.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.offset = str2num(get(fm.mrsi.spec1OffsetVal,'String'));
set(fm.mrsi.spec1OffsetVal,'String',num2str(mrsi.spec1.offset))

%--- update value spec 2 ---
if flag.mrsiSpec2Offset && flag.mrsiSyncOffset
    mrsi.spec2.offset = mrsi.spec1.offset;
    set(fm.mrsi.spec2OffsetVal,'String',num2str(mrsi.spec2.offset))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
