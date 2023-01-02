%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1GbDec2
%% 
%%  1Hz reduction of Gaussian line broadening.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update GB value spec 1 ---
mrsi.spec1.gb = mrsi.spec1.gb - 1;
set(fm.mrsi.spec1GbVal,'String',sprintf('%.2f',mrsi.spec1.gb))

%--- update GB value spec 2 ---
if flag.mrsiSpec2Gb && flag.mrsiSyncGb
    mrsi.spec2.gb = mrsi.spec2.gb - 1;
    set(fm.mrsi.spec2GbVal,'String',sprintf('%.2f',mrsi.spec2.gb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
