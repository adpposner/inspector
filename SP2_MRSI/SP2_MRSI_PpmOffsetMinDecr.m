%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmOffsetMinDecr
%% 
%%  0.1ppm decrease of minimum ppm offset window.
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi

%--- update window limit ---
mrsi.ppmOffsetMin = mrsi.ppmOffsetMin - 0.1;
set(fm.mrsi.ppmOffsetMin,'String',sprintf('%.2f',mrsi.ppmOffsetMin))

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
