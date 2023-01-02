%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityFormatMagnUpdate
%% 
%%  Visualization mode:
%%  1) real
%%  2) imaginary
%%  3) magnitude
%%  4) phase
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- direct assignment ---
flag.dataQualityFormat = 3;

%--- switch radiobutton ---
set(fm.data.qualityDet.formatReal,'Value',flag.dataQualityFormat==1)
set(fm.data.qualityDet.formatImag,'Value',flag.dataQualityFormat==2)
set(fm.data.qualityDet.formatMagn,'Value',flag.dataQualityFormat==3)
set(fm.data.qualityDet.formatPhase,'Value',flag.dataQualityFormat==4)

%--- update window ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);

