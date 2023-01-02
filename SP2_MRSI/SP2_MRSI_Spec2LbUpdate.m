%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2LbUpdate
%% 
%%  Update line broadening for spectrum 2
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.lb = str2num(get(fm.mrsi.spec2LbVal,'String'));
set(fm.mrsi.spec2LbVal,'String',sprintf('%.2f',mrsi.spec2.lb))

%--- update value spec 1 ---
if flag.mrsiSpec1Lb && flag.mrsiSyncLb
    mrsi.spec1.lb = mrsi.spec2.lb;
    set(fm.mrsi.spec1LbVal,'String',sprintf('%.2f',mrsi.spec1.lb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
