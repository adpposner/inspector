%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1CutDec2
%% 
%%  10 point reduced apodization of FID from spectrum 1.
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update cut-off value spec 1 ---
mrsi.spec1.cut = max(mrsi.spec1.cut - 64,1);
set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))

%--- update cut-off value spec 2 ---
if flag.mrsiSpec2Cut && flag.mrsiSyncCut
    mrsi.spec2.cut = max(mrsi.spec2.cut - 64,1);
    set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
