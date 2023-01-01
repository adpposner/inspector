%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ShiftUpdate
%% 
%%  Update line frequency shift [Hz] for spectrum 2
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.shift = str2num(get(fm.mrsi.spec2ShiftVal,'String'));
set(fm.mrsi.spec2ShiftVal,'String',sprintf('%.3f',mrsi.spec2.shift))

%--- update value spec 1 ---
if flag.mrsiSpec1Shift && flag.mrsiSyncShift
    mrsi.spec1.shift = mrsi.spec2.shift;
    set(fm.mrsi.spec1ShiftVal,'String',sprintf('%.3f',mrsi.spec1.shift))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
