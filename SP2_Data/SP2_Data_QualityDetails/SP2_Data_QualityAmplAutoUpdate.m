%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityAmplAutoUpdate
%% 
%%  Updates radiobutton setting: automatic assignmen of amplitude limits
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.dataQualityAmplMode = get(fm.data.qualityDet.amplAuto,'Value');

%--- switch radiobutton ---
set(fm.data.qualityDet.amplAuto,'Value',flag.dataQualityAmplMode)
set(fm.data.qualityDet.amplDirect,'Value',~flag.dataQualityAmplMode)

%--- update window ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);


end
