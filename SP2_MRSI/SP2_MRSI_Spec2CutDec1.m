%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2CutDec1
%% 
%%  1 point reduced apodization of FID from spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.cut = max(mrsi.spec2.cut - 16,1);
set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))

%--- update value spec 1 ---
if flag.mrsiSpec1Cut && flag.mrsiSyncCut
    mrsi.spec1.cut = max(mrsi.spec1.cut - 16,1);
    set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
