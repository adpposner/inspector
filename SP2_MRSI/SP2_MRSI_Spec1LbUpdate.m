%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1LbUpdate
%% 
%%  Update line broadening for spectrum 1
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update percentage value spec 1 ---
mrsi.spec1.lb = str2num(get(fm.mrsi.spec1LbVal,'String'));
set(fm.mrsi.spec1LbVal,'String',sprintf('%.2f',mrsi.spec1.lb))

%--- update percentage value spec 2 ---
if flag.mrsiSpec2Lb && flag.mrsiSyncLb
    mrsi.spec2.lb = mrsi.spec1.lb;
    set(fm.mrsi.spec2LbVal,'String',sprintf('%.2f',mrsi.spec2.lb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
