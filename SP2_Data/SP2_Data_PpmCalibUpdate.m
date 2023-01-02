%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmCalibUpdate
%% 
%%  Update frequency calibration
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data


%--- update percentage value ---
data.ppmCalib = str2num(get(fm.data.ppmCalib,'String'));

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);
