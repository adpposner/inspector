%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ScaleInc2
%% 
%%  0.01 increased scaling of spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.scale = mrsi.spec2.scale + 0.01;
set(fm.mrsi.spec2ScaleVal,'String',sprintf('%.3f',mrsi.spec2.scale))

%--- update value spec 1 ---
if flag.mrsiSpec1Scale && flag.mrsiSyncScale
    mrsi.spec1.scale = mrsi.spec1.scale + 0.01;
    set(fm.mrsi.spec1ScaleVal,'String',sprintf('%.3f',mrsi.spec1.scale))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
