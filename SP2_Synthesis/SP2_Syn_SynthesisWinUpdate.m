%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_SynthesisWinUpdate
%% 
%%  'Simulation' window update
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag syn pars

FCTNAME = 'SP2_Syn_SynthesisWinUpdate';


%--- ppm calibration ---
set(fm.syn.sf,'String',num2str(syn.sf))
set(fm.syn.ppmCalib,'String',num2str(syn.ppmCalib))
set(fm.syn.sw_h,'String',num2str(syn.sw_h))
set(fm.syn.nspecCBasic,'String',num2str(syn.nspecCBasic))

%--- noise amplitude ---
if flag.synNoise
    set(fm.syn.noiseAmp,'Enable','on')
    set(fm.syn.noiseKeep,'Enable','on')
else
    set(fm.syn.noiseAmp,'Enable','off')
    set(fm.syn.noiseKeep,'Enable','off')
end

%--- baseline amplitude ---
if flag.synBase
    set(fm.syn.baseAmp,'Enable','on')
else
    set(fm.syn.baseAmp,'Enable','off')
end

%--- polynomial baseline amplitude ---
if flag.synPoly
    set(fm.syn.polyCenterLab,'Color',pars.fgTextColor)
    set(fm.syn.polyCenter,'Enable','on')    
    set(fm.syn.polyAmp0Lab,'Color',pars.fgTextColor)
    set(fm.syn.polyAmp0,'Enable','on')
    set(fm.syn.polyAmp1Lab,'Color',pars.fgTextColor)
    set(fm.syn.polyAmp1,'Enable','on')
    set(fm.syn.polyAmp2Lab,'Color',pars.fgTextColor)
    set(fm.syn.polyAmp2,'Enable','on')
    set(fm.syn.polyAmp3Lab,'Color',pars.fgTextColor)
    set(fm.syn.polyAmp3,'Enable','on')
    set(fm.syn.polyAmp4Lab,'Color',pars.fgTextColor)
    set(fm.syn.polyAmp4,'Enable','on')
    set(fm.syn.polyAmp5Lab,'Color',pars.fgTextColor)
    set(fm.syn.polyAmp5,'Enable','on')
else
    set(fm.syn.polyCenterLab,'Color',pars.bgTextColor)
    set(fm.syn.polyCenter,'Enable','off')
    set(fm.syn.polyAmp0Lab,'Color',pars.bgTextColor)
    set(fm.syn.polyAmp0,'Enable','off')
    set(fm.syn.polyAmp1Lab,'Color',pars.bgTextColor)
    set(fm.syn.polyAmp1,'Enable','off')
    set(fm.syn.polyAmp2Lab,'Color',pars.bgTextColor)
    set(fm.syn.polyAmp2,'Enable','off')
    set(fm.syn.polyAmp3Lab,'Color',pars.bgTextColor)
    set(fm.syn.polyAmp3,'Enable','off')
    set(fm.syn.polyAmp4Lab,'Color',pars.bgTextColor)
    set(fm.syn.polyAmp4,'Enable','off')
    set(fm.syn.polyAmp5Lab,'Color',pars.bgTextColor)
    set(fm.syn.polyAmp5,'Enable','off')
end

%--- analysis frequency mode ---
if flag.synPpmShow                      % global loggingfile
    set(fm.syn.ppmShowMinDecr,'Enable','off')
    set(fm.syn.ppmShowMin,'Enable','off')
    set(fm.syn.ppmShowMinIncr,'Enable','off')
    set(fm.syn.ppmShowMaxDecr,'Enable','off')
    set(fm.syn.ppmShowMax,'Enable','off')
    set(fm.syn.ppmShowMaxIncr,'Enable','off')
else                                    % direct
    set(fm.syn.ppmShowMinDecr,'Enable','on')
    set(fm.syn.ppmShowMin,'Enable','on')
    set(fm.syn.ppmShowMinIncr,'Enable','on')
    set(fm.syn.ppmShowMaxDecr,'Enable','on')
    set(fm.syn.ppmShowMax,'Enable','on')
    set(fm.syn.ppmShowMaxIncr,'Enable','on')
end

