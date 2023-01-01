%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1GbDec3
%% 
%%  10Hz reduction of Gaussian line broadening.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag

%--- update percentage value spec 1 ---
mrsi.spec1.gb = mrsi.spec1.gb - 10;
set(fm.mrsi.spec1GbVal,'String',sprintf('%.2f',mrsi.spec1.gb))

%--- update percentage value spec 2 ---
if flag.mrsiSpec2Gb && flag.mrsiSyncGb
    mrsi.spec2.gb = mrsi.spec2.gb - 10;
    set(fm.mrsi.spec2GbVal,'String',sprintf('%.2f',mrsi.spec2.gb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
