%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1ZfInc1
%% 
%%  10 point increase of ZF for spectrum 1.
%%
%%  12-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.zf = mrsi.spec1.zf + 16;
set(fm.mrsi.spec1ZfVal,'String',sprintf('%.0f',mrsi.spec1.zf))

%--- update value spec 2 ---
if flag.mrsiSpec2Zf && flag.mrsiSyncZf
    mrsi.spec2.zf = mrsi.spec2.zf + 16;
    set(fm.mrsi.spec2ZfVal,'String',sprintf('%.0f',mrsi.spec2.zf))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate