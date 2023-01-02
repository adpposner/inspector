%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1CutInc1
%% 
%%  1 point increased apodization of FID from spectrum 1.
%%
%%  12-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update cut-off value spec 1 ---
if mrsi.spec1.cut==1
    mrsi.spec1.cut = 16;
else
    mrsi.spec1.cut = mrsi.spec1.cut + 16;
end
set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))

%--- update cut-off value spec 2 ---
if flag.mrsiSpec2Cut && flag.mrsiSyncCut
    if mrsi.spec2.cut==1
        mrsi.spec2.cut = 16;
    else
        mrsi.spec2.cut = max(mrsi.spec2.cut + 16,1);
    end
    set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
