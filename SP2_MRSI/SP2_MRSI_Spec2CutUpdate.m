%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2CutUpdate
%% 
%%  Update cut-off point of FID data apodization for spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.cut = str2double(get(fm.mrsi.spec2CutVal,'String'));
set(fm.mrsi.spec2CutVal,'String',sprintf('%.0f',mrsi.spec2.cut))

%--- update value spec 1 ---
if flag.mrsiSpec1Cut && flag.mrsiSyncCut
    mrsi.spec1.cut = mrsi.spec2.cut;
    set(fm.mrsi.spec1CutVal,'String',sprintf('%.0f',mrsi.spec1.cut))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
