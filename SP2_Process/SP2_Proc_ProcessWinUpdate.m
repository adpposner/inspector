%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_ProcessWinUpdate
%% 
%%  'Data' window update
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag pars proc

FCTNAME = 'SP2_Proc_ProcessWinUpdate';


%--- processing and export data format ---
if flag.procDataFormat==1            % matlab format
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathMat)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathMat)
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathMat)
elseif flag.procDataFormat==2        % RAG text format 
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathTxt)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathTxt)
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathTxt)
elseif flag.procDataFormat==3        % metabolite (.par) format 
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathPar)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathPar)
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathMat)    % note: .mat
elseif flag.procDataFormat==4        % Provencher LCModel data
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathRaw)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathRaw)
    set(fm.proc.exptDataPath,'String',proc.expt.dataPathRaw)
else                                 % Provencher LCModel result
    set(fm.proc.spec1DataPath,'String',proc.spec1.dataPathCoord)
    set(fm.proc.spec2DataPath,'String',proc.spec2.dataPathCoord)
    % note that the export field is not update/changed
end

%--- data format ---
if flag.procData==2         % directly from processing sheet
    set(fm.proc.spec1DataPath,'Enable','on')
    set(fm.proc.spec1DataSelect,'Enable','on')
else                        % from data sheet
    set(fm.proc.spec1DataPath,'Enable','off')
    set(fm.proc.spec1DataSelect,'Enable','off')
end

%--- 1 vs. 2 spectra ---
if flag.procNumSpec==0      % single spectrum mode
    set(fm.proc.spec2DataLab,'Color',pars.bgTextColor)
    set(fm.proc.spec2DataPath,'Enable','off')
    set(fm.proc.spec2DataSelect,'Enable','off')
    set(fm.proc.spec2DataLoad,'Enable','off')
else                        % two spectra mode
    set(fm.proc.spec2DataLab,'Color',pars.fgTextColor)
    if flag.procData==2     % directly from processing sheet && 2 spectra mode
        set(fm.proc.spec2DataPath,'Enable','on')
        set(fm.proc.spec2DataSelect,'Enable','on')
    else                    % from data sheet 
        set(fm.proc.spec2DataPath,'Enable','off')
        set(fm.proc.spec2DataSelect,'Enable','off')
    end
    set(fm.proc.spec2DataLoad,'Enable','on')
end

%--- spectrum 1: cut-off (apodization) ---
if flag.procSpec1Cut==1
    set(fm.proc.spec1CutDec3,'Enable','on')
    set(fm.proc.spec1CutDec2,'Enable','on')
    set(fm.proc.spec1CutDec1,'Enable','on')
    set(fm.proc.spec1CutVal,'Enable','on')
    set(fm.proc.spec1CutInc1,'Enable','on')
    set(fm.proc.spec1CutInc2,'Enable','on')
    set(fm.proc.spec1CutInc3,'Enable','on')
    set(fm.proc.spec1CutReset,'Enable','on')
else
    set(fm.proc.spec1CutDec3,'Enable','off')
    set(fm.proc.spec1CutDec2,'Enable','off')
    set(fm.proc.spec1CutDec1,'Enable','off')
    set(fm.proc.spec1CutVal,'Enable','off')
    set(fm.proc.spec1CutInc1,'Enable','off')
    set(fm.proc.spec1CutInc2,'Enable','off')
    set(fm.proc.spec1CutInc3,'Enable','off')
    set(fm.proc.spec1CutReset,'Enable','off')
end

%--- spectrum 2: cut-off (apodization) ---
if flag.procNumSpec==1
    set(fm.proc.spec2CutFlag,'Enable','on')
else
    set(fm.proc.spec2CutFlag,'Enable','off')
end
if flag.procSpec2Cut==1 && flag.procNumSpec==1
    set(fm.proc.spec2CutDec3,'Enable','on')
    set(fm.proc.spec2CutDec2,'Enable','on')
    set(fm.proc.spec2CutDec1,'Enable','on')
    set(fm.proc.spec2CutVal,'Enable','on')
    set(fm.proc.spec2CutInc1,'Enable','on')
    set(fm.proc.spec2CutInc2,'Enable','on')
    set(fm.proc.spec2CutInc3,'Enable','on')
    set(fm.proc.spec2CutReset,'Enable','on')
    if flag.procSpec1Cut
        set(fm.proc.syncCut,'Enable','on')
    else
        set(fm.proc.syncCut,'Enable','off')
    end
