%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityFrequGlobalUpdate
%% 
%%  Updates radiobutton setting: Global frequency range
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.dataQualityFrequMode = get(fm.data.qualityDet.frequGlobal,'Value');

%--- switch radiobutton ---
set(fm.data.qualityDet.frequGlobal,'Value',flag.dataQualityFrequMode)
set(fm.data.qualityDet.frequDirect,'Value',~flag.dataQualityFrequMode)

%--- update window ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);
