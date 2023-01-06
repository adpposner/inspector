%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualitySeriesMedianUpdate
%% 
%%  Updates radiobutton settings to switch series mode:
%%  1) minimum
%%  2) maximum
%%  3) mean
%%  4) median
%%  5) SD
%%  6) integral
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- flag handling ---
flag.dataQualitySeries = 4;

%--- update flag displays ---
set(fm.data.qualityDet.seriesMin,'Value',flag.dataQualitySeries==1)
set(fm.data.qualityDet.seriesMax,'Value',flag.dataQualitySeries==2)
set(fm.data.qualityDet.seriesMean,'Value',flag.dataQualitySeries==3)
set(fm.data.qualityDet.seriesMedian,'Value',flag.dataQualitySeries==4)
set(fm.data.qualityDet.seriesSD,'Value',flag.dataQualitySeries==5)
set(fm.data.qualityDet.seriesIntegr,'Value',flag.dataQualitySeries==6)


%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);
end