else
    set(fm.proc.spec2CutDec3,'Enable','off')
    set(fm.proc.spec2CutDec2,'Enable','off')
    set(fm.proc.spec2CutDec1,'Enable','off')
    set(fm.proc.spec2CutVal,'Enable','off')
    set(fm.proc.spec2CutInc1,'Enable','off')
    set(fm.proc.spec2CutInc2,'Enable','off')
    set(fm.proc.spec2CutInc3,'Enable','off')
    set(fm.proc.spec2CutReset,'Enable','off')
    set(fm.proc.syncCut,'Enable','off')
end

%--- Spetrum 1: ZF ---
if flag.procSpec1Zf==1
    set(fm.proc.spec1ZfDec3,'Enable','on')
    set(fm.proc.spec1ZfDec2,'Enable','on')
    set(fm.proc.spec1ZfDec1,'Enable','on')
    set(fm.proc.spec1ZfVal,'Enable','on')
    set(fm.proc.spec1ZfInc1,'Enable','on')
    set(fm.proc.spec1ZfInc2,'Enable','on')
    set(fm.proc.spec1ZfInc3,'Enable','on')
    set(fm.proc.spec1ZfReset,'Enable','on')
else
    set(fm.proc.spec1ZfDec3,'Enable','off')
    set(fm.proc.spec1ZfDec2,'Enable','off')
    set(fm.proc.spec1ZfDec1,'Enable','off')
    set(fm.proc.spec1ZfVal,'Enable','off')
    set(fm.proc.spec1ZfInc1,'Enable','off')
    set(fm.proc.spec1ZfInc2,'Enable','off')
    set(fm.proc.spec1ZfInc3,'Enable','off')
    set(fm.proc.spec1ZfReset,'Enable','off')
end

%--- Spectrum 2:s ZF ---
if flag.procNumSpec==1
    set(fm.proc.spec2ZfFlag,'Enable','on')
else
    set(fm.proc.spec2ZfFlag,'Enable','off')
end
if flag.procSpec2Zf==1 && flag.procNumSpec==1
    set(fm.proc.spec2ZfDec3,'Enable','on')
    set(fm.proc.spec2ZfDec2,'Enable','on')
    set(fm.proc.spec2ZfDec1,'Enable','on')
    set(fm.proc.spec2ZfVal,'Enable','on')
    set(fm.proc.spec2ZfInc1,'Enable','on')
    set(fm.proc.spec2ZfInc2,'Enable','on')
    set(fm.proc.spec2ZfInc3,'Enable','on')
    set(fm.proc.spec2ZfReset,'Enable','on')
    if flag.procSpec1Zf
        set(fm.proc.syncZf,'Enable','on')
    else
        set(fm.proc.syncZf,'Enable','off')
    end
else
    set(fm.proc.spec2ZfDec3,'Enable','off')
    set(fm.proc.spec2ZfDec2,'Enable','off')
    set(fm.proc.spec2ZfDec1,'Enable','off')
    set(fm.proc.spec2ZfVal,'Enable','off')
    set(fm.proc.spec2ZfInc1,'Enable','off')
    set(fm.proc.spec2ZfInc2,'Enable','off')
    set(fm.proc.spec2ZfInc3,'Enable','off')
    set(fm.proc.spec2ZfReset,'Enable','off')
    set(fm.proc.syncZf,'Enable','off')
end

%--- exponential line broadening ---
if flag.procSpec1Lb==1
    set(fm.proc.spec1LbDec3,'Enable','on')
    set(fm.proc.spec1LbDec2,'Enable','on')
    set(fm.proc.spec1LbDec1,'Enable','on')
    set(fm.proc.spec1LbVal,'Enable','on')
    set(fm.proc.spec1LbInc1,'Enable','on')
    set(fm.proc.spec1LbInc2,'Enable','on')
    set(fm.proc.spec1LbInc3,'Enable','on')
    set(fm.proc.spec1LbReset,'Enable','on')
else
    set(fm.proc.spec1LbDec3,'Enable','off')
    set(fm.proc.spec1LbDec2,'Enable','off')
    set(fm.proc.spec1LbDec1,'Enable','off')
    set(fm.proc.spec1LbVal,'Enable','off')
    set(fm.proc.spec1LbInc1,'Enable','off')
    set(fm.proc.spec1LbInc2,'Enable','off')
    set(fm.proc.spec1LbInc3,'Enable','off')
    set(fm.proc.spec1LbReset,'Enable','off')
