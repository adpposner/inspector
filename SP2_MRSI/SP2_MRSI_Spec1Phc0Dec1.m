%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1Phc0Dec1
%% 
%%  0.1deg decrease of zero order phase correction
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.phc0 = mrsi.spec1.phc0 - 0.1;
set(fm.mrsi.spec1Phc0Val,'String',sprintf('%.1f',mrsi.spec1.phc0))

%--- update value spec 2 ---
if flag.mrsiSpec2Phc0 && flag.mrsiSyncPhc0
    mrsi.spec2.phc0 = mrsi.spec2.phc0 - 0.1;
    set(fm.mrsi.spec2Phc0Val,'String',sprintf('%.1f',mrsi.spec2.phc0))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
