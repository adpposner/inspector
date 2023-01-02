%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_PpmCalibUpdate
%% 
%%  Update ppm frequency calibration.
%%
%%  11-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm stab


%--- update cut-off value ---
stab.ppmCalib = str2double(get(fm.stab.ppmCalib,'String'));
set(fm.stab.ppmCalib,'String',sprintf('%.3f',stab.ppmCalib))

%--- window update ---
SP2_Stab_StabilityWinUpdate

