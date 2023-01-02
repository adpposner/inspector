%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1Phc1Update
%% 
%%  Update of first order phase correction value for spectrum 1
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.phc1 = str2num(get(fm.mrsi.spec1Phc1Val,'String'));
set(fm.mrsi.spec1Phc1Val,'String',sprintf('%.1f',mrsi.spec1.phc1))

%--- update value spec 2 ---
if flag.mrsiSpec2Phc1 && flag.mrsiSyncPhc1
    mrsi.spec2.phc1 = mrsi.spec1.phc1;
    set(fm.mrsi.spec2Phc1Val,'String',sprintf('%.1f',mrsi.spec2.phc1))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate