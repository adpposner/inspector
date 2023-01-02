%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_LCModelWinUpdate
%% 
%%  'LCM' window update
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag lcm

FCTNAME = 'SP2_LCM_LCModelWinUpdate';


%--- processing and export data format ---
if flag.lcmDataFormat==1            % matlab format
    set(fm.lcm.dataPath,'String',lcm.dataPathMat)
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathMat)
elseif flag.lcmDataFormat==2        % RAG text format 
    set(fm.lcm.dataPath,'String',lcm.dataPathTxt)
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathTxt)
elseif flag.lcmDataFormat==3        % metabolite (.par) format 
    set(fm.lcm.dataPath,'String',lcm.dataPathPar)
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathMat)    % note: .mat
elseif flag.lcmDataFormat==4        % Provencher LCModel
    set(fm.lcm.dataPath,'String',lcm.dataPathRaw)
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathRaw)
else                                % JMRUI
    set(fm.lcm.dataPath,'String',lcm.dataPathJmrui)
    set(fm.lcm.exptDataPath,'String',lcm.expt.dataPathMat)
end

%--- data format ---
if flag.lcmData==6          % directly from LCM sheet
    set(fm.lcm.dataPath,'Enable','on')
    set(fm.lcm.dataSelect,'Enable','on')
else                        % from data sheet
    set(fm.lcm.dataPath,'Enable','off')
    set(fm.lcm.dataSelect,'Enable','off')
end

%--- spectrum 1: cut-off (apodization) ---
if flag.lcmSpecCut==1
    set(fm.lcm.specCutDec3,'Enable','on')
    set(fm.lcm.specCutDec2,'Enable','on')
    set(fm.lcm.specCutDec1,'Enable','on')
    set(fm.lcm.specCutVal,'Enable','on')
    set(fm.lcm.specCutInc1,'Enable','on')
    set(fm.lcm.specCutInc2,'Enable','on')
    set(fm.lcm.specCutInc3,'Enable','on')
    set(fm.lcm.specCutReset,'Enable','on')
else
    set(fm.lcm.specCutDec3,'Enable','off')
    set(fm.lcm.specCutDec2,'Enable','off')
    set(fm.lcm.specCutDec1,'Enable','off')
    set(fm.lcm.specCutVal,'Enable','off')
    set(fm.lcm.specCutInc1,'Enable','off')
    set(fm.lcm.specCutInc2,'Enable','off')
    set(fm.lcm.specCutInc3,'Enable','off')
    set(fm.lcm.specCutReset,'Enable','off')
end

%--- Spetrum 1: ZF ---
if flag.lcmSpecZf==1
    set(fm.lcm.specZfDec3,'Enable','on')
    set(fm.lcm.specZfDec2,'Enable','on')
    set(fm.lcm.specZfDec1,'Enable','on')
    set(fm.lcm.specZfVal,'Enable','on')
    set(fm.lcm.specZfInc1,'Enable','on')
    set(fm.lcm.specZfInc2,'Enable','on')
    set(fm.lcm.specZfInc3,'Enable','on')
    set(fm.lcm.specZfReset,'Enable','on')
else
    set(fm.lcm.specZfDec3,'Enable','off')
    set(fm.lcm.specZfDec2,'Enable','off')
    set(fm.lcm.specZfDec1,'Enable','off')
    set(fm.lcm.specZfVal,'Enable','off')
    set(fm.lcm.specZfInc1,'Enable','off')
    set(fm.lcm.specZfInc2,'Enable','off')
    set(fm.lcm.specZfInc3,'Enable','off')
    set(fm.lcm.specZfReset,'Enable','off')
end

%--- exponential line broadening ---
if flag.lcmSpecLb==1
    set(fm.lcm.specLbDec3,'Enable','on')
    set(fm.lcm.specLbDec2,'Enable','on')
    set(fm.lcm.specLbDec1,'Enable','on')
    set(fm.lcm.specLbVal,'Enable','on')
    set(fm.lcm.specLbInc1,'Enable','on')
    set(fm.lcm.specLbInc2,'Enable','on')
    set(fm.lcm.specLbInc3,'Enable','on')
    set(fm.lcm.specLbReset,'Enable','on')
else
    set(fm.lcm.specLbDec3,'Enable','off')
    set(fm.lcm.specLbDec2,'Enable','off')
    set(fm.lcm.specLbDec1,'Enable','off')
    set(fm.lcm.specLbVal,'Enable','off')
    set(fm.lcm.specLbInc1,'Enable','off')
    set(fm.lcm.specLbInc2,'Enable','off')
    set(fm.lcm.specLbInc3,'Enable','off')
    set(fm.lcm.specLbReset,'Enable','off')
