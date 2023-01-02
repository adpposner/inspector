%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Exit_ExitFct( varargin )
%% 
%%  Exit function (after saving the parameter settings to file for next 
%%  function call.
%%
%%  02-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile pars flag data stab mm proc t1t2 mrsi syn marss lcm tools man

FCTNAME = 'SP2_Exit_ExitFct';


%--- delete local windows ---
if ~SP2_ClearWindow
    fprintf(loggingfile,'\n--- WARNING ---\nClearing of window figure handles failed.\n\n');
    return
end

%--- transfer relevant parameters to pars2save struct ---
pars2save.nColors     = pars.nColors;
pars2save.figPos      = pars.figPos;

%--- transfer relevant parameters to data2save struct ---
data2save.defaultDir      = data.defaultDir;
data2save.protFile        = data.protFile;
data2save.protDir         = data.protDir;
data2save.protPath        = data.protPath;
data2save.protPathMat     = data.protPathMat;
data2save.protPathTxt     = data.protPathTxt;
data2save.protDateNum     = data.protDateNum;
data2save.protDateStr     = data.protDateStr;
data2save.quality         = data.quality;
data2save.phaseCorrNr     = data.phaseCorrNr;
data2save.rcvrMax         = data.rcvrMax;
data2save.rcvr            = data.rcvr;
data2save.rcvrInd         = data.rcvrInd;
data2save.rcvrN           = data.rcvrN;
data2save.rcvrSelectStr   = data.rcvrSelectStr;
data2save.select          = data.select;
data2save.selectN         = data.selectN;
data2save.selectStr       = data.selectStr;
data2save.ppmCorrMin      = data.ppmCorrMin;
data2save.ppmCorrMax      = data.ppmCorrMax;
data2save.ds              = data.ds;
data2save.nPhCycle        = data.nPhCycle;
data2save.ppmTargetMin    = data.ppmTargetMin;
data2save.ppmTargetMax    = data.ppmTargetMax;
data2save.ppmNoiseMin     = data.ppmNoiseMin;
data2save.ppmNoiseMax     = data.ppmNoiseMax;
data2save.ppmCalib        = data.ppmCalib;
data2save.ppmAssign       = data.ppmAssign;
data2save.fidCut          = data.fidCut;
data2save.fidZf           = data.fidZf;
data2save.scrollRcvr      = data.scrollRcvr;
data2save.scrollRep       = data.scrollRep;
data2save.amplMin         = data.amplMin;
data2save.amplMax         = data.amplMax;
data2save.ppmShowMin      = data.ppmShowMin;
data2save.ppmShowMax      = data.ppmShowMax;

%--- field handling of data structure ---
if isfield(data,'opt')
    data = rmfield(data,'opt');
end
if isfield(data,'frAlignAllInd')
    data = rmfield(data,'frAlignAllInd');
end
if isfield(data,'phAlignAllInd')
    data = rmfield(data,'phAlignAllInd');
end
if isfield(data.spec1,'fid')
    data.spec1 = rmfield(data.spec1,'fid');
end
if isfield(data.spec2,'fid')
    data.spec2 = rmfield(data.spec2,'fid');
end
if isfield(data.spec1,'fidArr')
    data.spec1 = rmfield(data.spec1,'fidArr');
end
if isfield(data.spec2,'fidArr')
    data.spec2 = rmfield(data.spec2,'fidArr');
end
if isfield(data.spec1,'fidArrRxComb')
    data.spec1 = rmfield(data.spec1,'fidArrRxComb');
end
if isfield(data.spec2,'fidArrRxComb')
    data.spec2 = rmfield(data.spec2,'fidArrRxComb');
end
if isfield(data.spec1,'fidArrSel')
    data.spec1 = rmfield(data.spec1,'fidArrSel');
end
if isfield(data.spec2,'fidSel')
    data.spec2 = rmfield(data.spec2,'fidSel');
end
if isfield(data.spec1,'fidArrSerial')
    data.spec1 = rmfield(data.spec1,'fidArrSerial');
end
if isfield(data.spec1,'spec')
    data.spec1 = rmfield(data.spec1,'spec');
end
if isfield(data.spec2,'spec')
    data.spec2 = rmfield(data.spec2,'spec');
end
data2save.spec1        = data.spec1;
data2save.spec2        = data.spec2;
data2save.satRec       = data.satRec;

%--- spectrum alignment window ---
data2save.frAlignPpm1Str   = data.frAlignPpm1Str;
data2save.frAlignPpm1Min   = data.frAlignPpm1Min;
data2save.frAlignPpm1Max   = data.frAlignPpm1Max;
data2save.frAlignPpm1N     = data.frAlignPpm1N;
data2save.frAlignPpm2Str   = data.frAlignPpm2Str;
data2save.frAlignPpm2Min   = data.frAlignPpm2Min;
data2save.frAlignPpm2Max   = data.frAlignPpm2Max;
data2save.frAlignPpm2N     = data.frAlignPpm2N;
data2save.frAlignFrequRg   = data.frAlignFrequRg;
data2save.frAlignFrequRes  = data.frAlignFrequRes;
data2save.frAlignExpLb     = data.frAlignExpLb;
data2save.frAlignFftCut    = data.frAlignFftCut;
data2save.frAlignFftZf     = data.frAlignFftZf;
data2save.frAlignRefFid    = data.frAlignRefFid;
data2save.frAlignIter      = data.frAlignIter;
data2save.frAlignVerbMax   = data.frAlignVerbMax;
data2save.phAlignPpm1Str   = data.phAlignPpm1Str;
data2save.phAlignPpm1Min   = data.phAlignPpm1Min;
data2save.phAlignPpm1Max   = data.phAlignPpm1Max;
data2save.phAlignPpm1N     = data.phAlignPpm1N;
data2save.phAlignPpm2Str   = data.phAlignPpm2Str;
data2save.phAlignPpm2Min   = data.phAlignPpm2Min;
data2save.phAlignPpm2Max   = data.phAlignPpm2Max;
data2save.phAlignPpm2N     = data.phAlignPpm2N;
data2save.phAlignExpLb     = data.phAlignExpLb;
data2save.phAlignFftCut    = data.phAlignFftCut;
data2save.phAlignFftZf     = data.phAlignFftZf;
data2save.phAlignPhStep    = data.phAlignPhStep;
data2save.phAlignRefFid    = data.phAlignRefFid;
data2save.phAlignIter      = data.phAlignIter;
data2save.phAlignVerbMax   = data.phAlignVerbMax;
data2save.amAlignPpmStr    = data.amAlignPpmStr;
data2save.amAlignPpmMin    = data.amAlignPpmMin;
data2save.amAlignPpmMax    = data.amAlignPpmMax;
data2save.amAlignPpmN      = data.amAlignPpmN;
data2save.amAlignExpLb     = data.amAlignExpLb;
data2save.amAlignFftCut    = data.amAlignFftCut;
data2save.amAlignFftZf     = data.amAlignFftZf;
data2save.amAlignRef1Str   = data.amAlignRef1Str;
data2save.amAlignRef1Vec   = data.amAlignRef1Vec;
data2save.amAlignRef1N     = data.amAlignRef1N;
data2save.amAlignRef2Str   = data.amAlignRef2Str;
data2save.amAlignRef2Vec   = data.amAlignRef2Vec;
data2save.amAlignRef2N     = data.amAlignRef2N;
data2save.amAlignPolyOrder = data.amAlignPolyOrder;
data2save.amAlignExtraPpm  = data.amAlignExtraPpm;

%--- transfer relevant parameters to stab2save struct ---
stab2save.phc0        = stab.phc0;
stab2save.ppmCalib    = stab.ppmCalib;
stab2save.ppmBins     = stab.ppmBins;
stab2save.specFirst   = stab.specFirst;
stab2save.specLast    = stab.specLast;
stab2save.ppmBinSel   = stab.ppmBinSel;
stab2save.specSel     = stab.specSel;      
stab2save.trans       = stab.trans;      
stab2save.rcvr        = stab.rcvr;

%--- MM parameters ---
mm2save.lb               = mm.lb;
mm2save.cut              = mm.cut;
mm2save.zf               = mm.zf;
mm2save.ppmCalib         = mm.ppmCalib;
mm2save.phaseZero        = mm.phaseZero;
mm2save.boxCar           = mm.boxCar;
mm2save.boxCarHz         = mm.boxCarHz;
mm2save.dataExtFac       = mm.dataExtFac;
mm2save.sim              = mm.sim;
mm2save.anaFrequMin      = mm.anaFrequMin;
mm2save.anaFrequMax      = mm.anaFrequMax;
mm2save.anaTOneFlexN     = mm.anaTOneFlexN;
mm2save.anaTOneFlexThMin = mm.anaTOneFlexThMin;
mm2save.anaTOneFlexThMax = mm.anaTOneFlexThMax;
mm2save.anaTOne          = mm.anaTOne;
mm2save.anaTOneN         = mm.anaTOneN;
mm2save.anaTOneStr       = mm.anaTOneStr;
mm2save.anaOptN          = mm.anaOptN;
mm2save.anaOptAmpRg      = mm.anaOptAmpRg;
mm2save.anaOptAmpRed     = mm.anaOptAmpRed;
mm2save.mmStructFile     = mm.mmStructFile;
mm2save.mmStructDir      = mm.mmStructDir;
mm2save.mmStructPath     = mm.mmStructPath;
mm2save.satRecSelect     = mm.satRecSelect;
mm2save.satRecCons       = mm.satRecCons;
mm2save.satRecConsN      = mm.satRecConsN;
mm2save.satRecConsStr    = mm.satRecConsStr;
mm2save.tOneSelect       = mm.tOneSelect;
mm2save.tOneCons         = mm.tOneCons;
mm2save.tOneConsN        = mm.tOneConsN;
mm2save.tOneConsStr      = mm.tOneConsStr;
mm2save.expPpmSelect     = mm.expPpmSelect;
mm2save.expPointSelect   = mm.expPointSelect;
mm2save.amplShowMin      = mm.amplShowMin;
mm2save.amplShowMax      = mm.amplShowMax;
mm2save.ppmShowMin       = mm.ppmShowMin;
mm2save.ppmShowMax       = mm.ppmShowMax;
mm2save.ppmShowPos       = mm.ppmShowPos;

%--- spectrum alignment window ---
mm2save.phAlignPpmStr    = mm.phAlignPpmStr;
mm2save.phAlignPpmMin    = mm.phAlignPpmMin;
mm2save.phAlignPpmMax    = mm.phAlignPpmMax;
mm2save.phAlignPpmN      = mm.phAlignPpmN;
mm2save.phAlignExpLb     = mm.phAlignExpLb;
mm2save.phAlignFftCut    = mm.phAlignFftCut;
mm2save.phAlignFftZf     = mm.phAlignFftZf;
mm2save.phAlignPhStep    = mm.phAlignPhStep;
mm2save.phAlignRefFid    = mm.phAlignRefFid;
mm2save.phAlignIter      = mm.phAlignIter;
mm2save.frAlignPpmStr    = mm.frAlignPpmStr;
mm2save.frAlignPpmMin    = mm.frAlignPpmMin;
mm2save.frAlignPpmMax    = mm.frAlignPpmMax;
mm2save.frAlignPpmN      = mm.frAlignPpmN;
mm2save.frAlignFrequRg   = mm.frAlignFrequRg;
mm2save.frAlignFrequRes  = mm.frAlignFrequRes;
mm2save.frAlignExpLb     = mm.frAlignExpLb;
mm2save.frAlignFftCut    = mm.frAlignFftCut;
mm2save.frAlignFftZf     = mm.frAlignFftZf;
mm2save.frAlignRefFid    = mm.frAlignRefFid;
mm2save.frAlignIter      = mm.frAlignIter;
mm2save.amAlignPpmStr    = mm.amAlignPpmStr;
mm2save.amAlignPpmMin    = mm.amAlignPpmMin;
mm2save.amAlignPpmMax    = mm.amAlignPpmMax;
mm2save.amAlignPpmN      = mm.amAlignPpmN;
mm2save.amAlignExpLb     = mm.amAlignExpLb;
mm2save.amAlignFftCut    = mm.amAlignFftCut;
mm2save.amAlignFftZf     = mm.amAlignFftZf;
mm2save.amAlignRef1Str   = mm.amAlignRef1Str;
mm2save.amAlignRef1Vec   = mm.amAlignRef1Vec;
mm2save.amAlignRef1N     = mm.amAlignRef1N;
mm2save.amAlignRef2Str   = mm.amAlignRef2Str;
mm2save.amAlignRef2Vec   = mm.amAlignRef2Vec;
mm2save.amAlignRef2N     = mm.amAlignRef2N;
mm2save.amAlignPolyOrder = mm.amAlignPolyOrder;
mm2save.amAlignExtraPpm  = mm.amAlignExtraPpm;


%--- non-water-suppressed (proc) parameters ---
proc2save.procFormat    = proc.procFormat;       % 1: single spectrum , 2: 2 spectra
if isfield(proc.spec1,'fid')
    proc.spec1 = rmfield(proc.spec1,'fid');
end
if isfield(proc.spec2,'fid')
    proc.spec2 = rmfield(proc.spec2,'fid');
end
if isfield(proc.spec1,'fidOrig')
    proc.spec1 = rmfield(proc.spec1,'fidOrig');
end
if isfield(proc.spec2,'fidOrig')
    proc.spec2 = rmfield(proc.spec2,'fidOrig');
end
if isfield(proc.spec1,'spec')
    proc.spec1 = rmfield(proc.spec1,'spec');
end
if isfield(proc.spec2,'spec')
    proc.spec2 = rmfield(proc.spec2,'spec');
end
if isfield(proc.expt,'fid')
    proc.expt = rmfield(proc.expt,'fid');
end
if isfield(proc.expt,'fidOrig')
    proc.expt = rmfield(proc.expt,'fidOrig');
end
if isfield(proc,'svd')
    if isfield(proc.svd,'fid')
        proc.svd = rmfield(proc.svd,'fid');
    end
    if isfield(proc.svd,'spec')
        proc.svd = rmfield(proc.svd,'spec');
    end
    if isfield(proc.svd,'fidPeak')
        proc.svd = rmfield(proc.svd,'fidPeak');
    end
    if isfield(proc.svd,'specPeak')
        proc.svd = rmfield(proc.svd,'specPeak');
    end
end
proc2save.spec1          = proc.spec1;            % parameter struct of spectrum 1
proc2save.spec2          = proc.spec2;            % parameter struct of spectrum 2
proc2save.expt           = proc.expt;             % parameter struct of export functionality
proc2save.ppmShowMin     = proc.ppmShowMin;       % min of ppm visualization window
proc2save.ppmShowMax     = proc.ppmShowMax;       % max of ppm window
proc2save.ppmTargetMin   = proc.ppmTargetMin;     % min of ppm visualization window
proc2save.ppmTargetMax   = proc.ppmTargetMax;     % max of ppm window
proc2save.ppmNoiseMin    = proc.ppmNoiseMin;      % min of ppm visualization window
proc2save.ppmNoiseMax    = proc.ppmNoiseMax;      % max of ppm window
proc2save.ppmCalib       = proc.ppmCalib;
proc2save.ppmAssign      = proc.ppmAssign;
proc2save.ppmShowPos     = proc.ppmShowPos;
proc2save.ppmShowPosMirr = proc.ppmShowPosMirr;
proc2save.amplMin        = proc.amplMin;          % min of amplitude window
proc2save.amplMax        = proc.amplMax;          % max of amplitude window      
proc2save.ppmOffsetMin   = proc.ppmOffsetMin;
proc2save.ppmOffsetMax   = proc.ppmOffsetMax;
proc2save.offsetVal      = proc.offsetVal;
proc2save.alignAmpWeight = proc.alignAmpWeight;
proc2save.alignPpmStr    = proc.alignPpmStr;
proc2save.alignPpmMin    = proc.alignPpmMin;
proc2save.alignPpmMax    = proc.alignPpmMax;
proc2save.alignPpmN      = proc.alignPpmN;
proc2save.alignTolFun    = proc.alignTolFun;
proc2save.alignMaxIter   = proc.alignMaxIter;
proc2save.alignPolyOrder = proc.alignPolyOrder;
proc2save.jdeEffPpmRg    = proc.jdeEffPpmRg;
proc2save.jdeEffOffset   = proc.jdeEffOffset;
proc2save.convExtStr     = proc.convExtStr;
proc2save.basePolyOrder  = proc.basePolyOrder;
proc2save.basePolyPpmStr = proc.basePolyPpmStr;
proc2save.basePolyPpmMin = proc.basePolyPpmMin;
proc2save.basePolyPpmMax = proc.basePolyPpmMax;
proc2save.basePolyPpmN   = proc.basePolyPpmN;
proc2save.baseInterpPpmStr = proc.baseInterpPpmStr;
proc2save.baseInterpPpmMin = proc.baseInterpPpmMin;
proc2save.baseInterpPpmMax = proc.baseInterpPpmMax;
proc2save.baseInterpPpmN = proc.baseInterpPpmN;
proc2save.baseSvdPeakN   = proc.baseSvdPeakN;
proc2save.baseSvdPpmStr  = proc.baseSvdPpmStr;
proc2save.baseSvdPpmMin  = proc.baseSvdPpmMin;
proc2save.baseSvdPpmMax  = proc.baseSvdPpmMax;
proc2save.baseSvdPpmN    = proc.baseSvdPpmN;


%--- T1/T2 analysis ---
t1t22save.lb                = t1t2.lb;
t1t22save.cut               = t1t2.cut;
t1t22save.zf                = t1t2.zf;
t1t22save.delayNumber       = t1t2.delayNumber;
t1t22save.ppmAssign         = t1t2.ppmAssign;
t1t22save.ppmCalib          = t1t2.ppmCalib;
t1t22save.ppmWinMin         = t1t2.ppmWinMin;
t1t22save.ppmWinMax         = t1t2.ppmWinMax;
t1t22save.phaseZero         = t1t2.phaseZero;
t1t22save.anaFidMin         = t1t2.anaFidMin;
t1t22save.anaFidMax         = t1t2.anaFidMax;
t1t22save.anaSignFlipN      = t1t2.anaSignFlipN;
t1t22save.anaTime           = t1t2.anaTime;
t1t22save.anaTimeN          = t1t2.anaTimeN;
t1t22save.anaTimeStr        = t1t2.anaTimeStr;
t1t22save.anaAmp            = t1t2.anaAmp;
t1t22save.anaAmpN           = t1t2.anaAmpN;
t1t22save.anaAmpStr         = t1t2.anaAmpStr;
t1t22save.anaTConstFlexN    = t1t2.anaTConstFlexN;
t1t22save.anaTConstFlex1Fix = t1t2.anaTConstFlex1Fix;
t1t22save.anaTConst         = t1t2.anaTConst;
t1t22save.anaTConstN        = t1t2.anaTConstN;
t1t22save.anaTConstStr      = t1t2.anaTConstStr;
t1t22save.tConstSelect      = t1t2.tConstSelect;
t1t22save.amplShowMin       = t1t2.amplShowMin;
t1t22save.amplShowMax       = t1t2.amplShowMax;
t1t22save.ppmShowMin        = t1t2.ppmShowMin;
t1t22save.ppmShowMax        = t1t2.ppmShowMax;
t1t22save.t1decT1           = t1t2.t1decT1;
t1t22save.t1decScale        = t1t2.t1decScale;
t1t22save.t1decDelay        = t1t2.t1decDelay;
t1t22save.t2decT2           = t1t2.t2decT2;
t1t22save.t2decScale        = t1t2.t2decScale;
t1t22save.t2decDelay        = t1t2.t2decDelay;


%--- MARSS ---
marss2save.sequNameCell     = marss.sequNameCell;
marss2save.sequOriginCell   = marss.sequOriginCell;
marss2save.simParsDefCell   = marss.simParsDefCell;
marss2save.resultFormatCell = marss.resultFormatCell;
marss2save.b0               = marss.b0;
marss2save.sf               = marss.sf;
marss2save.ppmCalib         = marss.ppmCalib;
marss2save.sw_h             = marss.sw_h;
marss2save.sw               = marss.sw;
marss2save.nspecCBasic      = marss.nspecCBasic;
marss2save.voxDim           = marss.voxDim;
marss2save.simDim           = marss.simDim;
marss2save.te               = marss.te;
marss2save.te2              = marss.te2;
marss2save.tm               = marss.tm;
marss2save.lb               = marss.lb;
marss2save.log              = marss.log;
marss2save.spinSys          = marss.spinSys;
marss2save.basis            = marss.basis;
marss2save.procCut          = marss.procCut;
marss2save.procZf           = marss.procZf;
marss2save.procLb           = marss.procLb;
marss2save.procGb           = marss.procGb;
marss2save.procPhc0         = marss.procPhc0;
marss2save.procPhc1         = marss.procPhc1;
marss2save.procScale        = marss.procScale;
marss2save.procShift        = marss.procShift;
marss2save.amplShowMin      = marss.amplShowMin;
marss2save.amplShowMax      = marss.amplShowMax;
marss2save.ppmShowMin       = marss.ppmShowMin;
marss2save.ppmShowMax       = marss.ppmShowMax;
marss2save.showSel          = marss.showSel;
marss2save.showSelN         = marss.showSelN;
marss2save.showSelStr       = marss.showSelStr;
marss2save.currShow         = marss.currShow;

%--- MRSI ---
if isfield(mrsi.spec1,'fid')
    mrsi.spec1 = rmfield(mrsi.spec1,'fid');
end
if isfield(mrsi.spec1,'spec')
    mrsi.spec1 = rmfield(mrsi.spec1,'spec');
end
if isfield(mrsi.spec1,'fidkspvec')
    mrsi.spec1 = rmfield(mrsi.spec1,'fidkspvec');
end
if isfield(mrsi.spec1,'fidksp')
    mrsi.spec1 = rmfield(mrsi.spec1,'fidksp');
end
if isfield(mrsi.spec1,'fidkspOrig')
    mrsi.spec1 = rmfield(mrsi.spec1,'fidkspOrig');
end
if isfield(mrsi.spec1,'fidimg')
    mrsi.spec1 = rmfield(mrsi.spec1,'fidimg');
end
if isfield(mrsi.spec1,'specimg')
    mrsi.spec1 = rmfield(mrsi.spec1,'specimg');
end
if isfield(mrsi.spec1,'fidimg_orig')
    mrsi.spec1 = rmfield(mrsi.spec1,'fidimg_orig');
end
if isfield(mrsi.spec2,'fid')
    mrsi.spec2 = rmfield(mrsi.spec2,'fid');
end
if isfield(mrsi.spec2,'spec')
    mrsi.spec2 = rmfield(mrsi.spec2,'spec');
end
if isfield(mrsi.spec2,'fidkspvec')
    mrsi.spec2 = rmfield(mrsi.spec2,'fidkspvec');
end
if isfield(mrsi.spec2,'fidksp')
    mrsi.spec2 = rmfield(mrsi.spec2,'fidksp');
end
if isfield(mrsi.spec2,'fidkspOrig')
    mrsi.spec2 = rmfield(mrsi.spec2,'fidkspOrig');
end
if isfield(mrsi.spec2,'fidimg')
    mrsi.spec2 = rmfield(mrsi.spec2,'fidimg');
end
if isfield(mrsi.spec2,'specimg')
    mrsi.spec2 = rmfield(mrsi.spec2,'specimg');
end
if isfield(mrsi.spec2,'fidimg_orig')
    mrsi.spec2 = rmfield(mrsi.spec2,'fidimg_orig');
end
if isfield(mrsi.ref,'fid')
    mrsi.ref = rmfield(mrsi.ref,'fid');
end
if isfield(mrsi.ref,'spec')
    mrsi.ref = rmfield(mrsi.ref,'spec');
end
if isfield(mrsi.ref,'fidkspvec')
    mrsi.ref = rmfield(mrsi.ref,'fidkspvec');
end
if isfield(mrsi.ref,'fidksp')
    mrsi.ref = rmfield(mrsi.ref,'fidksp');
end
if isfield(mrsi.ref,'fidkspOrig')
    mrsi.ref = rmfield(mrsi.ref,'fidkspOrig');
end
if isfield(mrsi.ref,'fidimg')
    mrsi.ref = rmfield(mrsi.ref,'fidimg');
end
if isfield(mrsi.ref,'specimg')
    mrsi.ref = rmfield(mrsi.ref,'specimg');
end
if isfield(mrsi.ref,'fidimg_orig')
    mrsi.ref = rmfield(mrsi.ref,'fidimg_orig');
end
if isfield(mrsi,'diff')
    if isfield(mrsi.diff,'fidimg_orig')
        mrsi.diff = rmfield(mrsi.diff,'fidimg_orig');
    end
    if isfield(mrsi.diff,'specimg')
        mrsi.diff = rmfield(mrsi.diff,'specimg');
    end
    if isfield(mrsi.diff,'spec')
        mrsi.diff = rmfield(mrsi.diff,'spec');
    end
end
if isfield(mrsi,'expt')
    if isfield(mrsi.expt,'fid')
        mrsi.expt = rmfield(mrsi.expt,'fid');
    end
end
mrsi2save.mrsiFormat     = mrsi.mrsiFormat;
mrsi2save.spec1          = mrsi.spec1;
mrsi2save.spec2          = mrsi.spec2;
mrsi2save.ref            = mrsi.ref;
mrsi2save.expt           = mrsi.expt;
mrsi2save.spatZF         = mrsi.spatZF;
mrsi2save.selectLR       = mrsi.selectLR;
mrsi2save.selectPA       = mrsi.selectPA;
mrsi2save.ppmShowMin     = mrsi.ppmShowMin;
mrsi2save.ppmShowMax     = mrsi.ppmShowMax;
mrsi2save.ppmCalib       = mrsi.ppmCalib;
mrsi2save.ppmAssign      = mrsi.ppmAssign;
mrsi2save.ppmShowPos     = mrsi.ppmShowPos;
mrsi2save.ppmShowPosMirr = mrsi.ppmShowPosMirr;
mrsi2save.ppmTargetMin   = mrsi.ppmTargetMin;
mrsi2save.ppmTargetMax   = mrsi.ppmTargetMax;
mrsi2save.ppmNoiseMin    = mrsi.ppmNoiseMin;
mrsi2save.ppmNoiseMax    = mrsi.ppmNoiseMax;
mrsi2save.amplMin        = mrsi.amplMin;
mrsi2save.amplMax        = mrsi.amplMax;
mrsi2save.ppmOffsetMin   = mrsi.ppmOffsetMin;
mrsi2save.ppmOffsetMax   = mrsi.ppmOffsetMax;
mrsi2save.offsetVal      = mrsi.offsetVal;
mrsi2save.basePolyOrder  = mrsi.basePolyOrder;
mrsi2save.basePolyPpmStr = mrsi.basePolyPpmStr;
mrsi2save.basePolyPpmMin = mrsi.basePolyPpmMin;
mrsi2save.basePolyPpmMax = mrsi.basePolyPpmMax;
mrsi2save.basePolyPpmN   = mrsi.basePolyPpmN;
mrsi2save.baseInterpPpmStr = mrsi.baseInterpPpmStr;
mrsi2save.baseInterpPpmMin = mrsi.baseInterpPpmMin;
mrsi2save.baseInterpPpmMax = mrsi.baseInterpPpmMax;
mrsi2save.baseInterpPpmN   = mrsi.baseInterpPpmN;
mrsi2save.baseSvdPeakN     = mrsi.baseSvdPeakN;
mrsi2save.baseSvdPpmStr    = mrsi.baseSvdPpmStr;
mrsi2save.baseSvdPpmMin    = mrsi.baseSvdPpmMin;
mrsi2save.baseSvdPpmMax    = mrsi.baseSvdPpmMax;
mrsi2save.baseSvdPpmN      = mrsi.baseSvdPpmN;


%--- LCModel ---
lcm2save.sf                 = lcm.sf;
lcm2save.sw_h               = lcm.sw_h;
lcm2save.dataFormatCell     = lcm.dataFormatCell;
lcm2save.dataDir            = lcm.dataDir;
lcm2save.dataFileMat        = lcm.dataFileMat;
lcm2save.dataPathMat        = lcm.dataPathMat;
lcm2save.dataFileTxt        = lcm.dataFileTxt;
lcm2save.dataPathTxt        = lcm.dataPathTxt;
lcm2save.dataFilePar        = lcm.dataFilePar;
lcm2save.dataPathPar        = lcm.dataPathPar;
lcm2save.dataFileRaw        = lcm.dataFileRaw;
lcm2save.dataPathRaw        = lcm.dataPathRaw;
lcm2save.dataFileJmrui      = lcm.dataFileJmrui;
lcm2save.dataPathJmrui      = lcm.dataPathJmrui;
lcm2save.basisDir           = lcm.basisDir;
lcm2save.basisFile          = lcm.basisFile;
lcm2save.basisPath          = lcm.basisPath;
lcm2save.specCut            = lcm.specCut;
lcm2save.specZf             = lcm.specZf;
lcm2save.specLb             = lcm.specLb;
lcm2save.specGb             = lcm.specGb;
lcm2save.specPhc0           = lcm.specPhc0;
lcm2save.specPhc1           = lcm.specPhc1;
lcm2save.specScale          = lcm.specScale;
lcm2save.specShift          = lcm.specShift;
lcm2save.specOffset         = lcm.specOffset;
lcm2save.ppmShowMin         = lcm.ppmShowMin;
lcm2save.ppmShowMax         = lcm.ppmShowMax;
lcm2save.ppmCalib           = lcm.ppmCalib;
lcm2save.ppmAssign          = lcm.ppmAssign;
lcm2save.ppmShowPos         = lcm.ppmShowPos;
lcm2save.anaScale           = lcm.anaScale;
lcm2save.anaScaleErr        = lcm.anaScaleErr;
lcm2save.anaLb              = lcm.anaLb;
lcm2save.anaLbErr           = lcm.anaLbErr;
lcm2save.anaGb              = lcm.anaGb;
lcm2save.anaGbErr           = lcm.anaGbErr;
lcm2save.anaShift           = lcm.anaShift;
lcm2save.anaShiftErr        = lcm.anaShiftErr;
lcm2save.anaPhc0            = lcm.anaPhc0;
lcm2save.anaPhc0Err         = lcm.anaPhc0Err;
lcm2save.anaPhc1            = lcm.anaPhc1;
lcm2save.anaPhc1Err         = lcm.anaPhc1Err;
lcm2save.anaPpmStr          = lcm.anaPpmStr;
lcm2save.anaPpmMin          = lcm.anaPpmMin;
lcm2save.anaPpmMax          = lcm.anaPpmMax;
lcm2save.anaPpmN            = lcm.anaPpmN;
lcm2save.anaPolyOrder       = lcm.anaPolyOrder;
lcm2save.anaPolyCoeff       = lcm.anaPolyCoeff;
lcm.anaPolyCoeffErr         = zeros(1,11);                      % polynomial coefficients 0..10th order, error
lcm2save.anaPolyShift       = lcm.anaPolyShift;
lcm.anaPolyShiftErr         = 0;                                % error of shift along the x-axis (ppm-axis) of polynomial
lcm2save.anaPolyCoeffImag   = lcm.anaPolyCoeffImag;
lcm.anaPolyCoeffImagErr     = zeros(1,11);                      % polynomial coefficients 0..10th order, imaginary part of complex fit, error
lcm2save.anaPolyShiftImag   = lcm.anaPolyShiftImag;
lcm.anaPolyShiftImagErr     = 0;                                % error of shift along the x-axis (ppm-axis) of polynomial
lcm2save.anaSplPtsPerPpm    = lcm.anaSplPtsPerPpm;
lcm2save.anaSplOrder        = lcm.anaSplOrder;
lcm2save.anaSplSmooth       = lcm.anaSplSmooth;
lcm2save.anaSplBounds       = lcm.anaSplBounds;

lcm2save.batch              = lcm.batch;
lcm2save.amplMin            = lcm.amplMin;
lcm2save.amplMax            = lcm.amplMax;
lcm2save.ppmTargetMin       = lcm.ppmTargetMin;
lcm2save.ppmTargetMax       = lcm.ppmTargetMax;
lcm2save.ppmNoiseMin        = lcm.ppmNoiseMin;
lcm2save.ppmNoiseMax        = lcm.ppmNoiseMax;
lcm2save.ppmOffsetMin       = lcm.ppmOffsetMin;
lcm2save.ppmOffsetMax       = lcm.ppmOffsetMax;
lcm2save.offsetVal          = lcm.offsetVal;
lcm2save.showSel            = lcm.showSel;
lcm2save.showSelN           = lcm.showSelN;
lcm2save.showSelStr         = lcm.showSelStr;
lcm2save.lineWidth          = lcm.lineWidth;
lcm2save.comb1Str           = lcm.comb1Str;
lcm2save.comb1Ind           = lcm.comb1Ind;
lcm2save.comb1N             = lcm.comb1N;
lcm2save.comb2Str           = lcm.comb2Str;
lcm2save.comb2Ind           = lcm.comb2Ind;
lcm2save.comb2N             = lcm.comb2N;
lcm2save.comb3Str           = lcm.comb3Str;
lcm2save.comb3Ind           = lcm.comb3Ind;
lcm2save.comb3N             = lcm.comb3N;
lcm2save.combN              = lcm.combN;
lcm2save.combInd            = lcm.combInd;

%--- LCM basis ---
if isfield(lcm.basis,'data')
    lcm.basis = rmfield(lcm.basis,'data');
end
if isfield(lcm.basis,'fid')
    lcm.basis = rmfield(lcm.basis,'fid');
end
if isfield(lcm.basis,'spec')
    lcm.basis = rmfield(lcm.basis,'spec');
end
lcm2save.basis        = lcm.basis;

%--- LCM export ---
if isfield(lcm.expt,'fid')
    lcm.expt = rmfield(lcm.expt,'fid');
end
if isfield(lcm.expt,'spec')
    lcm.expt = rmfield(lcm.expt,'spec');
end
lcm2save.expt         = lcm.expt;
lcm2save.logPath      = lcm.logPath;

%--- LCM fit analysis details ---
if isfield(lcm.fit,'fid')
    lcm.fit = rmfield(lcm.fit,'fid');
end
if isfield(lcm.fit,'spec')
    lcm.fit = rmfield(lcm.fit,'spec');
end
if isfield(lcm.fit,'sumSpec')
    lcm.fit = rmfield(lcm.fit,'sumSpec');
end
if isfield(lcm.fit,'fidSingle')
    lcm.fit = rmfield(lcm.fit,'fidSingle');
end
if isfield(lcm.fit,'specSingle')
    lcm.fit = rmfield(lcm.fit,'specSingle');
end
if isfield(lcm.fit,'resid')
    lcm.fit = rmfield(lcm.fit,'resid');
end
if isfield(lcm.fit,'corr')
    lcm.fit = rmfield(lcm.fit,'corr');
end
if isfield(lcm.fit,'polySpec')
    lcm.fit = rmfield(lcm.fit,'polySpec');
end
lcm2save.fit          = lcm.fit;

%--- LCM Monte-Carlo analysis details ---
if isfield(lcm.mc,'fid')
    lcm.mc = rmfield(lcm.mc,'fid');
end
lcm2save.mc           = lcm.mc;

%--- synthesis ---
syn2save.fidDir         = syn.fidDir;
syn2save.fidName        = syn.fidName;
syn2save.fidPath        = syn.fidPath;
syn2save.t1             = syn.t1;
syn2save.t2             = syn.t2;
syn2save.noiseAmp       = syn.noiseAmp;
syn2save.baseAmp        = syn.baseAmp;
syn2save.polyCenterPpm  = syn.polyCenterPpm;
syn2save.polyAmpVec     = syn.polyAmpVec;
syn2save.sf             = syn.sf;
syn2save.ppmCalib       = syn.ppmCalib;
syn2save.sw_h           = syn.sw_h;
syn2save.nspecCBasic    = syn.nspecCBasic;
syn2save.procCut        = syn.procCut;
syn2save.procZf         = syn.procZf;
syn2save.procLb         = syn.procLb;
syn2save.procGb         = syn.procGb;
syn2save.procPhc0       = syn.procPhc0;
syn2save.procPhc1       = syn.procPhc1;
syn2save.procScale      = syn.procScale;
syn2save.procShift      = syn.procShift;
syn2save.procOffset     = syn.procOffset;
syn2save.ppmTargetMin   = syn.ppmTargetMin;
syn2save.ppmTargetMax   = syn.ppmTargetMax;
syn2save.ppmNoiseMin    = syn.ppmNoiseMin;
syn2save.ppmNoiseMax    = syn.ppmNoiseMax;
syn2save.ppmShowPos     = syn.ppmShowPos;
syn2save.ppmShowPosMirr = syn.ppmShowPosMirr;
syn2save.ppmOffsetMin   = syn.ppmOffsetMin;
syn2save.ppmOffsetMax   = syn.ppmOffsetMax;
syn2save.offsetVal      = syn.offsetVal;
syn2save.metabCharStr   = syn.metabCharStr;
syn2save.metabCharCell  = syn.metabCharCell;
syn2save.amplShowMin    = syn.amplShowMin;
syn2save.amplShowMax    = syn.amplShowMax;
syn2save.ppmShowMin     = syn.ppmShowMin;
syn2save.ppmShowMax     = syn.ppmShowMax;
syn2save.ppmShowPos     = syn.ppmShowPos;

if isfield(syn,'brain')
    syn = rmfield(syn,'brain');
end

%--- tools ---
tools2save.anonFileDir  = tools.anonFileDir;
tools2save.anonFilePath = tools.anonFilePath;
tools2save.anonDir      = tools.anonDir;

%--- manual ---
man2save.fileDir        = man.fileDir;
man2save.fileName       = man.fileName;
man2save.filePath       = man.filePath;


%--- save selected fields of pars, exm, syn, syn, act, impt, t1t2 ---
%--- and all flags to file (no data)                              ---
% if nargin==1                % save as external/specific protocol
%     protFile = varargin{1};
% else                        % save as default/standard protocol file
%     protFile = pars.usrDefFile;
% end
if nargin==0            % save as default/standard protocol file
    protFile = pars.usrDefFile;
    clearVar = 1;
elseif nargin==1        % save as external/specific protocol
    [protFile, f_done] = SP2_Check4StrR(varargin{1});
    if ~f_done
        return
    end
    clearVar = 1;
elseif nargin==2
    [protFile, f_done] = SP2_Check4StrR(varargin{1});
    if ~f_done
        return
    end
    [clearVar, f_done] = SP2_Check4FlagR(varargin{2});
    if ~f_done
        return
    end
else
    fprintf(loggingfile,'%s -> Number of input variables >2 is not supported. Program aborted.\n',FCTNAME);
    return
end

%--- save protocol file ---
save(protFile,'pars2save','data2save','stab2save','mm2save','proc2save',...
              't1t22save','marss2save','mrsi2save','lcm2save','syn2save',...
              'tools2save','man2save','flag')
                
%--- info printout ---
if flag.verbose
    fprintf(loggingfile,'\nSettings written to file:\n<%s>\n',protFile');
    dirStruct = dir(protFile);
    fprintf(loggingfile,'file size: %.3f MByte\n',dirStruct.bytes/1e6);
else
    fprintf(loggingfile,'\nSettings written to protocol file ...\n');
end
fprintf(loggingfile,'INSPECTOR exited correctly.\n\n');
                    
%--- kill all windows, clear variables ---
a = gcf;
while (a > 1)
   delete(a)
   a = gcf;
end;
delete(a)
if clearVar
    clear all
end
