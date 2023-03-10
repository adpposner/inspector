%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1ShiftDec1
%% 
%%  0.1Hz decreased shift of spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.shift = mrsi.spec1.shift - 0.001;
set(fm.mrsi.spec1ShiftVal,'String',sprintf('%.3f',mrsi.spec1.shift))

%--- update value spec 2 ---
if flag.mrsiSpec2Shift && flag.mrsiSyncShift
    mrsi.spec2.shift = mrsi.spec2.shift - 0.001;
    set(fm.mrsi.spec2ShiftVal,'String',sprintf('%.3f',mrsi.spec2.shift))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