end
if flag.procNumSpec==1
    set(fm.proc.spec2LbFlag,'Enable','on')
else
    set(fm.proc.spec2LbFlag,'Enable','off')
end
if flag.procSpec2Lb==1 && flag.procNumSpec==1
    set(fm.proc.spec2LbDec3,'Enable','on')
    set(fm.proc.spec2LbDec2,'Enable','on')
    set(fm.proc.spec2LbDec1,'Enable','on')
    set(fm.proc.spec2LbVal,'Enable','on')
    set(fm.proc.spec2LbInc1,'Enable','on')
    set(fm.proc.spec2LbInc2,'Enable','on')
    set(fm.proc.spec2LbInc3,'Enable','on')
    set(fm.proc.spec2LbReset,'Enable','on')
    if flag.procSpec1Lb
        set(fm.proc.syncLb,'Enable','on')
    else
        set(fm.proc.syncLb,'Enable','off')
    end
else
    set(fm.proc.spec2LbDec3,'Enable','off')
    set(fm.proc.spec2LbDec2,'Enable','off')
    set(fm.proc.spec2LbDec1,'Enable','off')
    set(fm.proc.spec2LbVal,'Enable','off')
    set(fm.proc.spec2LbInc1,'Enable','off')
    set(fm.proc.spec2LbInc2,'Enable','off')
    set(fm.proc.spec2LbInc3,'Enable','off')
    set(fm.proc.spec2LbReset,'Enable','off')
    set(fm.proc.syncLb,'Enable','off')
end

%--- Gaussian line broadening ---
if flag.procSpec1Gb==1
    set(fm.proc.spec1GbDec3,'Enable','on')
    set(fm.proc.spec1GbDec2,'Enable','on')
    set(fm.proc.spec1GbDec1,'Enable','on')
    set(fm.proc.spec1GbVal,'Enable','on')
    set(fm.proc.spec1GbInc1,'Enable','on')
    set(fm.proc.spec1GbInc2,'Enable','on')
    set(fm.proc.spec1GbInc3,'Enable','on')
    set(fm.proc.spec1GbReset,'Enable','on')
else
    set(fm.proc.spec1GbDec3,'Enable','off')
    set(fm.proc.spec1GbDec2,'Enable','off')
    set(fm.proc.spec1GbDec1,'Enable','off')
    set(fm.proc.spec1GbVal,'Enable','off')
    set(fm.proc.spec1GbInc1,'Enable','off')
    set(fm.proc.spec1GbInc2,'Enable','off')
    set(fm.proc.spec1GbInc3,'Enable','off')
    set(fm.proc.spec1GbReset,'Enable','off')
end
if flag.procNumSpec==1
    set(fm.proc.spec2GbFlag,'Enable','on')
else
    set(fm.proc.spec2GbFlag,'Enable','off')
end
if flag.procSpec2Gb==1 && flag.procNumSpec==1
    set(fm.proc.spec2GbDec3,'Enable','on')
    set(fm.proc.spec2GbDec2,'Enable','on')
    set(fm.proc.spec2GbDec1,'Enable','on')
    set(fm.proc.spec2GbVal,'Enable','on')
    set(fm.proc.spec2GbInc1,'Enable','on')
    set(fm.proc.spec2GbInc2,'Enable','on')
    set(fm.proc.spec2GbInc3,'Enable','on')
    set(fm.proc.spec2GbReset,'Enable','on')
    if flag.procSpec1Gb
        set(fm.proc.syncGb,'Enable','on')
    else
        set(fm.proc.syncGb,'Enable','off')
    end
else
    set(fm.proc.spec2GbDec3,'Enable','off')
    set(fm.proc.spec2GbDec2,'Enable','off')
    set(fm.proc.spec2GbDec1,'Enable','off')
    set(fm.proc.spec2GbVal,'Enable','off')
    set(fm.proc.spec2GbInc1,'Enable','off')
    set(fm.proc.spec2GbInc2,'Enable','off')
    set(fm.proc.spec2GbInc3,'Enable','off')
    set(fm.proc.spec2GbReset,'Enable','off')
    set(fm.proc.syncGb,'Enable','off')
end

