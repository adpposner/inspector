%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_OffsetDec3
%% 
%%  Reduction of baseline offset value.
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm mrsi

%--- update percentage value spec 1 ---
mrsi.offsetVal = mrsi.offsetVal - 10000;
set(fm.mrsi.offsetVal,'String',sprintf('%.1f',mrsi.offsetVal))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
