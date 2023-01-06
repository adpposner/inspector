%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_MrsiWinUpdate
%% 
%%  'Data' window update
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag pars proc

FCTNAME = 'SP2_MRSI_MrsiWinUpdate';


%--- .mat/.txt update ---
if flag.mrsiDatFormat       % matlab format
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathMat)
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathMat)
    set(fm.mrsi.exptDataPath,'String',mrsi.expt.dataPathMat)
else                        % RAG text format 
    set(fm.mrsi.spec1DataPath,'String',mrsi.spec1.dataPathTxt)
    set(fm.mrsi.spec2DataPath,'String',mrsi.spec2.dataPathTxt)
    set(fm.mrsi.exptDataPath,'String',mrsi.expt.dataPathTxt)
end

%--- data format ---
if flag.mrsiData            % directly from processing sheet
    set(fm.mrsi.spec1DataPath,'Enable','on')
    set(fm.mrsi.spec1DataSelect,'Enable','on')
else                        % from data sheet
    set(fm.mrsi.spec1DataPath,'Enable','off')
    set(fm.mrsi.spec1DataSelect,'Enable','off')
end
if flag.mrsiNumSpec==0      % single spectrum mode
    set(fm.mrsi.spec2DataLab,'Color',pars.bgTextColor)
    set(fm.mrsi.spec2DataPath,'Enable','off')
    set(fm.mrsi.spec2DataSelect,'Enable','off')
    set(fm.mrsi.spec2DataLoad,'Enable','off')
else                        % two spectra mode
    set(fm.mrsi.spec2DataLab,'Color',pars.fgTextColor)
    if flag.mrsiData        % directly from processing sheet && 2 spectra mode
        set(fm.mrsi.spec2DataPath,'Enable','on')
        set(fm.mrsi.spec2DataSelect,'Enable','on')
    else                    % from data sheet 
        set(fm.mrsi.spec2DataPath,'Enable','off')
        set(fm.mrsi.spec2DataSelect,'Enable','off')
    end
    set(fm.mrsi.spec2DataLoad,'Enable','on')
end

%--- spectrum 1: cut-off (apodization) ---
if flag.mrsiSpec1Cut==1
    set(fm.mrsi.spec1CutDec3,'Enable','on')
    set(fm.mrsi.spec1CutDec2,'Enable','on')
    set(fm.mrsi.spec1CutDec1,'Enable','on')
    set(fm.mrsi.spec1CutVal,'Enable','on')
    set(fm.mrsi.spec1CutInc1,'Enable','on')
    set(fm.mrsi.spec1CutInc2,'Enable','on')
    set(fm.mrsi.spec1CutInc3,'Enable','on')
    set(fm.mrsi.spec1CutReset,'Enable','on')
else
    set(fm.mrsi.spec1CutDec3,'Enable','off')
    set(fm.mrsi.spec1CutDec2,'Enable','off')
    set(fm.mrsi.spec1CutDec1,'Enable','off')
    set(fm.mrsi.spec1CutVal,'Enable','off')
    set(fm.mrsi.spec1CutInc1,'Enable','off')
    set(fm.mrsi.spec1CutInc2,'Enable','off')
    set(fm.mrsi.spec1CutInc3,'Enable','off')
    set(fm.mrsi.spec1CutReset,'Enable','off')
end

%--- spectrum 2: cut-off (apodization) ---
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2CutFlag,'Enable','on')
else
    set(fm.mrsi.spec2CutFlag,'Enable','off')
end
if flag.mrsiSpec2Cut==1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2CutDec3,'Enable','on')
    set(fm.mrsi.spec2CutDec2,'Enable','on')
    set(fm.mrsi.spec2CutDec1,'Enable','on')
    set(fm.mrsi.spec2CutVal,'Enable','on')
    set(fm.mrsi.spec2CutInc1,'Enable','on')
    set(fm.mrsi.spec2CutInc2,'Enable','on')
    set(fm.mrsi.spec2CutInc3,'Enable','on')
    set(fm.mrsi.spec2CutReset,'Enable','on')
    if flag.mrsiSpec1Cut
        set(fm.mrsi.syncCut,'Enable','on')
    else
        set(fm.mrsi.syncCut,'Enable','off')
    end
else
    set(fm.mrsi.spec2CutDec3,'Enable','off')
    set(fm.mrsi.spec2CutDec2,'Enable','off')
    set(fm.mrsi.spec2CutDec1,'Enable','off')
    set(fm.mrsi.spec2CutVal,'Enable','off')
    set(fm.mrsi.spec2CutInc1,'Enable','off')
    set(fm.mrsi.spec2CutInc2,'Enable','off')
    set(fm.mrsi.spec2CutInc3,'Enable','off')
    set(fm.mrsi.spec2CutReset,'Enable','off')
    set(fm.mrsi.syncCut,'Enable','off')
end

%--- Spetrum 1: ZF ---
if flag.mrsiSpec1Zf==1
    set(fm.mrsi.spec1ZfDec3,'Enable','on')
    set(fm.mrsi.spec1ZfDec2,'Enable','on')
    set(fm.mrsi.spec1ZfDec1,'Enable','on')
    set(fm.mrsi.spec1ZfVal,'Enable','on')
    set(fm.mrsi.spec1ZfInc1,'Enable','on')
    set(fm.mrsi.spec1ZfInc2,'Enable','on')
    set(fm.mrsi.spec1ZfInc3,'Enable','on')
    set(fm.mrsi.spec1ZfReset,'Enable','on')
else
    set(fm.mrsi.spec1ZfDec3,'Enable','off')
    set(fm.mrsi.spec1ZfDec2,'Enable','off')
    set(fm.mrsi.spec1ZfDec1,'Enable','off')
    set(fm.mrsi.spec1ZfVal,'Enable','off')
    set(fm.mrsi.spec1ZfInc1,'Enable','off')
    set(fm.mrsi.spec1ZfInc2,'Enable','off')
    set(fm.mrsi.spec1ZfInc3,'Enable','off')
    set(fm.mrsi.spec1ZfReset,'Enable','off')
end

%--- Spectrum 2:s ZF ---
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2ZfFlag,'Enable','on')
else
    set(fm.mrsi.spec2ZfFlag,'Enable','off')
end
if flag.mrsiSpec2Zf==1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2ZfDec3,'Enable','on')
    set(fm.mrsi.spec2ZfDec2,'Enable','on')
    set(fm.mrsi.spec2ZfDec1,'Enable','on')
    set(fm.mrsi.spec2ZfVal,'Enable','on')
    set(fm.mrsi.spec2ZfInc1,'Enable','on')
    set(fm.mrsi.spec2ZfInc2,'Enable','on')
    set(fm.mrsi.spec2ZfInc3,'Enable','on')
    set(fm.mrsi.spec2ZfReset,'Enable','on')
    if flag.mrsiSpec1Zf
        set(fm.mrsi.syncZf,'Enable','on')
    else
        set(fm.mrsi.syncZf,'Enable','off')
    end
else
    set(fm.mrsi.spec2ZfDec3,'Enable','off')
    set(fm.mrsi.spec2ZfDec2,'Enable','off')
    set(fm.mrsi.spec2ZfDec1,'Enable','off')
    set(fm.mrsi.spec2ZfVal,'Enable','off')
    set(fm.mrsi.spec2ZfInc1,'Enable','off')
    set(fm.mrsi.spec2ZfInc2,'Enable','off')
    set(fm.mrsi.spec2ZfInc3,'Enable','off')
    set(fm.mrsi.spec2ZfReset,'Enable','off')
    set(fm.mrsi.syncZf,'Enable','off')
end

%--- exponential line broadening ---
if flag.mrsiSpec1Lb==1
    set(fm.mrsi.spec1LbDec3,'Enable','on')
    set(fm.mrsi.spec1LbDec2,'Enable','on')
    set(fm.mrsi.spec1LbDec1,'Enable','on')
    set(fm.mrsi.spec1LbVal,'Enable','on')
    set(fm.mrsi.spec1LbInc1,'Enable','on')
    set(fm.mrsi.spec1LbInc2,'Enable','on')
    set(fm.mrsi.spec1LbInc3,'Enable','on')
    set(fm.mrsi.spec1LbReset,'Enable','on')
else
    set(fm.mrsi.spec1LbDec3,'Enable','off')
    set(fm.mrsi.spec1LbDec2,'Enable','off')
    set(fm.mrsi.spec1LbDec1,'Enable','off')
    set(fm.mrsi.spec1LbVal,'Enable','off')
    set(fm.mrsi.spec1LbInc1,'Enable','off')
    set(fm.mrsi.spec1LbInc2,'Enable','off')
    set(fm.mrsi.spec1LbInc3,'Enable','off')
    set(fm.mrsi.spec1LbReset,'Enable','off')
end
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2LbFlag,'Enable','on')
else
    set(fm.mrsi.spec2LbFlag,'Enable','off')
end
if flag.mrsiSpec2Lb==1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2LbDec3,'Enable','on')
    set(fm.mrsi.spec2LbDec2,'Enable','on')
    set(fm.mrsi.spec2LbDec1,'Enable','on')
    set(fm.mrsi.spec2LbVal,'Enable','on')
    set(fm.mrsi.spec2LbInc1,'Enable','on')
    set(fm.mrsi.spec2LbInc2,'Enable','on')
    set(fm.mrsi.spec2LbInc3,'Enable','on')
    set(fm.mrsi.spec2LbReset,'Enable','on')
    if flag.mrsiSpec1Lb
        set(fm.mrsi.syncLb,'Enable','on')
    else
        set(fm.mrsi.syncLb,'Enable','off')
    end
else
    set(fm.mrsi.spec2LbDec3,'Enable','off')
    set(fm.mrsi.spec2LbDec2,'Enable','off')
    set(fm.mrsi.spec2LbDec1,'Enable','off')
    set(fm.mrsi.spec2LbVal,'Enable','off')
    set(fm.mrsi.spec2LbInc1,'Enable','off')
    set(fm.mrsi.spec2LbInc2,'Enable','off')
    set(fm.mrsi.spec2LbInc3,'Enable','off')
    set(fm.mrsi.spec2LbReset,'Enable','off')
    set(fm.mrsi.syncLb,'Enable','off')
end

%--- Gaussian line broadening ---
if flag.mrsiSpec1Gb==1
    set(fm.mrsi.spec1GbDec3,'Enable','on')
    set(fm.mrsi.spec1GbDec2,'Enable','on')
    set(fm.mrsi.spec1GbDec1,'Enable','on')
    set(fm.mrsi.spec1GbVal,'Enable','on')
    set(fm.mrsi.spec1GbInc1,'Enable','on')
    set(fm.mrsi.spec1GbInc2,'Enable','on')
    set(fm.mrsi.spec1GbInc3,'Enable','on')
    set(fm.mrsi.spec1GbReset,'Enable','on')
else
    set(fm.mrsi.spec1GbDec3,'Enable','off')
    set(fm.mrsi.spec1GbDec2,'Enable','off')
    set(fm.mrsi.spec1GbDec1,'Enable','off')
    set(fm.mrsi.spec1GbVal,'Enable','off')
    set(fm.mrsi.spec1GbInc1,'Enable','off')
    set(fm.mrsi.spec1GbInc2,'Enable','off')
    set(fm.mrsi.spec1GbInc3,'Enable','off')
    set(fm.mrsi.spec1GbReset,'Enable','off')
end
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2GbFlag,'Enable','on')
else
    set(fm.mrsi.spec2GbFlag,'Enable','off')
end
if flag.mrsiSpec2Gb==1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2GbDec3,'Enable','on')
    set(fm.mrsi.spec2GbDec2,'Enable','on')
    set(fm.mrsi.spec2GbDec1,'Enable','on')
    set(fm.mrsi.spec2GbVal,'Enable','on')
    set(fm.mrsi.spec2GbInc1,'Enable','on')
    set(fm.mrsi.spec2GbInc2,'Enable','on')
    set(fm.mrsi.spec2GbInc3,'Enable','on')
    set(fm.mrsi.spec2GbReset,'Enable','on')
    if flag.mrsiSpec1Gb
        set(fm.mrsi.syncGb,'Enable','on')
    else
        set(fm.mrsi.syncGb,'Enable','off')
    end
else
    set(fm.mrsi.spec2GbDec3,'Enable','off')
    set(fm.mrsi.spec2GbDec2,'Enable','off')
    set(fm.mrsi.spec2GbDec1,'Enable','off')
    set(fm.mrsi.spec2GbVal,'Enable','off')
    set(fm.mrsi.spec2GbInc1,'Enable','off')
    set(fm.mrsi.spec2GbInc2,'Enable','off')
    set(fm.mrsi.spec2GbInc3,'Enable','off')
    set(fm.mrsi.spec2GbReset,'Enable','off')
    set(fm.mrsi.syncGb,'Enable','off')
end

%--- zero order phase correction ---
if flag.mrsiSpec1Phc0
    set(fm.mrsi.spec1Phc0Dec3,'Enable','on')
    set(fm.mrsi.spec1Phc0Dec2,'Enable','on')
    set(fm.mrsi.spec1Phc0Dec1,'Enable','on')
    set(fm.mrsi.spec1Phc0Val,'Enable','on')
    set(fm.mrsi.spec1Phc0Inc1,'Enable','on')
    set(fm.mrsi.spec1Phc0Inc2,'Enable','on')
    set(fm.mrsi.spec1Phc0Inc3,'Enable','on')
    set(fm.mrsi.spec1Phc0Reset,'Enable','on')
else
    set(fm.mrsi.spec1Phc0Dec3,'Enable','off')
    set(fm.mrsi.spec1Phc0Dec2,'Enable','off')
    set(fm.mrsi.spec1Phc0Dec1,'Enable','off')
    set(fm.mrsi.spec1Phc0Val,'Enable','off')
    set(fm.mrsi.spec1Phc0Inc1,'Enable','off')
    set(fm.mrsi.spec1Phc0Inc2,'Enable','off')
    set(fm.mrsi.spec1Phc0Inc3,'Enable','off')
    set(fm.mrsi.spec1Phc0Reset,'Enable','off')
end
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2Phc0Flag,'Enable','on')
else
    set(fm.mrsi.spec2Phc0Flag,'Enable','off')
end
if flag.mrsiSpec2Phc0 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2Phc0Dec3,'Enable','on')
    set(fm.mrsi.spec2Phc0Dec2,'Enable','on')
    set(fm.mrsi.spec2Phc0Dec1,'Enable','on')
    set(fm.mrsi.spec2Phc0Val,'Enable','on')
    set(fm.mrsi.spec2Phc0Inc1,'Enable','on')
    set(fm.mrsi.spec2Phc0Inc2,'Enable','on')
    set(fm.mrsi.spec2Phc0Inc3,'Enable','on')
    set(fm.mrsi.spec2Phc0Reset,'Enable','on')
    if flag.mrsiSpec1Phc0
        set(fm.mrsi.syncPhc0,'Enable','on')
    else
        set(fm.mrsi.syncPhc0,'Enable','off')
    end
else
    set(fm.mrsi.spec2Phc0Dec3,'Enable','off')
    set(fm.mrsi.spec2Phc0Dec2,'Enable','off')
    set(fm.mrsi.spec2Phc0Dec1,'Enable','off')
    set(fm.mrsi.spec2Phc0Val,'Enable','off')
    set(fm.mrsi.spec2Phc0Inc1,'Enable','off')
    set(fm.mrsi.spec2Phc0Inc2,'Enable','off')
    set(fm.mrsi.spec2Phc0Inc3,'Enable','off')
    set(fm.mrsi.spec2Phc0Reset,'Enable','off')
    set(fm.mrsi.syncPhc0,'Enable','off')
end

%--- first order phase correction ---
if flag.mrsiSpec1Phc1
    set(fm.mrsi.spec1Phc1Dec3,'Enable','on')
    set(fm.mrsi.spec1Phc1Dec2,'Enable','on')
    set(fm.mrsi.spec1Phc1Dec1,'Enable','on')
    set(fm.mrsi.spec1Phc1Val,'Enable','on')
    set(fm.mrsi.spec1Phc1Inc1,'Enable','on')
    set(fm.mrsi.spec1Phc1Inc2,'Enable','on')
    set(fm.mrsi.spec1Phc1Inc3,'Enable','on')
    set(fm.mrsi.spec1Phc1Reset,'Enable','on')
