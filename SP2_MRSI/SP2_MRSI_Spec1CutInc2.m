%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1CutInc2
%% 
%%  10 point increased apodization of FID from spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update cut-off value spec 1 ---
if mrsi.spec1.cut==1
    mrsi.spec1.cut = 64;
else
    mrsi.spec1.cut = mrsi.spec1.cut + 64;
end
set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))

%--- update cut-off value spec 2 ---
if flag.mrsiSpec2Cut && flag.mrsiSyncCut
    if mrsi.spec2.cut==1
        mrsi.spec2.cut = 64;
    else
        mrsi.spec2.cut = max(mrsi.spec2.cut + 64,1);
    end
    set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
