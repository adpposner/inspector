%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2GbUpdate
%% 
%%  Update Gaussian line broadening for spectrum 2
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update percentage value ---
mrsi.spec2.gb = str2num(get(fm.mrsi.spec2GbVal,'String'));
set(fm.mrsi.spec2GbVal,'String',sprintf('%.2f',mrsi.spec2.gb))

%--- update value spec 1 ---
if flag.mrsiSpec1Gb && flag.mrsiSyncGb
    mrsi.spec1.gb = mrsi.spec2.gb;
    set(fm.mrsi.spec1GbVal,'String',sprintf('%.2f',mrsi.spec1.gb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
