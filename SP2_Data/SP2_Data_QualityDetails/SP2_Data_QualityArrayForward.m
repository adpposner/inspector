%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityArrayForward
%% 
%%  Scroll forward through spectral array in steps of columns*rows.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- parameter update ---
if data.quality.selectN>0       % corresponding index in 'select' vector
    [val,currInd] = min(abs(data.quality.select-data.quality.selectNr));
else
    fprintf('%s ->\nEmpty NR selection detected. Program aborted.\n',FCTNAME)
    return
end

%--- apply forward step only if the experiment end is beyond the current display ---
if currInd+data.quality.cols*data.quality.rows>data.quality.selectN
    newInd = currInd;                   % do not apply forward shift
else
    newInd = currInd + data.quality.cols*data.quality.rows;     % new index in 'select' vector
end
newInd = min(max(1,newInd),data.quality.selectN);
data.quality.selectNr = data.quality.select(newInd);
set(fm.data.qualityDet.arraySelectNr,'String',num2str(data.quality.selectNr))

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);

