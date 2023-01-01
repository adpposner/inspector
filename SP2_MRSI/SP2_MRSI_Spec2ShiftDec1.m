%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ShiftDec1
%% 
%%  0.1Hz decreased shift of spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.shift = mrsi.spec2.shift - 0.001;
set(fm.mrsi.spec2ShiftVal,'String',sprintf('%.3f',mrsi.spec2.shift))

%--- update value spec 1 ---
if flag.mrsiSpec1Shift && flag.mrsiSyncShift
    mrsi.spec1.shift = mrsi.spec1.shift - 0.001;
    set(fm.mrsi.spec1ShiftVal,'String',sprintf('%.3f',mrsi.spec1.shift))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
