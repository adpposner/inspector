%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1ScaleDec2
%% 
%%  0.01 reduced scaling of spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.scale = mrsi.spec1.scale - 0.01;
set(fm.mrsi.spec1ScaleVal,'String',sprintf('%.3f',mrsi.spec1.scale))

%--- update value spec 2 ---
if flag.mrsiSpec2Scale && flag.mrsiSyncScale
    mrsi.spec2.scale = mrsi.spec2.scale - 0.01;
    set(fm.mrsi.spec2ScaleVal,'String',sprintf('%.3f',mrsi.spec2.scale))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
