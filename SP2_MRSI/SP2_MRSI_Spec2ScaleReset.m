%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ScaleReset
%% 
%%  Reset scaling of spectrum 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.scale = 1;
set(fm.mrsi.spec2ScaleVal,'String',sprintf('%.3f',mrsi.spec2.scale))

%--- update value spec 1 ---
if flag.mrsiSpec1Scale && flag.mrsiSyncScale
    mrsi.spec1.scale = 1;
    set(fm.mrsi.spec1ScaleVal,'String',sprintf('%.3f',mrsi.spec1.scale))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
