%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_AlignSpec2
%%
%%  Align spectrum 2 with spectrum 1.
%%  Supported optimization parameters:
%%  1) line broadening (LB)
%%  2) Zero order phase (PHC0)
%%  3) First order phase (PHC1)
%%  4) Amplitude scaling
%%  5) Frequency shift
%%  6) Baseline offset
%%  7) Spectral stretch
%%
%%  09-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc flag align

FCTNAME = 'SP2_Proc_AlignSpec2';


%--- init success flag ---
f_succ = 0;

%--- data processing ---
if flag.procUpdateCalc
    if ~SP2_Proc_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end
elseif ~isfield(proc,'spec1') || ~isfield(proc,'spec2')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
elseif ~isfield(proc.spec1,'spec') || ~isfield(proc.spec2,'spec')
    fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
    return
end

%--- check data existence and parameter consistency ---
if flag.procNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME);
    return
else                        % 2 spectra
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec1,'spec')
        fprintf('%s ->\nData of spectrum 1 does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nSpectral data set 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec2,'sw')
        fprintf('%s ->\nSpectrum 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec2,'spec')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    %--- SW (and dwell time) ---
    if SP2_RoundToNthDigit(proc.spec1.sw,2)~=SP2_RoundToNthDigit(proc.spec2.sw,2)
        fprintf('%s -> SW mismatch detected (%.2fMHz ~= %.2fMHz)\n',FCTNAME,...
                proc.spec1.sw,proc.spec2.sw)
        return
    end
    %--- number of points ---
    if proc.spec1.nspecC~=proc.spec2.nspecC
        fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
                proc.spec1.nspecC,proc.spec2.nspecC)
    end
end

%--- consistency check: at least one optimization parameter selected ---
if ~flag.procAlignLb && ~flag.procAlignGb && ~flag.procAlignPhc0 && ...
   ~flag.procAlignPhc1 && ~flag.procAlignScale && ~flag.procAlignShift && ...
   ~flag.procAlignOffset && ~flag.procAlignStretch && ~flag.procAlignPoly
   fprintf('\nAt least one optimization parameter has to be selected.\nProgram aborted.\n\n');
   return
end
if flag.procAlignPoly && flag.procFormat~=1         % polynomial && not real spectrum
    fprintf('Polynomial fitting is not supported for complex (real AND imaginary) spectrum alignment yet.\n');
    return
end
if flag.procAlignPoly && flag.procAlignOffset       % polynomial && offset
    fprintf('Polynomial fitting and separate offset optimization does not make sense.\nTip: Disable offset (as it is included in the polynomial)\n');
    return
end

%--- enable parameter flags if necessary ---
flag.procSpec2Lb      = flag.procSpec2Lb || flag.procAlignLb;
flag.procSpec2Gb      = flag.procSpec2Gb || flag.procAlignGb;
flag.procSpec2Phc0    = flag.procSpec2Phc0 || flag.procAlignPhc0;
flag.procSpec2Phc1    = flag.procSpec2Phc1 || flag.procAlignPhc1;
flag.procSpec2Scale   = flag.procSpec2Scale || flag.procAlignScale;
flag.procSpec2Shift   = flag.procSpec2Shift || flag.procAlignShift;
flag.procSpec2Offset  = flag.procSpec2Offset || flag.procAlignOffset;
flag.procSpec2Stretch = flag.procSpec2Stretch || flag.procAlignStretch;
set(fm.proc.spec2LbFlag,'Value',flag.procSpec2Lb==1);
set(fm.proc.spec2GbFlag,'Value',flag.procSpec2Gb==1);
set(fm.proc.spec2Phc0Flag,'Value',flag.procSpec2Phc0==1);
set(fm.proc.spec2Phc1Flag,'Value',flag.procSpec2Phc1==1);
set(fm.proc.spec2ScaleFlag,'Value',flag.procSpec2Scale==1);
set(fm.proc.spec2ShiftFlag,'Value',flag.procSpec2Shift==1);
set(fm.proc.spec2OffsetFlag,'Value',flag.procSpec2Offset==1);
set(fm.proc.spec2StretchFlag,'Value',flag.procSpec2Stretch==1);
SP2_Proc_ProcessWinUpdate

%--- extraction of spectral parts to be fitted ---
alignAllBin = zeros(1,proc.spec1.nspecC);        % init global index vector for ppm ranges to be used (binary format)
alignMinI   = zeros(1,proc.alignPpmN);           % init minimum ppm index vector
alignMaxI   = zeros(1,proc.alignPpmN);           % init maximum ppm index vector
for winCnt = 1:proc.alignPpmN
    [alignMinI(winCnt),alignMaxI(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(proc.alignPpmMin(winCnt),proc.alignPpmMax(winCnt),...
                                 proc.ppmCalib,proc.spec1.sw,proc.spec1.spec);
    if ~f_done
        fprintf('\n%s ->\nFrequency window extraction failed for section #2 (%.2f-%.2f ppm). Program aborted.\n',...
                winCnt,proc.alignPpmMin(winCnt),proc.alignPpmMax(winCnt))
        return
    end
    alignAllBin(alignMinI(winCnt):alignMaxI(winCnt)) = 1;
end
proc.alignAllInd = find(alignAllBin);           % global index vector including all ppm ranges

%--- extract spectral range(s) in ppm for polynomial fit ---
if flag.procAlignPoly
    proc.ppmVec         = (-proc.spec2.sw/2:proc.spec2.sw/(proc.spec2.nspecC-1):proc.spec2.sw/2)' + proc.ppmCalib;
    proc.alignAllIndPpm = proc.ppmVec(proc.alignAllInd);
    if proc.alignPolyOrder>1
        proc.alignAllIndPpm2  = proc.alignAllIndPpm.^2;
    end
    if proc.alignPolyOrder>2
        proc.alignAllIndPpm3  = proc.alignAllIndPpm.^3;
    end
    if proc.alignPolyOrder>3
        proc.alignAllIndPpm4  = proc.alignAllIndPpm.^4;
    end
    if proc.alignPolyOrder>4
        proc.alignAllIndPpm5  = proc.alignAllIndPpm.^5;
    end
    if proc.alignPolyOrder>5
        proc.alignAllIndPpm6  = proc.alignAllIndPpm.^6;
    end
    if proc.alignPolyOrder>6
        proc.alignAllIndPpm7  = proc.alignAllIndPpm.^7;
    end
    if proc.alignPolyOrder>7
        proc.alignAllIndPpm8  = proc.alignAllIndPpm.^8;
    end
    if proc.alignPolyOrder>8
        proc.alignAllIndPpm9  = proc.alignAllIndPpm.^9;
    end
    if proc.alignPolyOrder>9
        proc.alignAllIndPpm10 = proc.alignAllIndPpm.^10;
    end
end

%--- get reference spectrum 2 as is ---
refSpecZoom = proc.spec1.spec(proc.alignAllInd);

%--- extraction of spectral range ---
if proc.alignAmpWeight==1.0         % no weighting
    if flag.procFormat==1           % real part
        refSpecZoomFit = real(refSpecZoom);
    elseif flag.procFormat==2       % imaginary part
        refSpecZoomFit = imag(refSpecZoom);
    elseif flag.procFormat==3       % magnitude
        refSpecZoomFit = abs(refSpecZoom);
    else                            % phase, here: real AND imaginary
        refSpecZoomFit = [real(refSpecZoom); imag(refSpecZoom)];
    end
else                                % amplitude weighting
    if flag.procFormat==1           % real part
        refSpecZoomFit = abs(real(refSpecZoom)).^proc.alignAmpWeight .* sign(real(refSpecZoom));
    elseif flag.procFormat==2       % imaginary part
        refSpecZoomFit = abs(imag(refSpecZoom)).^proc.alignAmpWeight .* sign(imag(refSpecZoom));
    elseif flag.procFormat==3       % magnitude
        refSpecZoomFit = abs(refSpecZoom).^proc.alignAmpWeight;
    else                            % phase, here: real AND imaginary
        refSpecZoomFit = abs([real(refSpecZoom); imag(refSpecZoom)]).^proc.alignAmpWeight .* ...
                         sign([real(refSpecZoom); imag(refSpecZoom)]);
    end
end

%--- index handling for fitting parameters and parameter init ---
% note that the order here corresponds to the order in which the various data
% manipulations are applied during processing, i.e. in the fitting function
indCnt     = 0;                 % parameter counter
lb         = [];
coeffStart = [];
ub         = [];
if flag.procAlignLb
    % index handling
    indCnt = indCnt + 1;
    align.indLb = indCnt;
    
    % parameter handling
    lb = [lb -5];
    coeffStart = [coeffStart proc.spec2.lb];
    ub = [ub 20];
end
if flag.procAlignGb
    % index handling
    indCnt = indCnt + 1;
    align.indGb = indCnt;
    
    % parameter handling
    lb = [lb -5];
    coeffStart = [coeffStart proc.spec2.gb];
    ub = [ub 20];
end
if flag.procAlignShift
    % index handling
    indCnt = indCnt + 1;
    align.indShift = indCnt;
    
    % parameter handling
    lb = [lb proc.spec2.shift-20];
    coeffStart = [coeffStart proc.spec2.shift];
    ub = [ub proc.spec2.shift+20];
end
if flag.procAlignOffset
    % index handling
    indCnt = indCnt + 1;
    align.indOffset = indCnt;
    
    % parameter handling
    lb = [lb proc.spec2.offset-20];
    coeffStart = [coeffStart proc.spec2.offset];
    ub = [ub proc.spec2.offset+20];
end
if flag.procAlignPhc0
    % index handling
    indCnt = indCnt + 1;
    align.indPhc0 = indCnt;
    
    % parameter handling
    lb = [lb -359.9];
    coeffStart = [coeffStart proc.spec2.phc0];
    ub = [ub 360];
end
if flag.procAlignPhc1
    % index handling
    indCnt = indCnt + 1;
    align.indPhc1 = indCnt;
    
    % parameter handling
    lb = [lb -1000];
    coeffStart = [coeffStart proc.spec2.phc1];
    ub = [ub 1000];
end
if flag.procAlignScale
    % index handling
    indCnt = indCnt + 1;
    align.indScale = indCnt;
    
    % parameter handling
    lb = [lb 0];
    coeffStart = [coeffStart proc.spec2.scale];
    ub = [ub 30];
end
if flag.procAlignStretch
    % index handling
    indCnt = indCnt + 1;
    align.indStretch = indCnt;
    
    % parameter handling
    lb = [lb -proc.spec2.sf];
    coeffStart = [coeffStart proc.spec2.stretch];
    ub = [ub proc.spec2.sf];
end
if flag.procAlignPoly
    % index handling
    indCnt = indCnt + 1;
    align.indPoly = indCnt;         % 1st index of polynomial coefficients
    
    % parameter handling
    lb = [lb -1e4*ones(1,proc.alignPolyOrder+1)];
    coeffStart = [coeffStart proc.spec2.polycoeff(end-proc.alignPolyOrder:end)];     % (reversed) nth..0 order
    ub = [ub 1e4*ones(1,proc.alignPolyOrder+1)];
end

%--- integral cost-function ---
% refSpecZoomFit(end+1) = sum(refSpecZoomFit);
% refSpecZoomFit = [refSpecZoomFit; refSpecZoomFit];
% refSpecZoomFit(length(proc.alignAllInd)+1:end) = sum(refSpecZoomFit);

%--- create default vector ---
align.frequVecOrig = -proc.spec2.sw_h/2:proc.spec2.sw_h/(proc.spec2.nspecC-1):proc.spec2.sw_h/2;
align.frequVecNew  = align.frequVecOrig;        % init only
align.specReal     = real(proc.spec2.spec);     % init only
align.specImag     = imag(proc.spec2.spec);     % init only

%--- least-squares fit ---
if flag.verbose
    opt = optimset('Display','iter','TolFun',proc.alignTolFun,'MaxIter',proc.alignMaxIter);
else
    opt = optimset('Display','off','TolFun',proc.alignTolFun,'MaxIter',proc.alignMaxIter);
end
[coeffFit,resnorm,resid,exitflag,output] = ...
    lsqcurvefit('SP2_Proc_AlignSpec2FitFct',coeffStart,[],refSpecZoomFit,lb,ub,opt);

%--- parameter assignment ---
if flag.procAlignLb
    proc.spec2.lb     = coeffFit(align.indLb);
end
if flag.procAlignGb
    proc.spec2.gb     = coeffFit(align.indGb);
end
if flag.procAlignPhc0
    proc.spec2.phc0   = coeffFit(align.indPhc0);
end
if flag.procAlignPhc1
    proc.spec2.phc1   = coeffFit(align.indPhc1);
end
if flag.procAlignScale
    proc.spec2.scale  = coeffFit(align.indScale);
end
if flag.procAlignShift
    proc.spec2.shift  = coeffFit(align.indShift);
end
if flag.procAlignOffset
    proc.spec2.offset = coeffFit(align.indOffset);
end
if flag.procAlignStretch
    proc.spec2.stretch = coeffFit(align.indStretch);
end
if flag.procAlignPoly
    proc.spec2.polycoeff(end-proc.alignPolyOrder:end) = coeffFit(align.indPoly:end); 
end

%--- info printout ---
fprintf('\nAlignment result of spectrum 2:\n');
if flag.procAlignLb
    fprintf('LB:\t\t\t%.3f Hz\n',proc.spec2.lb);
end
if flag.procAlignGb
    fprintf('GB:\t\t\t%.3f Hz\n',proc.spec2.gb);
end
if flag.procAlignPhc0
    fprintf('PHC0:\t\t%.1f deg\n',proc.spec2.phc0);
end
if flag.procAlignPhc1
    fprintf('PHC1:\t\t%.1f deg\n',proc.spec2.phc1);
end
if flag.procAlignScale
    fprintf('Scaling:\t%.5f\n',proc.spec2.scale);
end
if flag.procAlignShift
    fprintf('Shift:\t\t%.3f Hz\n',proc.spec2.shift);
end
if flag.procAlignOffset
    fprintf('Offset:\t\t%.3f\n',proc.spec2.offset);
end
if flag.procAlignStretch
    fprintf('Stretch:\t%.3f Hz/ppm\n',proc.spec2.stretch);
end
if flag.procAlignPoly
    fprintf('Poly (fit, nth..0):\t%s\n',SP2_Vec2PrintStr(coeffFit(align.indPoly:end),2));
    fprintf('Poly (complete):\t%s\n',SP2_Vec2PrintStr(proc.spec2.polycoeff,2));
end
fprintf('Resnorm:\t%f\n\n',resnorm);

%--- display update ---
if flag.procAlignLb
    set(fm.proc.spec2LbVal,'String',sprintf('%.2f',proc.spec2.lb));
end
if flag.procAlignGb
    set(fm.proc.spec2GbVal,'String',sprintf('%.2f',proc.spec2.gb));
end
if flag.procAlignPhc0
    set(fm.proc.spec2Phc0Val,'String',sprintf('%.1f',proc.spec2.phc0));
end
if flag.procAlignPhc1
    set(fm.proc.spec2Phc1Val,'String',sprintf('%.1f',proc.spec2.phc1));
end
if flag.procAlignScale
    set(fm.proc.spec2ScaleVal,'String',sprintf('%.3f',proc.spec2.scale));
end
if flag.procAlignShift
    set(fm.proc.spec2ShiftVal,'String',sprintf('%.3f',proc.spec2.shift));
end
if flag.procAlignOffset
    set(fm.proc.spec2OffsetVal,'String',sprintf('%.4f',proc.spec2.offset));
end
if flag.procAlignStretch
    set(fm.proc.spec2StretchVal,'String',sprintf('%.5f',proc.spec2.stretch));
end

%--- spectrum update / result visualization ---
% spectrum superposition
if flag.procAlignPoly
    %--- keep parameters and prevent double-consideration of baseline ---
    flagProcApplyPoly1  = flag.procApplyPoly1;
    flagProcApplyPoly2  = flag.procApplyPoly2;
    flag.procApplyPoly1 = 0;
    flag.procApplyPoly2 = 0;
    
    %--- default processing (without polynomial) ---
    if ~SP2_Proc_ProcComplete
        fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
        return
    end

    %--- add polynomial ---
    switch proc.alignPolyOrder
        case 0
            proc.polyFit = coeffFit(align.indPoly)*ones(1,proc.spec2.nspecC)';
        case 1
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec + ...
                           coeffFit(align.indPoly+1);
        case 2
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec + ...
                           coeffFit(align.indPoly+2);
        case 3
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec + ...
                           coeffFit(align.indPoly+3);
        case 4
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^4 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+3)*proc.ppmVec + ...
                           coeffFit(align.indPoly+4);
        case 5
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^5 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^4 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+3)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+4)*proc.ppmVec + ...
                           coeffFit(align.indPoly+5);
        case 6
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^6 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^5 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec.^4 + ...
                           coeffFit(align.indPoly+3)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+4)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+5)*proc.ppmVec + ...
                           coeffFit(align.indPoly+6);
        case 7
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^7 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^6 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec.^5 + ...
                           coeffFit(align.indPoly+3)*proc.ppmVec.^4 + ...
                           coeffFit(align.indPoly+4)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+5)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+6)*proc.ppmVec + ...
                           coeffFit(align.indPoly+7);
        case 8
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^8 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^7 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec.^6 + ...
                           coeffFit(align.indPoly+3)*proc.ppmVec.^5 + ...
                           coeffFit(align.indPoly+4)*proc.ppmVec.^4 + ...
                           coeffFit(align.indPoly+5)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+6)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+7)*proc.ppmVec + ...
                           coeffFit(align.indPoly+8);
        case 9
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^9 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^8 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec.^7 + ...
                           coeffFit(align.indPoly+3)*proc.ppmVec.^6 + ...
                           coeffFit(align.indPoly+4)*proc.ppmVec.^5 + ...
                           coeffFit(align.indPoly+5)*proc.ppmVec.^4 + ...
                           coeffFit(align.indPoly+6)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+7)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+8)*proc.ppmVec + ...
                           coeffFit(align.indPoly+9);
        case 10
            proc.polyFit = coeffFit(align.indPoly)*proc.ppmVec.^10 + ...
                           coeffFit(align.indPoly+1)*proc.ppmVec.^9 + ...
                           coeffFit(align.indPoly+2)*proc.ppmVec.^8 + ...
                           coeffFit(align.indPoly+3)*proc.ppmVec.^7 + ...
                           coeffFit(align.indPoly+4)*proc.ppmVec.^6 + ...
                           coeffFit(align.indPoly+5)*proc.ppmVec.^5 + ...
                           coeffFit(align.indPoly+6)*proc.ppmVec.^4 + ...
                           coeffFit(align.indPoly+7)*proc.ppmVec.^3 + ...
                           coeffFit(align.indPoly+8)*proc.ppmVec.^2 + ...
                           coeffFit(align.indPoly+9)*proc.ppmVec + ...
                           coeffFit(align.indPoly+10);
    end
    
    %--- plot spectrum and baseline ---
    if flag.verbose
        if ~SP2_Proc_PlotSpec2(0)
            return
        end
        yLim = get(gca,'YLim');
        hold on
        for winCnt = 1:proc.alignPpmN
            plot([proc.alignPpmMin(winCnt) proc.alignPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
            plot([proc.alignPpmMax(winCnt) proc.alignPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
        end
        if flag.procPpmShow     % direct
            ppmMin = proc.ppmShowMin;
            ppmMax = proc.ppmShowMax;
        else                    % full sweep width (symmetry assumed)
            ppmMin = -proc.spec2.sw/2 + proc.ppmCalib;
            ppmMax = proc.spec2.sw/2  + proc.ppmCalib;
        end
        [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,proc.spec2.sw,real(proc.spec2.spec));
        plot(ppmZoom,proc.polyFit(minI:maxI),'r')
        hold off
    end
    
    %--- data modification ---
    proc.spec2.spec = proc.spec2.spec - proc.polyFit;
    proc.specDiff   = proc.spec1.spec - proc.spec2.spec;
    
    %--- display (only) ---
    if ~SP2_Proc_PlotSpecSuperpos(0)
        return
    end
    
    %--- restore flag settings ---
    flag.procApplyPoly1 = flagProcApplyPoly1;
    flag.procApplyPoly2 = flagProcApplyPoly2;  
else
    %--- standard processing ---
    if ~SP2_Proc_ProcAndPlotSpecSuperpos(0)
        return
    end
end
xLim = get(gca,'XLim');
yLim = get(gca,'YLim');
hold on
for winCnt = 1:proc.alignPpmN
    plot([proc.alignPpmMin(winCnt) proc.alignPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
    plot([proc.alignPpmMax(winCnt) proc.alignPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
end
hold off
fprintf('Superposition plot limits %s\n',SP2_Vec2PrintStr([xLim, yLim],3,1));

%--- difference spectrum ---
if ~SP2_Proc_PlotSpecDiff(0)
    return
end
yLim = get(gca,'YLim');
hold on
for winCnt = 1:proc.alignPpmN
    plot([proc.alignPpmMin(winCnt) proc.alignPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
    plot([proc.alignPpmMax(winCnt) proc.alignPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
end
hold off

%--- result evaluation: data extraction ---
if flag.procFormat==1           % real part
    spec1Zoom    = real(proc.spec1.spec(proc.alignAllInd));
    spec2Zoom    = real(proc.spec2.spec(proc.alignAllInd));
    specDiffZoom = real(proc.specDiff(proc.alignAllInd));
elseif flag.procFormat==2       % imaginary part
    spec1Zoom    = imag(proc.spec1.spec(proc.alignAllInd));
    spec2Zoom    = imag(proc.spec2.spec(proc.alignAllInd));
    specDiffZoom = imag(proc.specDiff(proc.alignAllInd));
elseif flag.procFormat==3       % magnitude
    spec1Zoom    = abs(proc.spec1.spec(proc.alignAllInd));
    spec2Zoom    = abs(proc.spec2.spec(proc.alignAllInd));
    specDiffZoom = abs(proc.specDiff(proc.alignAllInd));
else                            % phase, here: real AND imaginary
    spec1Zoom    = [real(proc.spec1.spec(proc.alignAllInd)); imag(proc.spec1.spec(proc.alignAllInd))];
    spec2Zoom    = [real(proc.spec2.spec(proc.alignAllInd)); imag(proc.spec2.spec(proc.alignAllInd))];
    specDiffZoom = [real(proc.specDiff(proc.alignAllInd)); real(proc.specDiff(proc.alignAllInd))];
end

%--- result evaluation: data analysis ---
fprintf('Aligned spectrum 2:\n');
fprintf('Min/Max/Mean/Median/SD = %.3f/%.3f/%.3f/%.3f/%.3f\n',min(spec2Zoom),...
        max(spec2Zoom),mean(spec2Zoom),median(spec2Zoom),std(spec2Zoom))
fprintf('Reference spectrum 1:\n');
fprintf('Min/Max/Mean/Median/SD = %.3f/%.3f/%.3f/%.3f/%.3f\n',min(spec1Zoom),...
        max(spec1Zoom),mean(spec1Zoom),median(spec1Zoom),std(spec1Zoom))
fprintf('Difference spectrum:\n');
fprintf('Min/Max/Mean/Median/SD = %.3f/%.3f/%.3f/%.3f/%.3f\n',min(specDiffZoom),...
        max(specDiffZoom),mean(specDiffZoom),median(specDiffZoom),std(specDiffZoom))
fprintf('Min/max ratio difference vs. spectrum 2: %.2f%%\n',...
        100*(max(specDiffZoom)-min(specDiffZoom))/(max(spec2Zoom)-min(spec2Zoom)))
fprintf('Integral spec2/spec1/diff: %f/%f/%f\n',...
        sum(spec2Zoom),sum(spec1Zoom),sum(specDiffZoom))
fprintf('SD ratio difference vs. spectrum 2: %.2f%%\n\n',100*std(specDiffZoom)/std(spec2Zoom));

%--- update success flag ---
f_succ = 1;





end
