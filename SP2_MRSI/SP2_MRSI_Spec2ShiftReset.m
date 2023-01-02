%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ShiftReset
%% 
%%  Reset frequency shift of spectrum 2.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.shift = 0;
set(fm.mrsi.spec2ShiftVal,'String',sprintf('%.3f',mrsi.spec2.shift))

%--- update value spec 1 ---
if flag.mrsiSpec1Shift && flag.mrsiSyncShift
    mrsi.spec1.shift = 0;
    set(fm.mrsi.spec1ShiftVal,'String',sprintf('%.3f',mrsi.spec1.shift))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