else
    set(fm.mrsi.spec1Phc1Dec3,'Enable','off')
    set(fm.mrsi.spec1Phc1Dec2,'Enable','off')
    set(fm.mrsi.spec1Phc1Dec1,'Enable','off')
    set(fm.mrsi.spec1Phc1Val,'Enable','off')
    set(fm.mrsi.spec1Phc1Inc1,'Enable','off')
    set(fm.mrsi.spec1Phc1Inc2,'Enable','off')
    set(fm.mrsi.spec1Phc1Inc3,'Enable','off')
    set(fm.mrsi.spec1Phc1Reset,'Enable','off')
end
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2Phc1Flag,'Enable','on')
else
    set(fm.mrsi.spec2Phc1Flag,'Enable','off')
end
if flag.mrsiSpec2Phc1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2Phc1Dec3,'Enable','on')
    set(fm.mrsi.spec2Phc1Dec2,'Enable','on')
    set(fm.mrsi.spec2Phc1Dec1,'Enable','on')
    set(fm.mrsi.spec2Phc1Val,'Enable','on')
    set(fm.mrsi.spec2Phc1Inc1,'Enable','on')
    set(fm.mrsi.spec2Phc1Inc2,'Enable','on')
    set(fm.mrsi.spec2Phc1Inc3,'Enable','on')
    set(fm.mrsi.spec2Phc1Reset,'Enable','on')
    if flag.mrsiSpec1Phc1
        set(fm.mrsi.syncPhc1,'Enable','on')
    else
        set(fm.mrsi.syncPhc1,'Enable','off')
    end
else
    set(fm.mrsi.spec2Phc1Dec3,'Enable','off')
    set(fm.mrsi.spec2Phc1Dec2,'Enable','off')
    set(fm.mrsi.spec2Phc1Dec1,'Enable','off')
    set(fm.mrsi.spec2Phc1Val,'Enable','off')
    set(fm.mrsi.spec2Phc1Inc1,'Enable','off')
    set(fm.mrsi.spec2Phc1Inc2,'Enable','off')
    set(fm.mrsi.spec2Phc1Inc3,'Enable','off')
    set(fm.mrsi.spec2Phc1Reset,'Enable','off')
    set(fm.mrsi.syncPhc1,'Enable','off')
end

%--- amplitude scaling: spectrum 1 ---
if flag.mrsiSpec1Scale==1
    set(fm.mrsi.spec1ScaleDec3,'Enable','on')
    set(fm.mrsi.spec1ScaleDec2,'Enable','on')
    set(fm.mrsi.spec1ScaleDec1,'Enable','on')
    set(fm.mrsi.spec1ScaleVal,'Enable','on')
    set(fm.mrsi.spec1ScaleInc1,'Enable','on')
    set(fm.mrsi.spec1ScaleInc2,'Enable','on')
    set(fm.mrsi.spec1ScaleInc3,'Enable','on')
    set(fm.mrsi.spec1ScaleReset,'Enable','on')
else
    set(fm.mrsi.spec1ScaleDec3,'Enable','off')
    set(fm.mrsi.spec1ScaleDec2,'Enable','off')
    set(fm.mrsi.spec1ScaleDec1,'Enable','off')
    set(fm.mrsi.spec1ScaleVal,'Enable','off')
    set(fm.mrsi.spec1ScaleInc1,'Enable','off')
    set(fm.mrsi.spec1ScaleInc2,'Enable','off')
    set(fm.mrsi.spec1ScaleInc3,'Enable','off')
    set(fm.mrsi.spec1ScaleReset,'Enable','off')
end

%--- amplitude scaling: spectrum 2 ---
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2ScaleFlag,'Enable','on')
else
    set(fm.mrsi.spec2ScaleFlag,'Enable','off')
end
if flag.mrsiSpec2Scale==1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2ScaleDec3,'Enable','on')
    set(fm.mrsi.spec2ScaleDec2,'Enable','on')
    set(fm.mrsi.spec2ScaleDec1,'Enable','on')
    set(fm.mrsi.spec2ScaleVal,'Enable','on')
    set(fm.mrsi.spec2ScaleInc1,'Enable','on')
    set(fm.mrsi.spec2ScaleInc2,'Enable','on')
    set(fm.mrsi.spec2ScaleInc3,'Enable','on')
    set(fm.mrsi.spec2ScaleReset,'Enable','on')
    if flag.mrsiSpec1Scale
        set(fm.mrsi.syncScale,'Enable','on')
    else
        set(fm.mrsi.syncScale,'Enable','off')
    end
else
    set(fm.mrsi.spec2ScaleDec3,'Enable','off')
    set(fm.mrsi.spec2ScaleDec2,'Enable','off')
    set(fm.mrsi.spec2ScaleDec1,'Enable','off')
    set(fm.mrsi.spec2ScaleVal,'Enable','off')
    set(fm.mrsi.spec2ScaleInc1,'Enable','off')
    set(fm.mrsi.spec2ScaleInc2,'Enable','off')
    set(fm.mrsi.spec2ScaleInc3,'Enable','off')
    set(fm.mrsi.spec2ScaleReset,'Enable','off')
    set(fm.mrsi.syncScale,'Enable','off')
end

%--- frequency shift: spectrum 1 ---
if flag.mrsiSpec1Shift==1
    set(fm.mrsi.spec1ShiftDec3,'Enable','on')
    set(fm.mrsi.spec1ShiftDec2,'Enable','on')
    set(fm.mrsi.spec1ShiftDec1,'Enable','on')
    set(fm.mrsi.spec1ShiftVal,'Enable','on')
    set(fm.mrsi.spec1ShiftInc1,'Enable','on')
    set(fm.mrsi.spec1ShiftInc2,'Enable','on')
    set(fm.mrsi.spec1ShiftInc3,'Enable','on')
    set(fm.mrsi.spec1ShiftReset,'Enable','on')
else
    set(fm.mrsi.spec1ShiftDec3,'Enable','off')
    set(fm.mrsi.spec1ShiftDec2,'Enable','off')
    set(fm.mrsi.spec1ShiftDec1,'Enable','off')
    set(fm.mrsi.spec1ShiftVal,'Enable','off')
    set(fm.mrsi.spec1ShiftInc1,'Enable','off')
    set(fm.mrsi.spec1ShiftInc2,'Enable','off')
    set(fm.mrsi.spec1ShiftInc3,'Enable','off')
    set(fm.mrsi.spec1ShiftReset,'Enable','off')
end

%--- frequency shift: spectrum 2 ---
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2ShiftFlag,'Enable','on')
else
    set(fm.mrsi.spec2ShiftFlag,'Enable','off')
end
if flag.mrsiSpec2Shift==1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2ShiftDec3,'Enable','on')
    set(fm.mrsi.spec2ShiftDec2,'Enable','on')
    set(fm.mrsi.spec2ShiftDec1,'Enable','on')
    set(fm.mrsi.spec2ShiftVal,'Enable','on')
    set(fm.mrsi.spec2ShiftInc1,'Enable','on')
    set(fm.mrsi.spec2ShiftInc2,'Enable','on')
    set(fm.mrsi.spec2ShiftInc3,'Enable','on')
    set(fm.mrsi.spec2ShiftReset,'Enable','on')
    if flag.mrsiSpec1Shift
        set(fm.mrsi.syncShift,'Enable','on')
    else
        set(fm.mrsi.syncShift,'Enable','off')
    end
else
    set(fm.mrsi.spec2ShiftDec3,'Enable','off')
    set(fm.mrsi.spec2ShiftDec2,'Enable','off')
    set(fm.mrsi.spec2ShiftDec1,'Enable','off')
    set(fm.mrsi.spec2ShiftVal,'Enable','off')
    set(fm.mrsi.spec2ShiftInc1,'Enable','off')
    set(fm.mrsi.spec2ShiftInc2,'Enable','off')
    set(fm.mrsi.spec2ShiftInc3,'Enable','off')
    set(fm.mrsi.spec2ShiftReset,'Enable','off')
    set(fm.mrsi.syncShift,'Enable','off')
