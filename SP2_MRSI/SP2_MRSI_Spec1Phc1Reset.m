%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1Phc1Reset
%% 
%%  Reset first order phase correction
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.phc1 = 0;
set(fm.mrsi.spec1Phc1Val,'String',sprintf('%.1f',mrsi.spec1.phc1))

%--- update value spec 2 ---
if flag.mrsiSpec2Phc1 && flag.mrsiSyncPhc1
    mrsi.spec2.phc1 = 0;
    set(fm.mrsi.spec2Phc1Val,'String',sprintf('%.1f',mrsi.spec2.phc1))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
