%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1ScaleReset
%% 
%%  Reset scaling of spectrum 1.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value ---
mrsi.spec1.scale = 1;
set(fm.mrsi.spec1ScaleVal,'String',sprintf('%.3f',mrsi.spec1.scale))

%--- update value spec 2 ---
if flag.mrsiSpec2Scale && flag.mrsiSyncScale
    mrsi.spec2.scale = 1;
    set(fm.mrsi.spec2ScaleVal,'String',sprintf('%.3f',mrsi.spec2.scale))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
