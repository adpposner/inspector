%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_QualityParsUpdate
%% 
%%  Parameter update for quality assessment page.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- exponential line braodening ---
data.quality.lb = str2num(get(fm.data.qualityDet.expLbVal,'String'));
if isempty(data.quality.lb)
    data.quality.lb = 0;
end
set(fm.data.qualityDet.expLbVal,'String',num2str(data.quality.lb))

%--- FID apodization ---
data.quality.cut = str2num(get(fm.data.qualityDet.fftCutVal,'String'));
if isempty(data.quality.cut)
    data.quality.cut = 1024;
end
data.quality.cut = max(data.quality.cut,10);
set(fm.data.qualityDet.fftCutVal,'String',num2str(data.quality.cut))

%--- zero filling ---
data.quality.zf = str2num(get(fm.data.qualityDet.fftZfVal,'String'));
if isempty(data.quality.zf)
    data.quality.zf = 16384;
end
data.quality.zf = max(data.quality.zf,1024);
set(fm.data.qualityDet.fftZfVal,'String',num2str(data.quality.zf))

%--- rows of spectra ---
data.quality.rows = str2num(get(fm.data.qualityDet.rowsVal,'String'));
if isempty(data.quality.rows)
    data.quality.rows = 1;
end
data.quality.rows = max(1,round(data.quality.rows));
set(fm.data.qualityDet.rowsVal,'String',num2str(data.quality.rows))

%--- columns of spectra ---
data.quality.cols = str2num(get(fm.data.qualityDet.colsVal,'String'));
if isempty(data.quality.cols)
    data.quality.cols = 0;
end
data.quality.cols = max(1,round(data.quality.cols));
set(fm.data.qualityDet.colsVal,'String',num2str(data.quality.cols))

%--- minimum amplitude ---
data.quality.amplMin = str2num(get(fm.data.qualityDet.amplMin,'String'));
if isempty(data.quality.amplMin)
    data.quality.amplMin = -10000;
end
data.quality.amplMin = min(data.quality.amplMin,data.quality.amplMax);
set(fm.data.qualityDet.amplMin,'String',num2str(data.quality.amplMin))

%--- maximum amplitude ---
data.quality.amplMax = str2num(get(fm.data.qualityDet.amplMax,'String'));
if isempty(data.quality.amplMax)
    data.quality.amplMax = 10000;
end
data.quality.amplMax = max(data.quality.amplMin,data.quality.amplMax);
set(fm.data.qualityDet.amplMax,'String',num2str(data.quality.amplMax))

%--- minimum frequency ---
data.quality.frequMin = str2num(get(fm.data.qualityDet.frequMin,'String'));
if isempty(data.quality.frequMin)
    data.quality.frequMin = 0;
end
data.quality.frequMin = min(data.quality.frequMin,data.quality.frequMax-0.1);
set(fm.data.qualityDet.frequMin,'String',num2str(data.quality.frequMin))

%--- maximum frequency ---
data.quality.frequMax = str2num(get(fm.data.qualityDet.frequMax,'String'));
if isempty(data.quality.frequMax)
    data.quality.frequMax = 10;
end
data.quality.frequMax = max(data.quality.frequMin+0.1,data.quality.frequMax);
set(fm.data.qualityDet.frequMax,'String',num2str(data.quality.frequMax))

%--- zero order phase offset ---
data.quality.phaseZero = str2num(get(fm.data.qualityDet.phaseZero,'String'));
if isempty(data.quality.phaseZero)
    data.quality.phaseZero = 0;
end
set(fm.data.qualityDet.phaseZero,'String',num2str(data.quality.phaseZero))

%--- window update ---
SP2_Data_QualityDetailsWinUpdate

%--- update of spectral array ---
SP2_Data_QualityArrayShow(0);

%--- update of spectral series ---
SP2_Data_QualitySeriesShow(0);

%--- update of spectra superposition ---
SP2_Data_QualitySuperposShow(0);


end