end

%--- baseline offset: spectrum 1 ---
if flag.mrsiSpec1Offset==1
    set(fm.mrsi.spec1OffsetDec3,'Enable','on')
    set(fm.mrsi.spec1OffsetDec2,'Enable','on')
    set(fm.mrsi.spec1OffsetDec1,'Enable','on')
    set(fm.mrsi.spec1OffsetVal,'Enable','on')
    set(fm.mrsi.spec1OffsetInc1,'Enable','on')
    set(fm.mrsi.spec1OffsetInc2,'Enable','on')
    set(fm.mrsi.spec1OffsetInc3,'Enable','on')
    set(fm.mrsi.spec1OffsetReset,'Enable','on')
else
    set(fm.mrsi.spec1OffsetDec3,'Enable','off')
    set(fm.mrsi.spec1OffsetDec2,'Enable','off')
    set(fm.mrsi.spec1OffsetDec1,'Enable','off')
    set(fm.mrsi.spec1OffsetVal,'Enable','off')
    set(fm.mrsi.spec1OffsetInc1,'Enable','off')
    set(fm.mrsi.spec1OffsetInc2,'Enable','off')
    set(fm.mrsi.spec1OffsetInc3,'Enable','off')
    set(fm.mrsi.spec1OffsetReset,'Enable','off')
end

%--- baseline offset: spectrum 2 ---
if flag.mrsiNumSpec==1
    set(fm.mrsi.spec2OffsetFlag,'Enable','on')
else
    set(fm.mrsi.spec2OffsetFlag,'Enable','off')
end
if flag.mrsiSpec2Offset==1 && flag.mrsiNumSpec==1
    set(fm.mrsi.spec2OffsetDec3,'Enable','on')
    set(fm.mrsi.spec2OffsetDec2,'Enable','on')
    set(fm.mrsi.spec2OffsetDec1,'Enable','on')
    set(fm.mrsi.spec2OffsetVal,'Enable','on')
    set(fm.mrsi.spec2OffsetInc1,'Enable','on')
    set(fm.mrsi.spec2OffsetInc2,'Enable','on')
    set(fm.mrsi.spec2OffsetInc3,'Enable','on')
    set(fm.mrsi.spec2OffsetReset,'Enable','on')
    if flag.mrsiSpec1Offset
        set(fm.mrsi.syncOffset,'Enable','on')
    else
        set(fm.mrsi.syncOffset,'Enable','off')
    end
else
    set(fm.mrsi.spec2OffsetDec3,'Enable','off')
    set(fm.mrsi.spec2OffsetDec2,'Enable','off')
    set(fm.mrsi.spec2OffsetDec1,'Enable','off')
    set(fm.mrsi.spec2OffsetVal,'Enable','off')
    set(fm.mrsi.spec2OffsetInc1,'Enable','off')
    set(fm.mrsi.spec2OffsetInc2,'Enable','off')
    set(fm.mrsi.spec2OffsetInc3,'Enable','off')
    set(fm.mrsi.spec2OffsetReset,'Enable','off')
    set(fm.mrsi.syncOffset,'Enable','off')
end

%--- ppm calib update ---
set(fm.mrsi.ppmCalib,'String',sprintf('%.4f',mrsi.ppmCalib))

%--- visualization of specific frequency ---
if flag.mrsiPpmShowPos
    set(fm.mrsi.ppmShowPosVal,'Enable','on')
    set(fm.mrsi.ppmShowPosAssign,'Enable','on')
    set(fm.mrsi.ppmShowPosMirr,'Enable','on')
else
    set(fm.mrsi.ppmShowPosVal,'Enable','off')
    set(fm.mrsi.ppmShowPosAssign,'Enable','off')
    set(fm.mrsi.ppmShowPosMirr,'Enable','off')
end
set(fm.mrsi.ppmShowPosVal,'String',sprintf('%.4f',mrsi.ppmShowPos))


