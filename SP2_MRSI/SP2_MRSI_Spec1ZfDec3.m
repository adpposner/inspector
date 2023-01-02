%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1ZfDec3
%% 
%%  1000 point reduction of ZF for spectrum 1.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi flag


%--- update value spec 1 ---
mrsi.spec1.zf = max(mrsi.spec1.zf-1024,1);
set(fm.mrsi.spec1ZfVal,'String',sprintf('%.0f',mrsi.spec1.zf))

%--- update value spec 2 ---
if flag.mrsiSpec2Zf && flag.mrsiSyncZf
    mrsi.spec2.zf = max(mrsi.spec2.zf-1024,1);
    set(fm.mrsi.spec2ZfVal,'String',sprintf('%.0f',mrsi.spec2.zf))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
