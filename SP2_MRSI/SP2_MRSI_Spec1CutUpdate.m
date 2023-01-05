%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1CutUpdate
%% 
%%  Update cut-off point of FID data apodization for spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update cut-off value spec 1 ---
mrsi.spec1.cut = str2double(get(fm.mrsi.spec1CutVal,'String'));
set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))

%--- update cut-off value spec 2 ---
if flag.mrsiSpec2Cut && flag.mrsiSyncCut
    mrsi.spec2.cut = mrsi.spec1.cut;
    set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