%--- display amplitude mode ---
if flag.synAmplShow                     % direct
    set(fm.syn.amplShowMin,'Enable','on')
    set(fm.syn.amplShowMax,'Enable','on')
else                                    % auto
    set(fm.syn.amplShowMin,'Enable','off')
    set(fm.syn.amplShowMax,'Enable','off')
end

%--- ppm assign position ---
set(fm.syn.ppmShowPosVal,'String',num2str(syn.ppmShowPos))

%--- cut-off (apodization) ---
if flag.synProcCut==1
    set(fm.syn.procCutDec3,'Enable','on')
    set(fm.syn.procCutDec2,'Enable','on')
    set(fm.syn.procCutDec1,'Enable','on')
    set(fm.syn.procCutVal,'Enable','on')
    set(fm.syn.procCutInc1,'Enable','on')
    set(fm.syn.procCutInc2,'Enable','on')
    set(fm.syn.procCutInc3,'Enable','on')
    set(fm.syn.procCutReset,'Enable','on')
else
    set(fm.syn.procCutDec3,'Enable','off')
    set(fm.syn.procCutDec2,'Enable','off')
    set(fm.syn.procCutDec1,'Enable','off')
    set(fm.syn.procCutVal,'Enable','off')
    set(fm.syn.procCutInc1,'Enable','off')
    set(fm.syn.procCutInc2,'Enable','off')
    set(fm.syn.procCutInc3,'Enable','off')
    set(fm.syn.procCutReset,'Enable','off')
end

%--- ZF ---
if flag.synProcZf==1
    set(fm.syn.procZfDec3,'Enable','on')
    set(fm.syn.procZfDec2,'Enable','on')
    set(fm.syn.procZfDec1,'Enable','on')
    set(fm.syn.procZfVal,'Enable','on')
    set(fm.syn.procZfInc1,'Enable','on')
    set(fm.syn.procZfInc2,'Enable','on')
    set(fm.syn.procZfInc3,'Enable','on')
    set(fm.syn.procZfReset,'Enable','on')
else
    set(fm.syn.procZfDec3,'Enable','off')
    set(fm.syn.procZfDec2,'Enable','off')
    set(fm.syn.procZfDec1,'Enable','off')
    set(fm.syn.procZfVal,'Enable','off')
    set(fm.syn.procZfInc1,'Enable','off')
    set(fm.syn.procZfInc2,'Enable','off')
    set(fm.syn.procZfInc3,'Enable','off')
    set(fm.syn.procZfReset,'Enable','off')
end

%--- exponential line broadening ---
if flag.synProcLb==1
    set(fm.syn.procLbDec3,'Enable','on')
    set(fm.syn.procLbDec2,'Enable','on')
    set(fm.syn.procLbDec1,'Enable','on')
    set(fm.syn.procLbVal,'Enable','on')
    set(fm.syn.procLbInc1,'Enable','on')
    set(fm.syn.procLbInc2,'Enable','on')
    set(fm.syn.procLbInc3,'Enable','on')
    set(fm.syn.procLbReset,'Enable','on')
else
    set(fm.syn.procLbDec3,'Enable','off')
    set(fm.syn.procLbDec2,'Enable','off')
    set(fm.syn.procLbDec1,'Enable','off')
    set(fm.syn.procLbVal,'Enable','off')
    set(fm.syn.procLbInc1,'Enable','off')
    set(fm.syn.procLbInc2,'Enable','off')
    set(fm.syn.procLbInc3,'Enable','off')
    set(fm.syn.procLbReset,'Enable','off')
end

%--- Gaussian line broadening ---
if flag.synProcGb==1
    set(fm.syn.procGbDec3,'Enable','on')
    set(fm.syn.procGbDec2,'Enable','on')
    set(fm.syn.procGbDec1,'Enable','on')
    set(fm.syn.procGbVal,'Enable','on')
    set(fm.syn.procGbInc1,'Enable','on')
    set(fm.syn.procGbInc2,'Enable','on')
    set(fm.syn.procGbInc3,'Enable','on')
    set(fm.syn.procGbReset,'Enable','on')
else
    set(fm.syn.procGbDec3,'Enable','off')
    set(fm.syn.procGbDec2,'Enable','off')
    set(fm.syn.procGbDec1,'Enable','off')
    set(fm.syn.procGbVal,'Enable','off')
    set(fm.syn.procGbInc1,'Enable','off')
    set(fm.syn.procGbInc2,'Enable','off')
    set(fm.syn.procGbInc3,'Enable','off')
    set(fm.syn.procGbReset,'Enable','off')
end

%--- zero order phase correction ---
if flag.synProcPhc0
    set(fm.syn.procPhc0Dec3,'Enable','on')
    set(fm.syn.procPhc0Dec2,'Enable','on')
    set(fm.syn.procPhc0Dec1,'Enable','on')
    set(fm.syn.procPhc0Val,'Enable','on')
    set(fm.syn.procPhc0Inc1,'Enable','on')
    set(fm.syn.procPhc0Inc2,'Enable','on')
    set(fm.syn.procPhc0Inc3,'Enable','on')
    set(fm.syn.procPhc0Reset,'Enable','on')
else
    set(fm.syn.procPhc0Dec3,'Enable','off')
    set(fm.syn.procPhc0Dec2,'Enable','off')
    set(fm.syn.procPhc0Dec1,'Enable','off')
    set(fm.syn.procPhc0Val,'Enable','off')
    set(fm.syn.procPhc0Inc1,'Enable','off')
    set(fm.syn.procPhc0Inc2,'Enable','off')
    set(fm.syn.procPhc0Inc3,'Enable','off')
    set(fm.syn.procPhc0Reset,'Enable','off')
end

%--- first order phase correction ---
if flag.synProcPhc1
    set(fm.syn.procPhc1Dec3,'Enable','on')
    set(fm.syn.procPhc1Dec2,'Enable','on')
    set(fm.syn.procPhc1Dec1,'Enable','on')
    set(fm.syn.procPhc1Val,'Enable','on')
    set(fm.syn.procPhc1Inc1,'Enable','on')
    set(fm.syn.procPhc1Inc2,'Enable','on')
    set(fm.syn.procPhc1Inc3,'Enable','on')
    set(fm.syn.procPhc1Reset,'Enable','on')
else
    set(fm.syn.procPhc1Dec3,'Enable','off')
    set(fm.syn.procPhc1Dec2,'Enable','off')
    set(fm.syn.procPhc1Dec1,'Enable','off')
    set(fm.syn.procPhc1Val,'Enable','off')
    set(fm.syn.procPhc1Inc1,'Enable','off')
    set(fm.syn.procPhc1Inc2,'Enable','off')
    set(fm.syn.procPhc1Inc3,'Enable','off')
    set(fm.syn.procPhc1Reset,'Enable','off')
end

%--- amplitude scaling ---
if flag.synProcScale==1
    set(fm.syn.procScaleDec3,'Enable','on')
    set(fm.syn.procScaleDec2,'Enable','on')
    set(fm.syn.procScaleDec1,'Enable','on')
    set(fm.syn.procScaleVal,'Enable','on')
    set(fm.syn.procScaleInc1,'Enable','on')
    set(fm.syn.procScaleInc2,'Enable','on')
    set(fm.syn.procScaleInc3,'Enable','on')
    set(fm.syn.procScaleReset,'Enable','on')
else
    set(fm.syn.procScaleDec3,'Enable','off')
    set(fm.syn.procScaleDec2,'Enable','off')
    set(fm.syn.procScaleDec1,'Enable','off')
    set(fm.syn.procScaleVal,'Enable','off')
    set(fm.syn.procScaleInc1,'Enable','off')
    set(fm.syn.procScaleInc2,'Enable','off')
    set(fm.syn.procScaleInc3,'Enable','off')
    set(fm.syn.procScaleReset,'Enable','off')
end

%--- frequency shift ---
if flag.synProcShift==1
    set(fm.syn.procShiftDec3,'Enable','on')
    set(fm.syn.procShiftDec2,'Enable','on')
    set(fm.syn.procShiftDec1,'Enable','on')
    set(fm.syn.procShiftVal,'Enable','on')
    set(fm.syn.procShiftInc1,'Enable','on')
    set(fm.syn.procShiftInc2,'Enable','on')
    set(fm.syn.procShiftInc3,'Enable','on')
    set(fm.syn.procShiftReset,'Enable','on')
