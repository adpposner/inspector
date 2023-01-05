%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityFrequglobalUpdate
%% 
%%  Updates radiobutton setting: global frequency range
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.dataQualityFrequMode = get(fm.data.qualityDet.frequglobal,'Value');

%--- switch radiobutton ---
set(fm.data.qualityDet.frequglobal,'Value',flag.dataQualityFrequMode)
set(fm.data.qualityDet.frequDirect,'Value',~flag.dataQualityFrequMode)

%--- update window ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);
