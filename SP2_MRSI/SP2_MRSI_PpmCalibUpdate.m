%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmCalibUpdate
%% 
%%  Update frequency calibration
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi flag


%--- update percentage value ---
mrsi.ppmCalib = str2num(get(fm.mrsi.ppmCalib,'String'));
set(fm.mrsi.ppmCalib,'String',num2str(mrsi.ppmCalib))

%--- ppm position update ---
if flag.mrsiPpmShowPos
    SP2_MRSI_PpmShowPosValUpdate
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