%--- zero order phase correction ---
if flag.procSpec1Phc0
    set(fm.proc.spec1Phc0Dec3,'Enable','on')
    set(fm.proc.spec1Phc0Dec2,'Enable','on')
    set(fm.proc.spec1Phc0Dec1,'Enable','on')
    set(fm.proc.spec1Phc0Val,'Enable','on')
    set(fm.proc.spec1Phc0Inc1,'Enable','on')
    set(fm.proc.spec1Phc0Inc2,'Enable','on')
    set(fm.proc.spec1Phc0Inc3,'Enable','on')
    set(fm.proc.spec1Phc0Reset,'Enable','on')
else
    set(fm.proc.spec1Phc0Dec3,'Enable','off')
    set(fm.proc.spec1Phc0Dec2,'Enable','off')
    set(fm.proc.spec1Phc0Dec1,'Enable','off')
    set(fm.proc.spec1Phc0Val,'Enable','off')
    set(fm.proc.spec1Phc0Inc1,'Enable','off')
    set(fm.proc.spec1Phc0Inc2,'Enable','off')
    set(fm.proc.spec1Phc0Inc3,'Enable','off')
    set(fm.proc.spec1Phc0Reset,'Enable','off')
end
if flag.procNumSpec==1
    set(fm.proc.spec2Phc0Flag,'Enable','on')
else
    set(fm.proc.spec2Phc0Flag,'Enable','off')
end
if flag.procSpec2Phc0 && flag.procNumSpec==1
    set(fm.proc.spec2Phc0Dec3,'Enable','on')
    set(fm.proc.spec2Phc0Dec2,'Enable','on')
    set(fm.proc.spec2Phc0Dec1,'Enable','on')
    set(fm.proc.spec2Phc0Val,'Enable','on')
    set(fm.proc.spec2Phc0Inc1,'Enable','on')
    set(fm.proc.spec2Phc0Inc2,'Enable','on')
    set(fm.proc.spec2Phc0Inc3,'Enable','on')
    set(fm.proc.spec2Phc0Reset,'Enable','on')
    if flag.procSpec1Phc0
        set(fm.proc.syncPhc0,'Enable','on')
    else
        set(fm.proc.syncPhc0,'Enable','off')
    end
else
    set(fm.proc.spec2Phc0Dec3,'Enable','off')
    set(fm.proc.spec2Phc0Dec2,'Enable','off')
    set(fm.proc.spec2Phc0Dec1,'Enable','off')
    set(fm.proc.spec2Phc0Val,'Enable','off')
    set(fm.proc.spec2Phc0Inc1,'Enable','off')
    set(fm.proc.spec2Phc0Inc2,'Enable','off')
    set(fm.proc.spec2Phc0Inc3,'Enable','off')
    set(fm.proc.spec2Phc0Reset,'Enable','off')
    set(fm.proc.syncPhc0,'Enable','off')
end

%--- first order phase correction ---
if flag.procSpec1Phc1
    set(fm.proc.spec1Phc1Dec3,'Enable','on')
    set(fm.proc.spec1Phc1Dec2,'Enable','on')
    set(fm.proc.spec1Phc1Dec1,'Enable','on')
    set(fm.proc.spec1Phc1Val,'Enable','on')
    set(fm.proc.spec1Phc1Inc1,'Enable','on')
    set(fm.proc.spec1Phc1Inc2,'Enable','on')
    set(fm.proc.spec1Phc1Inc3,'Enable','on')
    set(fm.proc.spec1Phc1Reset,'Enable','on')
else
    set(fm.proc.spec1Phc1Dec3,'Enable','off')
    set(fm.proc.spec1Phc1Dec2,'Enable','off')
    set(fm.proc.spec1Phc1Dec1,'Enable','off')
    set(fm.proc.spec1Phc1Val,'Enable','off')
    set(fm.proc.spec1Phc1Inc1,'Enable','off')
    set(fm.proc.spec1Phc1Inc2,'Enable','off')
    set(fm.proc.spec1Phc1Inc3,'Enable','off')
    set(fm.proc.spec1Phc1Reset,'Enable','off')
end
if flag.procNumSpec==1
    set(fm.proc.spec2Phc1Flag,'Enable','on')
else
    set(fm.proc.spec2Phc1Flag,'Enable','off')
