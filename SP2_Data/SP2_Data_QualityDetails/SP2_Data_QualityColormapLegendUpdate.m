%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityColormapLegendUpdate
%% 
%%  Update legend radiobutton
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- flag handling ---
flag.dataQualityLegend = get(fm.data.qualityDet.cmapLegend,'Value');

%--- update flag displays ---
set(fm.data.qualityDet.cmapLegend,'Value',flag.dataQualityLegend)

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);