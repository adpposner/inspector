%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ScaleUpdate
%% 
%%  Update of scaling factor for spectrum 2
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.scale = str2num(get(fm.mrsi.spec2ScaleVal,'String'));
set(fm.mrsi.spec2ScaleVal,'String',sprintf('%.3f',mrsi.spec2.scale))

%--- update value spec 1 ---
if flag.mrsiSpec1Scale && flag.mrsiSyncScale
    mrsi.spec1.scale = mrsi.spec2.scale;
    set(fm.mrsi.spec1ScaleVal,'String',sprintf('%.3f',mrsi.spec1.scale))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
