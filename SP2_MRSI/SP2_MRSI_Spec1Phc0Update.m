%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1Phc0Update
%% 
%%  Update of zero order phase correction value for spectrum 1
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.phc0 = str2num(get(fm.mrsi.spec1Phc0Val,'String'));
set(fm.mrsi.spec1Phc0Val,'String',sprintf('%.1f',mrsi.spec1.phc0))

%--- update value spec 2 ---
if flag.mrsiSpec2Phc0 && flag.mrsiSyncPhc0
    mrsi.spec2.phc0 = mrsi.spec1.phc0;
    set(fm.mrsi.spec2Phc0Val,'String',sprintf('%.1f',mrsi.spec2.phc0))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