else
    set(fm.syn.procShiftDec3,'Enable','off')
    set(fm.syn.procShiftDec2,'Enable','off')
    set(fm.syn.procShiftDec1,'Enable','off')
    set(fm.syn.procShiftVal,'Enable','off')
    set(fm.syn.procShiftInc1,'Enable','off')
    set(fm.syn.procShiftInc2,'Enable','off')
    set(fm.syn.procShiftInc3,'Enable','off')
    set(fm.syn.procShiftReset,'Enable','off')
end

%--- baseline offset ---
if flag.synProcOffset==1
    set(fm.syn.procOffsetDec3,'Enable','on')
    set(fm.syn.procOffsetDec2,'Enable','on')
    set(fm.syn.procOffsetDec1,'Enable','on')
    set(fm.syn.procOffsetVal,'Enable','on')
    set(fm.syn.procOffsetInc1,'Enable','on')
    set(fm.syn.procOffsetInc2,'Enable','on')
    set(fm.syn.procOffsetInc3,'Enable','on')
    set(fm.syn.procOffsetReset,'Enable','on')
else
    set(fm.syn.procOffsetDec3,'Enable','off')
    set(fm.syn.procOffsetDec2,'Enable','off')
    set(fm.syn.procOffsetDec1,'Enable','off')
    set(fm.syn.procOffsetVal,'Enable','off')
    set(fm.syn.procOffsetInc1,'Enable','off')
    set(fm.syn.procOffsetInc2,'Enable','off')
    set(fm.syn.procOffsetInc3,'Enable','off')
    set(fm.syn.procOffsetReset,'Enable','off')
end

%--- baseline offset mode ---
if flag.synOffset          % ppm range
    set(fm.syn.ppmOffsetMinDecr,'Enable','on')
    set(fm.syn.ppmOffsetMin,'Enable','on')
    set(fm.syn.ppmOffsetMinIncr,'Enable','on')
    set(fm.syn.ppmOffsetMaxDecr,'Enable','on')
    set(fm.syn.ppmOffsetMax,'Enable','on')
    set(fm.syn.ppmOffsetMaxIncr,'Enable','on')
    set(fm.syn.offsetDec3,'Enable','off')
    set(fm.syn.offsetDec2,'Enable','off')
    set(fm.syn.offsetDec1,'Enable','off')
    set(fm.syn.offsetVal,'Enable','off')
    set(fm.syn.offsetInc1,'Enable','off')
    set(fm.syn.offsetInc2,'Enable','off')
    set(fm.syn.offsetInc3,'Enable','off')
    set(fm.syn.offsetReset,'Enable','off')
    set(fm.syn.offsetAssign,'Enable','off')
else                        % direct value assignment
    set(fm.syn.ppmOffsetMinDecr,'Enable','off')
    set(fm.syn.ppmOffsetMin,'Enable','off')
    set(fm.syn.ppmOffsetMinIncr,'Enable','off')
    set(fm.syn.ppmOffsetMaxDecr,'Enable','off')
    set(fm.syn.ppmOffsetMax,'Enable','off')
    set(fm.syn.ppmOffsetMaxIncr,'Enable','off')
    set(fm.syn.offsetDec3,'Enable','on')
    set(fm.syn.offsetDec2,'Enable','on')
    set(fm.syn.offsetDec1,'Enable','on')
    set(fm.syn.offsetVal,'Enable','on')
    set(fm.syn.offsetInc1,'Enable','on')
    set(fm.syn.offsetInc2,'Enable','on')
    set(fm.syn.offsetInc3,'Enable','on')
    set(fm.syn.offsetReset,'Enable','on')
    set(fm.syn.offsetAssign,'Enable','on')
end
set(fm.syn.offsetVal,'String',sprintf('%.1f',syn.offsetVal))

%--- visualization of specific frequency ---
if flag.synPpmShowPos
    set(fm.syn.ppmShowPosVal,'Enable','on')
    set(fm.syn.ppmShowPosAssign,'Enable','on')
else
    set(fm.syn.ppmShowPosVal,'Enable','off')
    set(fm.syn.ppmShowPosAssign,'Enable','off')
end
set(fm.syn.ppmShowPosVal,'String',sprintf('%.4f',syn.ppmShowPos))





