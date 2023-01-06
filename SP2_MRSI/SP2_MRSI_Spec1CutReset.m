%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1CutReset
%% 
%%  Reset apodization of FID from spectrum 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.cut = 1024;
set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))

%--- update value spec 2 ---
if flag.mrsiSpec2Cut && flag.mrsiSyncCut
    mrsi.spec2.cut = 1024;
    set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
