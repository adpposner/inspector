%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2CutInc2
%% 
%%  10 point increased apodization of FID from spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 2 ---
if mrsi.spec2.cut==1
    mrsi.spec2.cut = 64;
else
    mrsi.spec2.cut = mrsi.spec2.cut + 64;
end
set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))

%--- update value spec 1 ---
if flag.mrsiSpec1Cut && flag.mrsiSyncCut
    if mrsi.spec1.cut==1
        mrsi.spec1.cut = 64;
    else
        mrsi.spec1.cut = mrsi.spec1.cut + 64;
    end
    set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
