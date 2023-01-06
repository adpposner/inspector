%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2OffsetUpdate
%% 
%%  Update of baseline offset for spectrum 2.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.offset = str2num(get(fm.mrsi.spec2OffsetVal,'String'));
set(fm.mrsi.spec2OffsetVal,'String',num2str(mrsi.spec2.offset))

%--- update value spec 1 ---
if flag.mrsiSpec1Offset && flag.mrsiSyncOffset
    mrsi.spec1.offset = mrsi.spec2.offset;
    set(fm.mrsi.spec1OffsetVal,'String',num2str(mrsi.spec1.offset))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
