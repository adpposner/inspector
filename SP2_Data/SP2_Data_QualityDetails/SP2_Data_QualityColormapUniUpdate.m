%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityColormapUniUpdate
%% 
%%  Updates radiobutton settings to switch color modes:
%%  0) unicolor (blue only)
%%  1) JET
%%  2) Uns' Uwe
%%  3) HOT
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- flag handling ---
flag.dataQualityCMap = 0;

%--- update flag displays ---
set(fm.data.qualityDet.cmapUni,'Value',flag.dataQualityCMap==0)
set(fm.data.qualityDet.cmapJet,'Value',flag.dataQualityCMap==1)
set(fm.data.qualityDet.cmapHsv,'Value',flag.dataQualityCMap==2)
set(fm.data.qualityDet.cmapHot,'Value',flag.dataQualityCMap==3)

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);