end

%--- Gaussian line broadening ---
if flag.lcmSpecGb==1
    set(fm.lcm.specGbDec3,'Enable','on')
    set(fm.lcm.specGbDec2,'Enable','on')
    set(fm.lcm.specGbDec1,'Enable','on')
    set(fm.lcm.specGbVal,'Enable','on')
    set(fm.lcm.specGbInc1,'Enable','on')
    set(fm.lcm.specGbInc2,'Enable','on')
    set(fm.lcm.specGbInc3,'Enable','on')
    set(fm.lcm.specGbReset,'Enable','on')
else
    set(fm.lcm.specGbDec3,'Enable','off')
    set(fm.lcm.specGbDec2,'Enable','off')
    set(fm.lcm.specGbDec1,'Enable','off')
    set(fm.lcm.specGbVal,'Enable','off')
    set(fm.lcm.specGbInc1,'Enable','off')
    set(fm.lcm.specGbInc2,'Enable','off')
    set(fm.lcm.specGbInc3,'Enable','off')
    set(fm.lcm.specGbReset,'Enable','off')
end

%--- zero order phase correction ---
if flag.lcmSpecPhc0
    set(fm.lcm.specPhc0Dec3,'Enable','on')
    set(fm.lcm.specPhc0Dec2,'Enable','on')
    set(fm.lcm.specPhc0Dec1,'Enable','on')
    set(fm.lcm.specPhc0Val,'Enable','on')
    set(fm.lcm.specPhc0Inc1,'Enable','on')
    set(fm.lcm.specPhc0Inc2,'Enable','on')
    set(fm.lcm.specPhc0Inc3,'Enable','on')
    set(fm.lcm.specPhc0Reset,'Enable','on')
else
    set(fm.lcm.specPhc0Dec3,'Enable','off')
    set(fm.lcm.specPhc0Dec2,'Enable','off')
    set(fm.lcm.specPhc0Dec1,'Enable','off')
    set(fm.lcm.specPhc0Val,'Enable','off')
    set(fm.lcm.specPhc0Inc1,'Enable','off')
    set(fm.lcm.specPhc0Inc2,'Enable','off')
    set(fm.lcm.specPhc0Inc3,'Enable','off')
    set(fm.lcm.specPhc0Reset,'Enable','off')
end

%--- first order phase correction ---
if flag.lcmSpecPhc1
    set(fm.lcm.specPhc1Dec3,'Enable','on')
    set(fm.lcm.specPhc1Dec2,'Enable','on')
    set(fm.lcm.specPhc1Dec1,'Enable','on')
    set(fm.lcm.specPhc1Val,'Enable','on')
    set(fm.lcm.specPhc1Inc1,'Enable','on')
    set(fm.lcm.specPhc1Inc2,'Enable','on')
    set(fm.lcm.specPhc1Inc3,'Enable','on')
    set(fm.lcm.specPhc1Reset,'Enable','on')
else
    set(fm.lcm.specPhc1Dec3,'Enable','off')
    set(fm.lcm.specPhc1Dec2,'Enable','off')
    set(fm.lcm.specPhc1Dec1,'Enable','off')
    set(fm.lcm.specPhc1Val,'Enable','off')
    set(fm.lcm.specPhc1Inc1,'Enable','off')
    set(fm.lcm.specPhc1Inc2,'Enable','off')
    set(fm.lcm.specPhc1Inc3,'Enable','off')
    set(fm.lcm.specPhc1Reset,'Enable','off')
end

%--- amplitude scaling: spectrum 1 ---
if flag.lcmSpecScale==1
    set(fm.lcm.specScaleDec3,'Enable','on')
    set(fm.lcm.specScaleDec2,'Enable','on')
    set(fm.lcm.specScaleDec1,'Enable','on')
    set(fm.lcm.specScaleVal,'Enable','on')
    set(fm.lcm.specScaleInc1,'Enable','on')
    set(fm.lcm.specScaleInc2,'Enable','on')
    set(fm.lcm.specScaleInc3,'Enable','on')
    set(fm.lcm.specScaleReset,'Enable','on')
else
    set(fm.lcm.specScaleDec3,'Enable','off')
    set(fm.lcm.specScaleDec2,'Enable','off')
    set(fm.lcm.specScaleDec1,'Enable','off')
    set(fm.lcm.specScaleVal,'Enable','off')
    set(fm.lcm.specScaleInc1,'Enable','off')
    set(fm.lcm.specScaleInc2,'Enable','off')
    set(fm.lcm.specScaleInc3,'Enable','off')
    set(fm.lcm.specScaleReset,'Enable','off')
end

%--- frequency shift: spectrum 1 ---
if flag.lcmSpecShift==1
    set(fm.lcm.specShiftDec3,'Enable','on')
    set(fm.lcm.specShiftDec2,'Enable','on')
    set(fm.lcm.specShiftDec1,'Enable','on')
    set(fm.lcm.specShiftVal,'Enable','on')
    set(fm.lcm.specShiftInc1,'Enable','on')
    set(fm.lcm.specShiftInc2,'Enable','on')
    set(fm.lcm.specShiftInc3,'Enable','on')
    set(fm.lcm.specShiftReset,'Enable','on')
else
    set(fm.lcm.specShiftDec3,'Enable','off')
    set(fm.lcm.specShiftDec2,'Enable','off')
    set(fm.lcm.specShiftDec1,'Enable','off')
    set(fm.lcm.specShiftVal,'Enable','off')
    set(fm.lcm.specShiftInc1,'Enable','off')
    set(fm.lcm.specShiftInc2,'Enable','off')
    set(fm.lcm.specShiftInc3,'Enable','off')
    set(fm.lcm.specShiftReset,'Enable','off')
end

%--- baseline offset: spectrum 1 ---
if flag.lcmSpecOffset==1
    set(fm.lcm.specOffsetDec3,'Enable','on')
    set(fm.lcm.specOffsetDec2,'Enable','on')
    set(fm.lcm.specOffsetDec1,'Enable','on')
    set(fm.lcm.specOffsetVal,'Enable','on')
    set(fm.lcm.specOffsetInc1,'Enable','on')
    set(fm.lcm.specOffsetInc2,'Enable','on')
    set(fm.lcm.specOffsetInc3,'Enable','on')
    set(fm.lcm.specOffsetReset,'Enable','on')
else
    set(fm.lcm.specOffsetDec3,'Enable','off')
    set(fm.lcm.specOffsetDec2,'Enable','off')
    set(fm.lcm.specOffsetDec1,'Enable','off')
    set(fm.lcm.specOffsetVal,'Enable','off')
    set(fm.lcm.specOffsetInc1,'Enable','off')
    set(fm.lcm.specOffsetInc2,'Enable','off')
    set(fm.lcm.specOffsetInc3,'Enable','off')
    set(fm.lcm.specOffsetReset,'Enable','off')
end

%--- ppm calib update ---
set(fm.lcm.ppmCalib,'String',sprintf('%.4f',lcm.ppmCalib))

%--- fit parameter flag update ---
set(fm.lcm.anaLbFlag,'Value',flag.lcmAnaLb)
set(fm.lcm.anaGbFlag,'Value',flag.lcmAnaGb)
set(fm.lcm.anaShiftFlag,'Value',flag.lcmAnaShift)
set(fm.lcm.anaPolyFlag,'Value',flag.lcmAnaPoly)
set(fm.lcm.anaPhc0Flag,'Value',flag.lcmAnaPhc0)
set(fm.lcm.anaPhc1Flag,'Value',flag.lcmAnaPhc1)

%--- baseline offset mode ---
if flag.lcmOffset          % ppm range
    set(fm.lcm.ppmOffsetMinDecr,'Enable','on')
    set(fm.lcm.ppmOffsetMin,'Enable','on')
    set(fm.lcm.ppmOffsetMinIncr,'Enable','on')
    set(fm.lcm.ppmOffsetMaxDecr,'Enable','on')
    set(fm.lcm.ppmOffsetMax,'Enable','on')
    set(fm.lcm.ppmOffsetMaxIncr,'Enable','on')
    set(fm.lcm.offsetDec3,'Enable','off')
    set(fm.lcm.offsetDec2,'Enable','off')
    set(fm.lcm.offsetDec1,'Enable','off')
    set(fm.lcm.offsetVal,'Enable','off')
    set(fm.lcm.offsetInc1,'Enable','off')
    set(fm.lcm.offsetInc2,'Enable','off')
    set(fm.lcm.offsetInc3,'Enable','off')
    set(fm.lcm.offsetReset,'Enable','off')
    set(fm.lcm.offsetAssign,'Enable','off')
