%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2GbInc3
%% 
%%  10Hz reduction of Gaussian line broadening.
%%
%%  08-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.gb = mrsi.spec2.gb + 10;
set(fm.mrsi.spec2GbVal,'String',sprintf('%.2f',mrsi.spec2.gb))

%--- update value spec 1 ---
if flag.mrsiSpec1Gb && flag.mrsiSyncGb
    mrsi.spec1.gb = mrsi.spec1.gb + 10;
    set(fm.mrsi.spec1GbVal,'String',sprintf('%.2f',mrsi.spec1.gb))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