end
if flag.procSpec2Phc1 && flag.procNumSpec==1
    set(fm.proc.spec2Phc1Dec3,'Enable','on')
    set(fm.proc.spec2Phc1Dec2,'Enable','on')
    set(fm.proc.spec2Phc1Dec1,'Enable','on')
    set(fm.proc.spec2Phc1Val,'Enable','on')
    set(fm.proc.spec2Phc1Inc1,'Enable','on')
    set(fm.proc.spec2Phc1Inc2,'Enable','on')
    set(fm.proc.spec2Phc1Inc3,'Enable','on')
    set(fm.proc.spec2Phc1Reset,'Enable','on')
    if flag.procSpec1Phc1
        set(fm.proc.syncPhc1,'Enable','on')
    else
        set(fm.proc.syncPhc1,'Enable','off')
    end
else
    set(fm.proc.spec2Phc1Dec3,'Enable','off')
    set(fm.proc.spec2Phc1Dec2,'Enable','off')
    set(fm.proc.spec2Phc1Dec1,'Enable','off')
    set(fm.proc.spec2Phc1Val,'Enable','off')
    set(fm.proc.spec2Phc1Inc1,'Enable','off')
    set(fm.proc.spec2Phc1Inc2,'Enable','off')
    set(fm.proc.spec2Phc1Inc3,'Enable','off')
    set(fm.proc.spec2Phc1Reset,'Enable','off')
    set(fm.proc.syncPhc1,'Enable','off')
end

%--- amplitude scaling: spectrum 1 ---
if flag.procSpec1Scale==1
    set(fm.proc.spec1ScaleDec3,'Enable','on')
    set(fm.proc.spec1ScaleDec2,'Enable','on')
    set(fm.proc.spec1ScaleDec1,'Enable','on')
    set(fm.proc.spec1ScaleVal,'Enable','on')
    set(fm.proc.spec1ScaleInc1,'Enable','on')
    set(fm.proc.spec1ScaleInc2,'Enable','on')
    set(fm.proc.spec1ScaleInc3,'Enable','on')
    set(fm.proc.spec1ScaleReset,'Enable','on')
else
    set(fm.proc.spec1ScaleDec3,'Enable','off')
    set(fm.proc.spec1ScaleDec2,'Enable','off')
    set(fm.proc.spec1ScaleDec1,'Enable','off')
    set(fm.proc.spec1ScaleVal,'Enable','off')
    set(fm.proc.spec1ScaleInc1,'Enable','off')
    set(fm.proc.spec1ScaleInc2,'Enable','off')
    set(fm.proc.spec1ScaleInc3,'Enable','off')
    set(fm.proc.spec1ScaleReset,'Enable','off')
end

%--- amplitude scaling: spectrum 2 ---
if flag.procNumSpec==1
    set(fm.proc.spec2ScaleFlag,'Enable','on')
else
    set(fm.proc.spec2ScaleFlag,'Enable','off')
end
if flag.procSpec2Scale==1 && flag.procNumSpec==1
    set(fm.proc.spec2ScaleDec3,'Enable','on')
    set(fm.proc.spec2ScaleDec2,'Enable','on')
    set(fm.proc.spec2ScaleDec1,'Enable','on')
    set(fm.proc.spec2ScaleVal,'Enable','on')
    set(fm.proc.spec2ScaleInc1,'Enable','on')
    set(fm.proc.spec2ScaleInc2,'Enable','on')
    set(fm.proc.spec2ScaleInc3,'Enable','on')
    set(fm.proc.spec2ScaleReset,'Enable','on')
    if flag.procSpec1Scale
        set(fm.proc.syncScale,'Enable','on')
    else
        set(fm.proc.syncScale,'Enable','off')
    end
else
    set(fm.proc.spec2ScaleDec3,'Enable','off')
    set(fm.proc.spec2ScaleDec2,'Enable','off')
    set(fm.proc.spec2ScaleDec1,'Enable','off')
    set(fm.proc.spec2ScaleVal,'Enable','off')
    set(fm.proc.spec2ScaleInc1,'Enable','off')
    set(fm.proc.spec2ScaleInc2,'Enable','off')
    set(fm.proc.spec2ScaleInc3,'Enable','off')
    set(fm.proc.spec2ScaleReset,'Enable','off')
    set(fm.proc.syncScale,'Enable','off')
end

%--- frequency shift: spectrum 1 ---
if flag.procSpec1Shift==1
    set(fm.proc.spec1ShiftDec3,'Enable','on')
    set(fm.proc.spec1ShiftDec2,'Enable','on')
    set(fm.proc.spec1ShiftDec1,'Enable','on')
    set(fm.proc.spec1ShiftVal,'Enable','on')
    set(fm.proc.spec1ShiftInc1,'Enable','on')
    set(fm.proc.spec1ShiftInc2,'Enable','on')
    set(fm.proc.spec1ShiftInc3,'Enable','on')
    set(fm.proc.spec1ShiftReset,'Enable','on')