%--- visualization: frequency ---
if flag.mrsiPpmShow         % direct
    set(fm.mrsi.ppmShowMinDecr,'Enable','on')
    set(fm.mrsi.ppmShowMin,'Enable','on')
    set(fm.mrsi.ppmShowMinIncr,'Enable','on')
    set(fm.mrsi.ppmShowMaxDecr,'Enable','on')
    set(fm.mrsi.ppmShowMax,'Enable','on')
    set(fm.mrsi.ppmShowMaxIncr,'Enable','on')
else                        % full SW
    set(fm.mrsi.ppmShowMinDecr,'Enable','off')
    set(fm.mrsi.ppmShowMin,'Enable','off')
    set(fm.mrsi.ppmShowMinIncr,'Enable','off')
    set(fm.mrsi.ppmShowMaxDecr,'Enable','off')
    set(fm.mrsi.ppmShowMax,'Enable','off')
    set(fm.mrsi.ppmShowMaxIncr,'Enable','off')
end

%--- visualization: amplitude ---
if flag.mrsiAmpl             % direct
    set(fm.mrsi.amplMinDecr,'Enable','on')
    set(fm.mrsi.amplMin,'Enable','on')
    set(fm.mrsi.amplMinIncr,'Enable','on')
    set(fm.mrsi.amplMaxDecr,'Enable','on')
    set(fm.mrsi.amplMax,'Enable','on')
    set(fm.mrsi.amplMaxIncr,'Enable','on')
else                        % auto
    set(fm.mrsi.amplMinDecr,'Enable','off')
    set(fm.mrsi.amplMin,'Enable','off')
    set(fm.mrsi.amplMinIncr,'Enable','off')
    set(fm.mrsi.amplMaxDecr,'Enable','off')
    set(fm.mrsi.amplMax,'Enable','off')
    set(fm.mrsi.amplMaxIncr,'Enable','off')
end

%--- baseline offset mode ---
if flag.mrsiOffset          % ppm range
    set(fm.mrsi.ppmOffsetMinDecr,'Enable','on')
    set(fm.mrsi.ppmOffsetMin,'Enable','on')
    set(fm.mrsi.ppmOffsetMinIncr,'Enable','on')
    set(fm.mrsi.ppmOffsetMaxDecr,'Enable','on')
    set(fm.mrsi.ppmOffsetMax,'Enable','on')
    set(fm.mrsi.ppmOffsetMaxIncr,'Enable','on')
    set(fm.mrsi.offsetDec3,'Enable','off')
    set(fm.mrsi.offsetDec2,'Enable','off')
    set(fm.mrsi.offsetDec1,'Enable','off')
    set(fm.mrsi.offsetVal,'Enable','off')
    set(fm.mrsi.offsetInc1,'Enable','off')
    set(fm.mrsi.offsetInc2,'Enable','off')
    set(fm.mrsi.offsetInc3,'Enable','off')
    set(fm.mrsi.offsetAssign,'Enable','off')
else                        % direct value assignment
    set(fm.mrsi.ppmOffsetMinDecr,'Enable','off')
    set(fm.mrsi.ppmOffsetMin,'Enable','off')
    set(fm.mrsi.ppmOffsetMinIncr,'Enable','off')
    set(fm.mrsi.ppmOffsetMaxDecr,'Enable','off')
    set(fm.mrsi.ppmOffsetMax,'Enable','off')
    set(fm.mrsi.ppmOffsetMaxIncr,'Enable','off')
    set(fm.mrsi.offsetDec3,'Enable','on')
    set(fm.mrsi.offsetDec2,'Enable','on')
    set(fm.mrsi.offsetDec1,'Enable','on')
    set(fm.mrsi.offsetVal,'Enable','on')
    set(fm.mrsi.offsetInc1,'Enable','on')
    set(fm.mrsi.offsetInc2,'Enable','on')
    set(fm.mrsi.offsetInc3,'Enable','on')
    set(fm.mrsi.offsetAssign,'Enable','on')
end
set(fm.mrsi.offsetVal,'String',sprintf('%.1f',mrsi.offsetVal))



end
