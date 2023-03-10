%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ZfDec3
%% 
%%  1000 point reduction of ZF for spectrum 2.
%%
%%  12-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update value spec 2 ---
mrsi.spec2.zf = max(mrsi.spec2.zf - 1024,1);
set(fm.mrsi.spec2ZfVal,'String',sprintf('%.0f',mrsi.spec2.zf))

%--- update value spec 1 ---
if flag.mrsiSpec1Zf && flag.mrsiSyncZf
    mrsi.spec1.zf = max(mrsi.spec1.zf - 1024,1);
    set(fm.mrsi.spec1ZfVal,'String',sprintf('%.0f',mrsi.spec1.zf))
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