else
    set(fm.proc.spec1ShiftDec3,'Enable','off')
    set(fm.proc.spec1ShiftDec2,'Enable','off')
    set(fm.proc.spec1ShiftDec1,'Enable','off')
    set(fm.proc.spec1ShiftVal,'Enable','off')
    set(fm.proc.spec1ShiftInc1,'Enable','off')
    set(fm.proc.spec1ShiftInc2,'Enable','off')
    set(fm.proc.spec1ShiftInc3,'Enable','off')
    set(fm.proc.spec1ShiftReset,'Enable','off')
end

%--- frequency shift: spectrum 2 ---
if flag.procNumSpec==1
    set(fm.proc.spec2ShiftFlag,'Enable','on')
else
    set(fm.proc.spec2ShiftFlag,'Enable','off')
end
if flag.procSpec2Shift==1 && flag.procNumSpec==1
    set(fm.proc.spec2ShiftDec3,'Enable','on')
    set(fm.proc.spec2ShiftDec2,'Enable','on')
    set(fm.proc.spec2ShiftDec1,'Enable','on')
    set(fm.proc.spec2ShiftVal,'Enable','on')
    set(fm.proc.spec2ShiftInc1,'Enable','on')
    set(fm.proc.spec2ShiftInc2,'Enable','on')
    set(fm.proc.spec2ShiftInc3,'Enable','on')
    set(fm.proc.spec2ShiftReset,'Enable','on')
    if flag.procSpec1Shift
        set(fm.proc.syncShift,'Enable','on')
    else
        set(fm.proc.syncShift,'Enable','off')
    end
else
    set(fm.proc.spec2ShiftDec3,'Enable','off')
    set(fm.proc.spec2ShiftDec2,'Enable','off')
    set(fm.proc.spec2ShiftDec1,'Enable','off')
    set(fm.proc.spec2ShiftVal,'Enable','off')
    set(fm.proc.spec2ShiftInc1,'Enable','off')
    set(fm.proc.spec2ShiftInc2,'Enable','off')
    set(fm.proc.spec2ShiftInc3,'Enable','off')
    set(fm.proc.spec2ShiftReset,'Enable','off')
    set(fm.proc.syncShift,'Enable','off')
end

%--- baseline offset: spectrum 1 ---
if flag.procSpec1Offset==1
    set(fm.proc.spec1OffsetDec3,'Enable','on')
    set(fm.proc.spec1OffsetDec2,'Enable','on')
    set(fm.proc.spec1OffsetDec1,'Enable','on')
    set(fm.proc.spec1OffsetVal,'Enable','on')
    set(fm.proc.spec1OffsetInc1,'Enable','on')
    set(fm.proc.spec1OffsetInc2,'Enable','on')
    set(fm.proc.spec1OffsetInc3,'Enable','on')
    set(fm.proc.spec1OffsetReset,'Enable','on')
else
    set(fm.proc.spec1OffsetDec3,'Enable','off')
    set(fm.proc.spec1OffsetDec2,'Enable','off')
    set(fm.proc.spec1OffsetDec1,'Enable','off')
    set(fm.proc.spec1OffsetVal,'Enable','off')
    set(fm.proc.spec1OffsetInc1,'Enable','off')
    set(fm.proc.spec1OffsetInc2,'Enable','off')
    set(fm.proc.spec1OffsetInc3,'Enable','off')
    set(fm.proc.spec1OffsetReset,'Enable','off')
end

%--- baseline offset: spectrum 2 ---
if flag.procNumSpec==1
    set(fm.proc.spec2OffsetFlag,'Enable','on')
else
    set(fm.proc.spec2OffsetFlag,'Enable','off')
end
if flag.procSpec2Offset==1 && flag.procNumSpec==1
    set(fm.proc.spec2OffsetDec3,'Enable','on')
    set(fm.proc.spec2OffsetDec2,'Enable','on')
    set(fm.proc.spec2OffsetDec1,'Enable','on')
    set(fm.proc.spec2OffsetVal,'Enable','on')
    set(fm.proc.spec2OffsetInc1,'Enable','on')
    set(fm.proc.spec2OffsetInc2,'Enable','on')
    set(fm.proc.spec2OffsetInc3,'Enable','on')
    set(fm.proc.spec2OffsetReset,'Enable','on')
    if flag.procSpec1Offset
        set(fm.proc.syncOffset,'Enable','on')
    else
        set(fm.proc.syncOffset,'Enable','off')
    end