else                        % direct value assignment
    set(fm.lcm.ppmOffsetMinDecr,'Enable','off')
    set(fm.lcm.ppmOffsetMin,'Enable','off')
    set(fm.lcm.ppmOffsetMinIncr,'Enable','off')
    set(fm.lcm.ppmOffsetMaxDecr,'Enable','off')
    set(fm.lcm.ppmOffsetMax,'Enable','off')
    set(fm.lcm.ppmOffsetMaxIncr,'Enable','off')
    set(fm.lcm.offsetDec3,'Enable','on')
    set(fm.lcm.offsetDec2,'Enable','on')
    set(fm.lcm.offsetDec1,'Enable','on')
    set(fm.lcm.offsetVal,'Enable','on')
    set(fm.lcm.offsetInc1,'Enable','on')
    set(fm.lcm.offsetInc2,'Enable','on')
    set(fm.lcm.offsetInc3,'Enable','on')
    set(fm.lcm.offsetReset,'Enable','on')
    set(fm.lcm.offsetAssign,'Enable','on')
end
set(fm.lcm.offsetVal,'String',sprintf('%.1f',lcm.offsetVal))

%--- visualization of specific frequency ---
if flag.lcmPpmShowPos
    set(fm.lcm.ppmShowPosVal,'Enable','on')
    set(fm.lcm.ppmShowPosAssign,'Enable','on')
else
    set(fm.lcm.ppmShowPosVal,'Enable','off')
    set(fm.lcm.ppmShowPosAssign,'Enable','off')
end
set(fm.lcm.ppmShowPosVal,'String',sprintf('%.4f',lcm.ppmShowPos))

%--- visualization: frequency ---
if flag.lcmPpmShow         % direct
    set(fm.lcm.ppmShowMinDecr,'Enable','on')
    set(fm.lcm.ppmShowMin,'Enable','on')
    set(fm.lcm.ppmShowMinIncr,'Enable','on')
    set(fm.lcm.ppmShowMaxDecr,'Enable','on')
    set(fm.lcm.ppmShowMax,'Enable','on')
    set(fm.lcm.ppmShowMaxIncr,'Enable','on')
else                        % full SW
    set(fm.lcm.ppmShowMinDecr,'Enable','off')
    set(fm.lcm.ppmShowMin,'Enable','off')
    set(fm.lcm.ppmShowMinIncr,'Enable','off')
    set(fm.lcm.ppmShowMaxDecr,'Enable','off')
    set(fm.lcm.ppmShowMax,'Enable','off')
    set(fm.lcm.ppmShowMaxIncr,'Enable','off')
end

%--- visualization: amplitude ---
if flag.lcmAmpl             % direct
    set(fm.lcm.amplMinDecr,'Enable','on')
    set(fm.lcm.amplMin,'Enable','on')
    set(fm.lcm.amplMinIncr,'Enable','on')
    set(fm.lcm.amplMaxDecr,'Enable','on')
    set(fm.lcm.amplMax,'Enable','on')
    set(fm.lcm.amplMaxIncr,'Enable','on')
else                        % auto
    set(fm.lcm.amplMinDecr,'Enable','off')
    set(fm.lcm.amplMin,'Enable','off')
    set(fm.lcm.amplMinIncr,'Enable','off')
    set(fm.lcm.amplMaxDecr,'Enable','off')
    set(fm.lcm.amplMax,'Enable','off')
    set(fm.lcm.amplMaxIncr,'Enable','off')
end

%--- Monte-Carlo ---
if flag.lcmMCarloInit
    set(fm.lcm.anaMCarloSpread,'Enable','on')
else
    set(fm.lcm.anaMCarloSpread,'Enable','off')
end

%--- polynomial order ---
if flag.lcmAnaPoly
    set(fm.lcm.anaPolyOrdDec,'Enable','on')
    set(fm.lcm.anaPolyOrder,'Enable','on')
    set(fm.lcm.anaPolyOrdInc,'Enable','on')
else
    set(fm.lcm.anaPolyOrdDec,'Enable','off')
    set(fm.lcm.anaPolyOrder,'Enable','off')
    set(fm.lcm.anaPolyOrdInc,'Enable','off')
end

%--- spline points per ppm ---
if flag.lcmAnaSpline
    set(fm.lcm.anaSplPtsPerPpm,'Enable','on')
else
    set(fm.lcm.anaSplPtsPerPpm,'Enable','off')
end

%--- selection vs. all metabolites display ---
if flag.lcmShowSelAll           % selection
    set(fm.lcm.showSelStr,'Enable','on')
else
    set(fm.lcm.showSelStr,'Enable','off')
end

%--- current display metabolite ---
set(fm.lcm.singleCurr,'String',sprintf('%.0f',lcm.fit.currShow))

%--- log file creation ---
% automatically disabled (with WARNING) when selected, but the export
% directory is not accessible
set(fm.lcm.saveLog,'Value',flag.lcmSaveLog)

%--- jpeg file creation ---
% automatically saves figures to image (jpeg) format ---
set(fm.lcm.saveJpeg,'Value',flag.lcmSaveJpeg)





