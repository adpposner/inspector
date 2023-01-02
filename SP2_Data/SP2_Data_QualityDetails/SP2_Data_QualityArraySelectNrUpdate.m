%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityArraySelectNrUpdate
%% 
%%  Parameter update for quality assessment page.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data


%--- parameter update ---
data.quality.selectNr = str2num(get(fm.data.qualityDet.arraySelectNr,'String'));
data.quality.selectNr = min(max(1,round(data.quality.selectNr)),data.spec1.nr*data.spec1.seriesN);
set(fm.data.qualityDet.arraySelectNr,'String',num2str(data.quality.selectNr))

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);

