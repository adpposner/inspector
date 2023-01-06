%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1LbDec2
%% 
%%  1Hz reduction of exponential line broadening.
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag

%--- update percentage value spec 1 ---
mrsi.spec1.lb = mrsi.spec1.lb - 1;
set(fm.mrsi.spec1LbVal,'String',sprintf('%.2f',mrsi.spec1.lb))

%--- update percentage value spec 2 ---
if flag.mrsiSpec2Lb && flag.mrsiSyncLb
    mrsi.spec2.lb = mrsi.spec2.lb - 1;
    set(fm.mrsi.spec2LbVal,'String',sprintf('%.2f',mrsi.spec2.lb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