else
    set(fm.proc.spec2OffsetDec3,'Enable','off')
    set(fm.proc.spec2OffsetDec2,'Enable','off')
    set(fm.proc.spec2OffsetDec1,'Enable','off')
    set(fm.proc.spec2OffsetVal,'Enable','off')
    set(fm.proc.spec2OffsetInc1,'Enable','off')
    set(fm.proc.spec2OffsetInc2,'Enable','off')
    set(fm.proc.spec2OffsetInc3,'Enable','off')
    set(fm.proc.spec2OffsetReset,'Enable','off')
    set(fm.proc.syncOffset,'Enable','off')
end


%--- spectral stretch: spectrum 1 ---
if flag.procSpec1Stretch==1
    set(fm.proc.spec1StretchDec3,'Enable','on')
    set(fm.proc.spec1StretchDec2,'Enable','on')
    set(fm.proc.spec1StretchDec1,'Enable','on')
    set(fm.proc.spec1StretchVal,'Enable','on')
    set(fm.proc.spec1StretchInc1,'Enable','on')
    set(fm.proc.spec1StretchInc2,'Enable','on')
    set(fm.proc.spec1StretchInc3,'Enable','on')
    set(fm.proc.spec1StretchReset,'Enable','on')
else
    set(fm.proc.spec1StretchDec3,'Enable','off')
    set(fm.proc.spec1StretchDec2,'Enable','off')
    set(fm.proc.spec1StretchDec1,'Enable','off')
    set(fm.proc.spec1StretchVal,'Enable','off')
    set(fm.proc.spec1StretchInc1,'Enable','off')
    set(fm.proc.spec1StretchInc2,'Enable','off')
    set(fm.proc.spec1StretchInc3,'Enable','off')
    set(fm.proc.spec1StretchReset,'Enable','off')
end

%--- spectral stretch: spectrum 2 ---
if flag.procNumSpec==1
    set(fm.proc.spec2StretchFlag,'Enable','on')
else
    set(fm.proc.spec2StretchFlag,'Enable','off')
end
if flag.procSpec2Stretch==1 && flag.procNumSpec==1
    set(fm.proc.spec2StretchDec3,'Enable','on')
    set(fm.proc.spec2StretchDec2,'Enable','on')
    set(fm.proc.spec2StretchDec1,'Enable','on')
    set(fm.proc.spec2StretchVal,'Enable','on')
    set(fm.proc.spec2StretchInc1,'Enable','on')
    set(fm.proc.spec2StretchInc2,'Enable','on')
    set(fm.proc.spec2StretchInc3,'Enable','on')
    set(fm.proc.spec2StretchReset,'Enable','on')
    if flag.procSpec1Stretch
        set(fm.proc.syncStretch,'Enable','on')
    else
        set(fm.proc.syncStretch,'Enable','off')
    end
else
    set(fm.proc.spec2StretchDec3,'Enable','off')
    set(fm.proc.spec2StretchDec2,'Enable','off')
    set(fm.proc.spec2StretchDec1,'Enable','off')
    set(fm.proc.spec2StretchVal,'Enable','off')
    set(fm.proc.spec2StretchInc1,'Enable','off')
    set(fm.proc.spec2StretchInc2,'Enable','off')
    set(fm.proc.spec2StretchInc3,'Enable','off')
    set(fm.proc.spec2StretchReset,'Enable','off')
    set(fm.proc.syncStretch,'Enable','off')
end

%--- ppm calib update ---
set(fm.proc.ppmCalib,'String',sprintf('%.4f',proc.ppmCalib))

%--- visualization of specific frequency ---
if flag.procPpmShowPos
    set(fm.proc.ppmShowPosVal,'Enable','on')
    set(fm.proc.ppmShowPosAssign,'Enable','on')
    set(fm.proc.ppmShowPosMirr,'Enable','on')
else
    set(fm.proc.ppmShowPosVal,'Enable','off')
    set(fm.proc.ppmShowPosAssign,'Enable','off')
    set(fm.proc.ppmShowPosMirr,'Enable','off')
end
set(fm.proc.ppmShowPosVal,'String',sprintf('%.4f',proc.ppmShowPos))


