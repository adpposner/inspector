%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2LbInc2
%% 
%%  1Hz reduction of exponential line broadening.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.lb = mrsi.spec2.lb + 1;
set(fm.mrsi.spec2LbVal,'String',sprintf('%.2f',mrsi.spec2.lb))

%--- update value spec 1 ---
if flag.mrsiSpec1Lb && flag.mrsiSyncLb
    mrsi.spec1.lb = mrsi.spec1.lb + 1;
    set(fm.mrsi.spec1LbVal,'String',sprintf('%.2f',mrsi.spec1.lb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
