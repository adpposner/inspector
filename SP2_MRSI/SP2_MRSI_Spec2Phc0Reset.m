%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2Phc0Reset
%% 
%%  Reset zero order phase correction
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update percentage value ---
mrsi.spec2.phc0 = 0;
set(fm.mrsi.spec2Phc0Val,'String',sprintf('%.1f',mrsi.spec2.phc0))

%--- update value spec 1 ---
if flag.mrsiSpec1Phc0 && flag.mrsiSyncPhc0
    mrsi.spec1.phc0 = 0;
    set(fm.mrsi.spec1Phc0Val,'String',sprintf('%.1f',mrsi.spec1.phc0))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