%--- visualization: frequency ---
if flag.procPpmShow         % direct
    set(fm.proc.ppmShowMinDecr,'Enable','on')
    set(fm.proc.ppmShowMin,'Enable','on')
    set(fm.proc.ppmShowMinIncr,'Enable','on')
    set(fm.proc.ppmShowMaxDecr,'Enable','on')
    set(fm.proc.ppmShowMax,'Enable','on')
    set(fm.proc.ppmShowMaxIncr,'Enable','on')
else                        % full SW
    set(fm.proc.ppmShowMinDecr,'Enable','off')
    set(fm.proc.ppmShowMin,'Enable','off')
    set(fm.proc.ppmShowMinIncr,'Enable','off')
    set(fm.proc.ppmShowMaxDecr,'Enable','off')
    set(fm.proc.ppmShowMax,'Enable','off')
    set(fm.proc.ppmShowMaxIncr,'Enable','off')
end

%--- visualization: amplitude ---
if flag.procAmpl             % direct
    set(fm.proc.amplMinDecr,'Enable','on')
    set(fm.proc.amplMin,'Enable','on')
    set(fm.proc.amplMinIncr,'Enable','on')
    set(fm.proc.amplMaxDecr,'Enable','on')
    set(fm.proc.amplMax,'Enable','on')
    set(fm.proc.amplMaxIncr,'Enable','on')
else                        % auto
    set(fm.proc.amplMinDecr,'Enable','off')
    set(fm.proc.amplMin,'Enable','off')
    set(fm.proc.amplMinIncr,'Enable','off')
    set(fm.proc.amplMaxDecr,'Enable','off')
    set(fm.proc.amplMax,'Enable','off')
    set(fm.proc.amplMaxIncr,'Enable','off')
end

%--- baseline offset mode ---
if flag.procOffset          % ppm range
    set(fm.proc.ppmOffsetMinDecr,'Enable','on')
    set(fm.proc.ppmOffsetMin,'Enable','on')
    set(fm.proc.ppmOffsetMinIncr,'Enable','on')
    set(fm.proc.ppmOffsetMaxDecr,'Enable','on')
    set(fm.proc.ppmOffsetMax,'Enable','on')
    set(fm.proc.ppmOffsetMaxIncr,'Enable','on')
    set(fm.proc.offsetDec3,'Enable','off')
    set(fm.proc.offsetDec2,'Enable','off')
    set(fm.proc.offsetDec1,'Enable','off')
    set(fm.proc.offsetVal,'Enable','off')
    set(fm.proc.offsetInc1,'Enable','off')
    set(fm.proc.offsetInc2,'Enable','off')
    set(fm.proc.offsetInc3,'Enable','off')
    set(fm.proc.offsetReset,'Enable','off')
    set(fm.proc.offsetAssign,'Enable','off')
else                        % direct value assignment
    set(fm.proc.ppmOffsetMinDecr,'Enable','off')
    set(fm.proc.ppmOffsetMin,'Enable','off')
    set(fm.proc.ppmOffsetMinIncr,'Enable','off')
    set(fm.proc.ppmOffsetMaxDecr,'Enable','off')
    set(fm.proc.ppmOffsetMax,'Enable','off')
    set(fm.proc.ppmOffsetMaxIncr,'Enable','off')
    set(fm.proc.offsetDec3,'Enable','on')
    set(fm.proc.offsetDec2,'Enable','on')
    set(fm.proc.offsetDec1,'Enable','on')
    set(fm.proc.offsetVal,'Enable','on')
    set(fm.proc.offsetInc1,'Enable','on')
    set(fm.proc.offsetInc2,'Enable','on')
    set(fm.proc.offsetInc3,'Enable','on')
    set(fm.proc.offsetReset,'Enable','on')
    set(fm.proc.offsetAssign,'Enable','on')
end
set(fm.proc.offsetVal,'String',num2str(proc.offsetVal))

%--- spectra alignment ---
if flag.procAlignPoly
    set(fm.proc.alignPolyOrdDec,'Enable','on')
    set(fm.proc.alignPolyOrder,'Enable','on')
    set(fm.proc.alignPolyOrdInc,'Enable','on')
else
    set(fm.proc.alignPolyOrdDec,'Enable','off')
    set(fm.proc.alignPolyOrder,'Enable','off')
    set(fm.proc.alignPolyOrdInc,'Enable','off')
end









