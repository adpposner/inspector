%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1GbUpdate
%% 
%%  Update line Gaussian broadening for spectrum 1
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update percentage value ---
mrsi.spec1.gb = str2num(get(fm.mrsi.spec1GbVal,'String'));
set(fm.mrsi.spec1GbVal,'String',sprintf('%.2f',mrsi.spec1.gb))

%--- update percentage value spec 2 ---
if flag.mrsiSpec2Gb && flag.mrsiSyncGb
    mrsi.spec2.gb = mrsi.spec1.gb;
    set(fm.mrsi.spec2GbVal,'String',sprintf('%.2f',mrsi.spec2.gb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
