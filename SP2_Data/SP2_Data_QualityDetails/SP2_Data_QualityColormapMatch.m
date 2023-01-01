%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityColormapMatch
%% 
%%  Adjust full color range to match full range of NR selection
%%  via adjustment of # of rows/columns.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- rows of spectra ---
data.quality.rows = data.quality.selectN;
set(fm.data.qualityDet.rowsVal,'String',num2str(data.quality.rows))
fprintf('# of rows set to match number of NRs %.0f\n',data.quality.rows)

%--- columns of spectra ---
data.quality.cols = 1;
set(fm.data.qualityDet.colsVal,'String',num2str(data.quality.cols))

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);

