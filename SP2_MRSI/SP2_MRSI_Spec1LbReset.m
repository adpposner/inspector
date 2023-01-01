%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1LbReset
%% 
%%  Reset exponential line broadening.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag

%--- update percentage value spec 1 ---
mrsi.spec1.lb = 0;
set(fm.mrsi.spec1LbVal,'String',sprintf('%.2f',mrsi.spec1.lb))

%--- update percentage value spec 2 ---
if flag.mrsiSpec2Lb && flag.mrsiSyncLb
    mrsi.spec2.lb = 0;
    set(fm.mrsi.spec2LbVal,'String',sprintf('%.2f',mrsi.spec2.lb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
