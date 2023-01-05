%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Stab_StabilityAnalysis
%%
%% Function to check phase and amplitude stability of an FID series.
%% In the frequency domain max. frequency position and FWHM is analyzed.
%%
%% 06/2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global stab flag

FCTNAME = 'SP2_Stab_StabilityAnalysis';


%--- init success flag ---
f_succ = 0;

%--- line broadening ---
flag.stabLb    = 1;                 % spectral line broadening
stab.lb        = 5;                 % exponential line broadening [Hz]

%--- spectral zero filling ---
flag.stabZf    = 1;                 % spectral zero-filling
stab.zf        = 1024*16;           % desired final number of complex data points (after ZF)

%--- ECC ---
flag.stabEcc         = 1;           % eddy currents are corrected via 1st scan

%--- peak maximum determination ---
flag.stabSpline      = 1;           % spline interpolation for improved maximum localization (0: simple maximum search)
stab.splFac          = 25;          % spline interpolation factor for magn. spectrum peak localization
flag.stabPlotSpline  = 0;           % plot part of the spline interpolation results
stab.n2plot          = 10;          % number of spline interpolation results to be plotted
stab.fitWinHz        = 200;         % frequency range/window [Hz] for peak maximum analysis
flag.stabFreqVerbose = 0;           % explicit printout of all (relative and absolute) frequency values

%--- extract acquisitions ---
flag.stabExtractAcq   = 1;                 % extracts single acquisition or series of acquisitions assigned by 'acqVec'

%--- linear detrending of frequency evolution ---
flag.stabFrequDetr    = 1;                 % linear detrending of frequency evolution

%--- phase offset removal ---
flag.stabPhaseOffRm   = 0;                 % 0: off, 1: with respect to the 1st point, 2: with respect to the mean value

%--- Fourier analysis of time series ---
flag.stabFftAnalysis  = 1;                 % Fourier analsys of amplitudes, phases and frequencies
stab.frequLim         = 2;                 % minimum display frequency [pts] (should be at least 2 to avoid the offset representation)
stab.periodLim        = 0;                 % minimum value for the oscillation periods [s], 0: full range
flag.stabAmplNorm     = 1;                 % 1: amplitude normalization, 0: no scaling at all

%--- FWHM determination ---
flag.stabFwhmAnalysis = 0;                 % performs FWHM analysis (see f_fwhmEcc)
flag.stabFwhmZeroPh   = 0;                 % individual zero order phasing by maximum search before FWHM determination
flag.stabFwhmRealMagn = 0;                 % 1: real spectra, 0: magnitude spectra for FWHM analysis
flag.stabFwhmTimeVsNR = 1;                 % 1: time axis, 0: acquisition number [NR]

%--- superposition plot ---
flag.stabPlotSuperPos  = 1;               % plots real and magnitude peak superposition
flag.stabSpCenter2SFO1 = 0;               % 1: plot centered to SFO1, 0: plot centered to first peak
stab.plotWinHz         = 500;            % frequency range/window [Hz] to be displayed in superposition plot

%--- output flags and parameters ---
flag.stabPlotSingleAcqs = 0;               % plots single acquisitions to particular figures
flag.stabPlotDatConnect = 0;               % 1: plot data connections, 0: data points only
flag.stabDisplHrVsMin   = 0;               % time axis mode, 1: hour (day time), 0: minutes (relative to first data point)
flag.stabVerbose        = 1;               % explicit result printout
flag.stabDbFirstAcq     = 0;               % show intermediate calculation steps for first FID to check data conversion
                                    % This might be helpful to check correct convdta conversion for unknown filters
%--- data export option ---
flag.stabExpFdFrequ   = 0;                  % export (frequency domain) frequencies
stab.fdFrequYmin      = -0.3;               % minimum frequency value (y-axis)
stab.fdFrequYmax      = 1;                  % maximum frequency value (y-axis)
stab.fdFrequSymb      = 'o';                % data symbol
stab.fdFrequColor     = [1 0 0];            % plot color
stab.fdFrequPos       = [340 263 672 466];  % figure dimensions

flag.stabExpFftFrequ  = 0;                  % export (frequency domain) frequencies
stab.fftFrequColor    = [0 0 1];            % plot color
stab.fftFrequPos      = [340 263 672 466];  % figure dimensions
flag.stabFftFrequMax  = 0.6;                % 0: full frequency range, >0: maximum frequency limit
flag.stabFftAmplMax   = 0;                  % 0: automatic y-axis assignment, >0: direct assignment of y-axis limit


%---------------------------------------------------------------------------------------------------------------------------------
%-----------     P R O G R A M     S T A R T     ---------------------------------------------------------------------------------
%---------------------------------------------------------------------------------------------------------------------------------
t0 = clock;         % start time measurement

%--- data assignment ---
if ~SP2_Stab_DataAssignment
    fprintf('%s ->\nData assignment failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- path, file and parameter handling ---------------------
FCTNAME = 'SP2_Stab_StabilityAnalysis';
fprintf('\n%s started ...\n',FCTNAME);

%--- reducec/extract NR data vector ---
if flag.stabExtractAcq          % selected range of spectra
    %--- data assignment: selected FID range ---
    if stab.specFirst<1
        fprintf('%s -> 1st selected spectrum is <1. Program aborted.',FCTNAME);
        return
    elseif stab.specLast>stab.nr
        fprintf('%s -> Upper end of selected spectral series exceeds NR (%.0f>%.0f). Program aborted',FCTNAME,stab.specLast,stab.nr);
        return
    end
    stab.ana.specFirst = stab.specFirst;
    stab.ana.specLast  = stab.specLast;
    stab.ana.nr        = stab.specLast-stab.specFirst+1;
else                            % full range, i.e. FIDs
    %--- data assignment: simple copy ---
    stab.ana.specFirst = 1;
    stab.ana.specLast  = stab.nr;
    stab.ana.nr        = stab.nr;
end
stab.ana.fid       = stab.fidOrig(:,stab.ana.specFirst:stab.ana.specLast);
stab.ana.tNR_s     = stab.tNR_s(stab.ana.specFirst:stab.ana.specLast);      % relative
stab.ana.tNR_h     = stab.tNR_h(stab.ana.specFirst:stab.ana.specLast);      % relative
stab.ana.tNR_min   = stab.tNR_min(stab.ana.specFirst:stab.ana.specLast);    % relative
stab.ana.dur_s     = stab.tr*stab.ana.nr;
stab.ana.dur_min   = stab.ana.dur_s/60;

%--- info printout ---
if flag.stabExtractAcq          % selected range of spectra
    %--- info printout ---
    fprintf('NR [%.0f %.0f] (%.0f of %.0f), TR %.1f s, dur %.1f min of %.1f min, %.0f pts, sw %.0f Hz\n',...
            stab.ana.specFirst,stab.ana.specLast,stab.ana.nr,stab.nr,stab.tr,stab.ana.dur_min,stab.dur_min,stab.nspecC,stab.sw_h)
else                            % full range, i.e. FIDs
    %--- info printout ---
    fprintf('NR [1 %.0f], TR %.1f s, dur %.1f min, %.0f pts, sw %.0f Hz\n',...
            stab.ana.nr,stab.tr,stab.ana.dur_min,stab.nspecC,stab.sw_h)
end

%--- time axis to be plotted ---
if flag.stabDisplHrVsMin            % day time [h]
    stab.tVecPlot = stab.ana.tNR_h;
    stab.tLabel   = 'day time [h]';
else                                % minute scale (relative)
    stab.tVecPlot = stab.ana.tNR_min;
    stab.tLabel   = 'time [min]';
end
    
%--- exponential line broadening ---
if flag.stabLb
    stab.dwell   = 2/(stab.sw_h);        % '2' due to complex data points
	expLbVec     = exp(-stab.lb*stab.dwell*(0:stab.nspecC-1)*pi/2);
    expLbMat     = repmat(expLbVec,stab.ana.nr,1)';
    stab.ana.fid = expLbMat .* stab.ana.fid;
end

%--- FID phase and amplitude analysis ---
stab.phase = angle(stab.ana.fid(1,:))*180/pi;        % phase of first FID point
stab.ampl  = abs(stab.ana.fid(1,:));                 % magnitude amplitude of 1st FID point

%--- phase offset removal ---
if flag.stabPhaseOffRm==1                  % 1st point
    stab.phase = stab.phase - stab.phase(1);
elseif flag.stabPhaseOffRm==2              % mean
    stab.phase = stab.phase - mean(stab.phase);
elseif flag.stabPhaseOffRm~=0
    fprintf('%s -> flag value f_phaseOffRm=%.0f is not allowed (legal values: 0,1,2)',FCTNAME,flag.stabPhaseOffRm);
    return
end

%--- ECC ---
if flag.stabEcc        % eddy currents are corrected via 1st scan
    stab.phaseEcc = angle(stab.ana.fid(:,1));                                     % get time domain phase of first FID
    for icnt = 1:stab.ana.nr
        stab.ana.fid(:,icnt) = stab.ana.fid(:,icnt) .* exp(-1i*stab.phaseEcc);    % ECC for each FID
    end
end

%--- FFT including potential zero-filling ---
if flag.stabZf
    stab.spec = fftshift(fft(stab.ana.fid,stab.zf,1),1);
else
    stab.spec = fftshift(fft(stab.ana.fid,[],1),1);
end
stab.nspecC  = size(stab.spec,1);
stab.hzPerPt = stab.sw_h/(stab.nspecC-1);                                   % Hertz per point (frequency resolution)
stab.fAxis   = -stab.sw_h/2:stab.sw_h/(stab.nspecC-1):stab.sw_h/2;          % frequency axis

%--- analysis of frequency variations (simple peak picking) ---             % factor to translate point to frequency scale                    
stab.specMagn     = abs(stab.spec);                                         % calculate magnitude spectra
[stab.maxMagnValDiscr,stab.maxMagnIndDiscr] = max(stab.specMagn);           % maximum value indices are used for peak localization      
stab.maxMagnHzDiscr = (stab.maxMagnIndDiscr-stab.maxMagnIndDiscr(1)) * stab.hzPerPt;
stab.fitWinPts    = stab.fitWinHz / stab.hzPerPt;                           % translate frequency window to point window
stab.indMin       = max(1,round(stab.maxMagnIndDiscr(1)-stab.fitWinPts/2)); % lower index of frequency window 
stab.indMax       = min(stab.nspecC,round(stab.maxMagnIndDiscr(1)+stab.fitWinPts/2));   % higher index of frequency window
stab.specZoom     = stab.spec(stab.indMin:stab.indMax,:);                   % get zoom of complex spectra
stab.specMagnZoom = stab.specMagn(stab.indMin:stab.indMax,:);               % get zoom of magnitude spectra
stab.maxMagnInd   = 0;                                                      % init/reset
stab.maxMagnVal   = 0;                                                      % init/reset
for icnt = 1:stab.ana.nr                                                    % determine peak max and position [pts]
    if flag.stabSpline                                                      % spline interpolation
        if flag.stabPlotSpline && icnt<=stab.n2plot
            [stab.maxMagnVal(icnt),stab.maxMagnInd(icnt)] = SP2_SplineMaxDeterm(stab.specMagnZoom(:,icnt),stab.splFac,1);
        else
            [stab.maxMagnVal(icnt),stab.maxMagnInd(icnt)] = SP2_SplineMaxDeterm(stab.specMagnZoom(:,icnt),stab.splFac);      
        end
        stab.maxMagnInd(icnt) = stab.indMin + stab.maxMagnInd(icnt) -1;        % translate index from zoomed range to global index
    else        % previous result of pure maximum search is used
        stab.maxMagnVal = stab.maxMagnValDiscr;
        stab.maxMagnInd = stab.maxMagnIndDiscr;
    end
end
% determination of peak frequency
stab.maxMagnHzOff = (stab.maxMagnInd-(stab.nspecC+1)/2) * stab.hzPerPt;         % frequency offset
stab.maxMagnHzAbs = 1e6*stab.sf + stab.maxMagnHzOff;                            % absolute frequency
stab.maxMagnHz    = (stab.maxMagnInd-stab.maxMagnInd(1)) * stab.hzPerPt;        % frequency relative to first scan
if flag.stabFreqVerbose
    fprintf('\nFREQUENCY ANALYSIS\n');
    for iNR = 1:stab.ana.nr
        fprintf('NR %.0f / %s \tfrequency (rel./offset/abs.): %.1f Hz / %.1f Hz / %.1f Hz\n'...
                ,iNR,SP2_Sec2ClockStr(stab.tNR_s(iNR)),stab.maxMagnHz(iNR),stab.maxMagnHzOff(iNR),stab.maxMagnHzAbs(iNR))             
    end
    fprintf('\n');
end

%--- linear detrending ---
if flag.stabFrequDetr
    fitCoeff      = polyfit(1:stab.ana.nr,stab.maxMagnHz,1);                    % linear fitting
    stab.maxMagnHz = stab.maxMagnHz - (fitCoeff(2) + fitCoeff(1)*(0:stab.ana.nr-1));
    stab.driftPerH = fitCoeff(1)*(stab.ana.nr-1) / (stab.tNR_h(end)-stab.tNR_h(1));
    if flag.stabVerbose
        fprintf('linear detrending of frequency development: fitCoeff %.3f/%.3f (slope/offset)\n',...
                fitCoeff(1),fitCoeff(2))
        fprintf('frequency drift: %.2f Hz/min = %.3f Hz/h\n',stab.driftPerH/60,stab.driftPerH);
    end
end

%--- FWHM analysis ---
if flag.stabFwhmAnalysis
    fprintf('\nFWHM ANALYSIS:\n');
    for iNR = 1:stab.ana.nr
        if flag.stabFwhmRealMagn
            if flag.stabFwhmZeroPh
                [specTr,stab.ph0(iNR)] = SP2_ZeroPhasing(stab.spec(:,iNR)');                  % zero order phasing by maximum search
                stab.spec(:,iNR) = specTr';    
            end
            stab.fwhmPts(iNR) = SP2_FWHM(real(stab.spec(:,iNR)));                                % FWHM determination [pts]
        else        % magnitude spectra
            stab.fwhmPts(iNR) = SP2_FWHM(abs(stab.spec(:,iNR)));                                 % FWHM determination [pts]
        end
        fwhm_hz = stab.hzPerPt * stab.fwhmPts(iNR);       % pure FWHM calculation result (no consideration of real/magn and previous LB correction so far)
        if flag.stabLb
            if flag.stabFwhmRealMagn        % real
                fprintf('NR %.0f / %s \tFWHM(real) %.1f Hz at lb %.1fHz => %.1f Hz\n'...
                        ,iNR,SP2_Sec2ClockStr(stab.tNR_s(iNR)),fwhm_hz,stab.lb,fwhm_hz-stab.lb)
                stab.fwhmHz(iNR) = fwhm_hz-stab.lb;    
            else                            % magnitude
                fprintf('NR %.0f / %s \tFWHM(magn.) %.1f Hz at lb %.1f Hz => FWHM(real): %.1f Hz at lb %.1f Hz => %.1f Hz\n'...
                        ,iNR,SP2_Sec2ClockStr(stab.tNR_s(iNR)),fwhm_hz,stab.lb*sqrt(3),fwhm_hz/sqrt(3),stab.lb,fwhm_hz/sqrt(3)-stab.lb)
                stab.fwhmHz(iNR) = fwhm_hz/sqrt(3)-stab.lb;    
            end
        else
            if flag.stabFwhmRealMagn        % real
                fprintf('NR %.0f / %s \tFWHM(real) %.1f Hz\n',iNR,SP2_Sec2ClockStr(stab.tNR_s(iNR)),fwhm_hz);
                stab.fwhmHz(iNR) = fwhm_hz;    
            else                            % magnitude
                fprintf('NR %.0f / %s \tFWHM(magn.) %.1f Hz => FWHM(real): %.1f Hz\n',iNR,SP2_Sec2ClockStr(stab.tNR_s(iNR)),fwhm_hz,fwhm_hz/sqrt(3));
                stab.fwhmHz(iNR) = fwhm_hz/sqrt(3);    
            end
        end
    end
    fprintf('\n');
	if flag.stabDbFirstAcq
        fprintf('%s -> zero order phasing:\n%s',FCTNAME,SP2_Vec2PrintStr(stab.ph0,0));
	    fprintf('%s -> FWHM determination:\n%s',FCTNAME,SP2_Vec2PrintStr(stab.fwhmHz,1));
	end
end


%--- data analysis ---        
if flag.stabPlotSuperPos
    StabAnaLoc_SuperPosition
end

%--- consistency check ---
if stab.specFirst==stab.specLast
    fprintf('%s ->\nRange of bins must be larger than 1 for bin statistics. Program aborted.\n',FCTNAME);
    return
end

StabAnaLoc_TimeDomain
if stab.ana.nr>4     % necessary to have at least 2 points for the frequency window (5/2-1=2)
    StabAnaLoc_FrequencyDomain
end
if flag.stabFwhmAnalysis
    StabAnaLoc_FWHM_Analysis
end
if flag.stabFftAnalysis            % Fourier analysis of phase, amplitude and frequency development
    StabAnaLoc_FourierAnalysis
end
if flag.stabDbFirstAcq
    StabAnaLoc_PlotCalcTracking
end
if flag.stabPlotSingleAcqs
    StabAnaLoc_PlotSingleAcqs
end

eTime = etime(clock,t0);
fprintf('%s completed (elapsed time %.1f minutes)\n\n',FCTNAME,eTime/60);
% program end %

%--- update success flag ---
f_succ = 1;


%--------------------------------------------------------------------------
%---   L O C A L   F U N C T I O N S   ------------------------------------
%--------------------------------------------------------------------------
function StabAnaLoc_SuperPosition

global stab flag

% determine frequency window (centered on discrete peak position of first magnitude spectrum)
stab.plotWinPts = stab.plotWinHz / stab.hzPerPt;                                       % translate frequency window to point window
if flag.stabSpCenter2SFO1      % center on synthesizer frequency SFO1
    ind2center = (stab.nspecC+1)/2;
else                        % center on first peak
    ind2center = stab.maxMagnInd(1);
end
stab.indMinPlot = max(1,round(ind2center-stab.plotWinPts/2));                  % lower index of frequency window 
stab.indMaxPlot = min(stab.nspecC,round(ind2center+stab.plotWinPts/2));         % higher index of frequency window

% plot superposition
fh_spos = figure;
colorMat = colormap(hsv(stab.ana.nr));
namestr = sprintf(' Superposition');
set(fh_spos,'NumberTitle','off','Name',namestr,'Position',[436 90 672 835])
subplot(3,1,1)      % real spectra
title('Unphased Real Spectra')
hold on
cCnt = 1;
for icnt = 1:stab.ana.nr
    plot(stab.fAxis(stab.indMinPlot:stab.indMaxPlot),real(stab.spec(stab.indMinPlot:stab.indMaxPlot,icnt)),'Color',colorMat(cCnt,:))
    cCnt = cCnt+1;
end
hold off
for icnt = 1:stab.ana.nr             % determine plot limits
    [limVecTmp(1) limVecTmp(2) limVecTmp(3) limVecTmp(4)] = SP2_IdealAxisValues(stab.fAxis(stab.indMinPlot:stab.indMaxPlot),real(stab.spec(stab.indMinPlot:stab.indMaxPlot,icnt)));
    if icnt==1
        limVec = limVecTmp;    
    end
    limVec = SP2_ModifyAxisValues(limVec,limVecTmp);
end
hold off
axis([limVec(1) limVec(2) limVec(3) limVec(4)]);
set(gca,'xDir','reverse');
ylabel('amplitude [a.u.]')
subplot(3,1,2)      % magnitude spectra
title('Imaginary Spectra')
hold on
cCnt = 1;
for icnt = 1:stab.ana.nr
    plot(stab.fAxis(stab.indMinPlot:stab.indMaxPlot),imag(stab.spec(stab.indMinPlot:stab.indMaxPlot,icnt)),'Color',colorMat(cCnt,:))
    cCnt = cCnt+1;
end
hold off
for icnt = 1:stab.ana.nr         % determine plot limits
    [limVecTmp(1) limVecTmp(2) limVecTmp(3) limVecTmp(4)] = SP2_IdealAxisValues(stab.fAxis(stab.indMinPlot:stab.indMaxPlot),imag(stab.spec(stab.indMinPlot:stab.indMaxPlot,icnt)));
    if icnt==1
        limVec = limVecTmp;    
    end
    limVec = SP2_ModifyAxisValues(limVec,limVecTmp);
end
hold off
axis([limVec(1) limVec(2) limVec(3) limVec(4)]);
set(gca,'xDir','reverse');
ylabel('amplitude [a.u.]')
subplot(3,1,3)      % magnitude spectra
title('Magnitude Spectra')
hold on
cCnt = 1;
for icnt = 1:stab.ana.nr
    plot(stab.fAxis(stab.indMinPlot:stab.indMaxPlot),abs(stab.spec(stab.indMinPlot:stab.indMaxPlot,icnt)),'Color',colorMat(cCnt,:))
    cCnt = cCnt+1;
end
hold off
for icnt = 1:stab.ana.nr         % determine plot limits
    [limVecTmp(1) limVecTmp(2) limVecTmp(3) limVecTmp(4)] = SP2_IdealAxisValues(stab.fAxis(stab.indMinPlot:stab.indMaxPlot),abs(stab.spec(stab.indMinPlot:stab.indMaxPlot,icnt)));
    if icnt==1
        limVec = limVecTmp;    
    end
    limVec = SP2_ModifyAxisValues(limVec,limVecTmp);
end
hold off
axis([limVec(1) limVec(2) limVec(3) limVec(4)]);
set(gca,'xDir','reverse');
xlabel('frequency [Hz]')
ylabel('amplitude [a.u.]')


%--------------------------------------------------------------------------
function StabAnaLoc_TimeDomain

global stab flag

fh1 = figure;
namestr = sprintf(' Stability Analysis (Time Domain)');
set(fh1,'NumberTitle','off','Name',namestr,'Position',[549 224 672 597]);
subplot(2,1,1)

plot(stab.ana.specFirst:stab.ana.specLast,stab.phase,'r+')
if flag.stabPlotDatConnect
    hold on
    plot(stab.ana.specFirst:stab.ana.specLast,stab.phase)
    hold off
end
[minX maxX minY maxY] = SP2_IdealAxisValues(stab.ana.specFirst:stab.ana.specLast,stab.phase);
if maxY>0
    maxY = maxY * 1.2;
else
    maxY = maxY * 0.85;
end
axis([minX maxX minY maxY])
title('Phase of 1st FID Point')
xLabel = sprintf('repetition number [1], TR=%.1fms',stab.tr);
xlabel(xLabel)
ylabel('phase angle [deg]')
stdDev = sprintf('std.dev.=%.1f, max.jump=%.1f, max.diff.=%.1f',...
                 std(stab.phase),max(abs(diff(stab.phase))),max(stab.phase)-min(stab.phase));
text(minX+(maxX-minX)/20,maxY-(maxY-minY)/10,stdDev)
subplot(2,1,2)
plot(stab.tVecPlot,stab.ampl,'r+')
if flag.stabPlotDatConnect
    hold on
    plot(stab.tVecPlot,stab.ampl,'r+')
    hold off
end
[minX maxX minY maxY] = SP2_IdealAxisValues(stab.tVecPlot,stab.ampl);
maxY = maxY * 1.01;
axis([minX maxX minY maxY])
title('Amplitude of 1st FID Point')
xlabel(stab.tLabel)
ylabel('amplitude [a.u.]')
stdDev = sprintf('std=%.0f, std/m=%.1f%%, max.jump/m=%.1f%%, max.diff/m=%.1f%%',...
                 std(stab.ampl),100*std(stab.ampl)/mean(stab.ampl),100*max(abs(diff(stab.ampl)))/mean(stab.ampl),...
                 100*(max(stab.ampl)-min(stab.ampl))/mean(stab.ampl));
text(minX+(maxX-minX)/20,maxY-(maxY-minY)/10,stdDev)

% explicit printout
if flag.stabVerbose
    fprintf('time domain analysis (1st point):\n');
    fprintf('phase variation:      %.2fdeg (std), %.2fdeg (max.jump), %.2fdeg (max.diff)\n',...
            std(stab.phase),max(abs(diff(stab.phase))),max(stab.phase)-min(stab.phase));
    fprintf('amplitude variation:  %.0f (std), %.2f%% (std/mean), %.2f%% (max.jump/mean), %.2f%% (max.diff/mean)\n',...
            std(stab.ampl),100*std(stab.ampl)/mean(stab.ampl),100*max(abs(diff(stab.ampl)))/mean(stab.ampl),...
            100*(max(stab.ampl)-min(stab.ampl))/mean(stab.ampl));
end


%---------------------------------------------------------------------------------
function StabAnaLoc_FrequencyDomain

global stab flag

fh2 = figure;
namestr = sprintf(' Stability Analysis (Frequency Domain)');
set(fh2,'NumberTitle','off','Name',namestr,'Position',[340 132 672 597]);
subplot(2,1,1)
plot(stab.ana.specFirst:stab.ana.specLast,stab.maxMagnHz,'r+')
if flag.stabPlotDatConnect
    hold on
    plot(stab.ana.specFirst:stab.ana.specLast,stab.maxMagnHz)
    hold off
end
[minX maxX minY maxY] = SP2_IdealAxisValues(stab.ana.specFirst:stab.ana.specLast,stab.maxMagnHz);
if maxY>0
    maxY = maxY*1.5;
else
    maxY = maxY*0.7;
end
axis([minX maxX minY maxY])
if flag.stabSpline
    titlestr = sprintf('frequency variation (resolution: %.2fHz)',stab.hzPerPt/stab.splFac);
else
    titlestr = sprintf('frequency variation (resolution: %.2fHz)',stab.hzPerPt);
end
title(titlestr)
xLabel = sprintf('repetition number [1], TR=%.0fms',stab.tr);
xlabel(xLabel)
ylabel('delta frequency [Hz]')
stdDev = sprintf('std.dev.=%.1f, max.jump=%.1f, max.diff=%.1f',...
                 std(stab.maxMagnHz),max(abs(diff(stab.maxMagnHz))),max(stab.maxMagnHz)-min(stab.maxMagnHz));
text(minX+(maxX-minX)/20,maxY-(maxY-minY)/10,stdDev)
subplot(2,1,2)
plot(stab.tVecPlot,stab.maxMagnVal,'r+')
if flag.stabPlotDatConnect
    hold on
    plot(stab.tVecPlot,stab.maxMagnVal)
    hold off
end
[minX maxX minY maxY] = SP2_IdealAxisValues(stab.tVecPlot,stab.maxMagnVal);
maxY = maxY*1.01;
axis([minX maxX minY maxY])
title('Magnitude Peak Amplitude')
xlabel(stab.tLabel)
ylabel('amplitude [a.u.]')
stdDev = sprintf('std.dev=%.0f, std./m=%.1f%%, max.jump/m=%.1f%%, max.diff/m=%.1f%%',...
                 std(stab.maxMagnVal),100*std(stab.maxMagnVal)/mean(stab.maxMagnVal),...
                 100*max(diff(stab.maxMagnVal))/mean(stab.maxMagnVal),...
                 100*(max(stab.maxMagnVal)-min(stab.maxMagnVal))/mean(stab.maxMagnVal));
text(minX+(maxX-minX)/20,maxY-(maxY-minY)/10,stdDev)

%--- plot data to separate figure for export ---
if flag.stabExpFdFrequ
    fh_fdFrequ = figure;
    namestr = sprintf('Frequency Domain');
    set(fh_fdFrequ,'NumberTitle','off','Name',namestr,'Position',stab.fdFrequPos);
    fdFrequPh = plot(stab.tVecPlot,stab.maxMagnHz,stab.fdFrequSymb);
    set(fdFrequPh,'Color',stab.fdFrequColor)
    if flag.stabPlotDatConnect
        hold on
        plot(stab.tVecPlot,stab.maxMagnHz)
        hold off
    end
    [minX maxX minY maxY] = SP2_IdealAxisValues(stab.tVecPlot,stab.maxMagnHz);
    axis([minX maxX stab.fdFrequYmin stab.fdFrequYmax])
    title(titlestr)
    xlabel(stab.tLabel)
    ylabel('delta frequency [Hz]')
end

%--- explicit result printout ---
if flag.stabVerbose
    fprintf('frequency domain analysis:\n');
    if flag.stabSpline
        fprintf('frequency resolution: %.2f Hz (spline factor %i)\n',stab.hzPerPt/stab.splFac,stab.splFac);
    else
        fprintf('frequency resolution: %.2f Hz (no spline interpolation)\n',stab.hzPerPt);
    end
    fprintf('frequency variation:  %.2f Hz (std), %.2f Hz (max.jump), %.2f Hz (max.diff)\n',...
            std(stab.maxMagnHz),max(abs(diff(stab.maxMagnHz))),max(stab.maxMagnHz)-min(stab.maxMagnHz));
    fprintf('amplitude variation:  %.0f (std), %.2f%% (std./mean), %.2f%% (max.jump), %.2f%% (max.diff)\n',...
            std(stab.maxMagnVal),100*std(stab.maxMagnVal)/mean(stab.maxMagnVal),...
            100*max(diff(stab.maxMagnVal))/mean(stab.maxMagnVal),...
            100*(max(stab.maxMagnVal)-min(stab.maxMagnVal))/mean(stab.maxMagnVal));
end



%---------------------------------------------------------------------------------
function StabAnaLoc_FWHM_Analysis

global stab flag

fh2 = figure;
namestr = sprintf(' FWHM Analysis');
set(fh2,'NumberTitle','off','Name',namestr,'Position',[542 234 672 597]);
if flag.stabFwhmTimeVsNR           % day time [hours]
    plot(stab.tVecPlot,stab.fwhmHz,'r+')
    if flag.stabPlotDatConnect
        hold on
        plot(stab.tVecPlot,stab.fwhmHz)
        hold off
    end
    [minX maxX minY maxY] = SP2_IdealAxisValues(stab.tVecPlot,stab.fwhmHz);
    xlabel('day time [hours]')
else                            % acquisition number [NR]
    plot(stab.fwhmHz,'r+')
    if flag.stabPlotDatConnect
        hold on
        plot(stab.fwhmHz)
        hold off
    end
    [minX maxX minY maxY] = SP2_IdealAxisValues(stab.fwhmHz);
    xlabel('acquisition number [NR]')
end
axis([minX maxX minY maxY])
titlestr = sprintf('FWHM analysis\nflags: ECC/ZeroPhase/RealMagn=%i/%i/%i',...
                   flag.stabFwhmEcc,flag.stabFwhmZeroPh,flag.stabFwhmRealMagn);
title(titlestr)
ylabel('FWHM [Hz]')
stdDev = sprintf('std.dev.=%.1f, max.diff.=%.1f',std(stab.fwhmHz),max(abs(diff(stab.fwhmHz))));
text(minX+(maxX-minX)/20,maxY-(maxY-minY)/10,stdDev)



%---------------------------------------------------------------------------------
function StabAnaLoc_FourierAnalysis

global stab flag


phaseFftTmp  = abs(fft(stab.phase));
phaseFft     = phaseFftTmp(1,1:ceil(stab.ana.nr/2));
amplFftTmp   = abs(fft(stab.ampl));
amplFft      = amplFftTmp(1,1:ceil(stab.ana.nr/2));
frequFftTmp  = abs(fft(stab.maxMagnHz));
frequFft     = frequFftTmp(1,1:ceil(stab.ana.nr/2));
SW_h         = 1/stab.tr;
frequAxis    = 0:SW_h/(2*(ceil(stab.ana.nr/2)-1)):SW_h/2;
periodAxis   = 1./frequAxis(2:end);         % first value is zero
if stab.periodLim>0
    pLimInd = min(find(periodAxis<stab.periodLim));          % find period values smaller than stab.periodLim (1st index)
    if isempty(pLimInd)
        pLimInd = 1;         % avoid empty assignment
        fprintf('FourierAnalysis -> periodLim was too small and had to be increased for reasonable displaying ...\n');
    end
else
    pLimInd = 1;        % full range
end

fh_fft = figure;
namestr = sprintf(' Fourier Analysis');
set(fh_fft,'NumberTitle','off','Name',namestr,'Position',[92 152 1091 593]);
subplot(2,3,1)
if flag.stabAmplNorm           % amplitude normalization
    phaseFft2Plot = phaseFft(1,stab.frequLim:end);
    phaseFft2Plot = phaseFft2Plot / max(phaseFft2Plot);
else
    phaseFft2Plot = phaseFft(1,stab.frequLim:end);
end
plot(frequAxis(1,stab.frequLim:end),phaseFft2Plot)
[minX maxX minY maxY] = SP2_IdealAxisValues(frequAxis(1,stab.frequLim:end),phaseFft2Plot);
axis([minX maxX minY maxY])
title('Fourier analysis of phases')
xlabel('frequency [Hz]')
ylabel('amplitude [a.u.]')
subplot(2,3,2)
if flag.stabAmplNorm           % amplitude normalization
    amplFft2Plot = amplFft(1,stab.frequLim:end);
    amplFft2Plot = amplFft2Plot / max(amplFft2Plot);
else
    amplFft2Plot = amplFft(1,stab.frequLim:end);
end
plot(frequAxis(1,stab.frequLim:end),amplFft2Plot)
[minX maxX minY maxY] = SP2_IdealAxisValues(frequAxis(1,stab.frequLim:end),amplFft2Plot);
axis([minX maxX minY maxY])
title('Fourier analysis of amplitude')
xlabel('frequency [Hz]')
subplot(2,3,3)
if flag.stabAmplNorm           % amplitude normalization
    frequFft2Plot = frequFft(1,stab.frequLim:end);
    frequFft2Plot = frequFft2Plot / max(frequFft2Plot);
else
    frequFft2Plot = frequFft(1,stab.frequLim:end);
end
plot(frequAxis(1,stab.frequLim:end),frequFft2Plot)
[minX maxX minY maxY] = SP2_IdealAxisValues(frequAxis(1,stab.frequLim:end),frequFft2Plot);
axis([minX maxX minY maxY])
if flag.stabLb
    titleStr = sprintf('Fourier analysis of frequencies (lb %.1f Hz)',stab.lb);
else
    titleStr = 'Fourier analysis of frequencies (lb 0Hz)';
end
title(titleStr)
xlabel('frequency [Hz]')
subplot(2,3,4)
if flag.stabAmplNorm           % amplitude normalization
    phaseFftPeriod2Plot = phaseFft(1,pLimInd+1:end);
    phaseFftPeriod2Plot = phaseFftPeriod2Plot / max(phaseFftPeriod2Plot);
else
    phaseFftPeriod2Plot = phaseFft(1,pLimInd+1:end);
end
plot(periodAxis(1,pLimInd:end),phaseFftPeriod2Plot)       % +1 since the zero frequency was removed before the period calculation
[minX maxX minY maxY] = SP2_IdealAxisValues(periodAxis(1,pLimInd:end),phaseFftPeriod2Plot);
axis([minX maxX minY maxY])
xlabel('oscillation period [s]')
ylabel('amplitude [a.u.]')
subplot(2,3,5)
if flag.stabAmplNorm           % amplitude normalization
    amplFftPeriod2Plot = amplFft(1,pLimInd+1:end);
    amplFftPeriod2Plot = amplFftPeriod2Plot / max(amplFftPeriod2Plot);
else
    amplFftPeriod2Plot = amplFft(1,pLimInd+1:end);
end
plot(periodAxis(1,pLimInd:end),amplFftPeriod2Plot)
[minX maxX minY maxY] = SP2_IdealAxisValues(periodAxis(1,pLimInd:end),amplFftPeriod2Plot);
axis([minX maxX minY maxY])
xlabel('oscillation period [s]') 
subplot(2,3,6)
if flag.stabAmplNorm           % amplitude normalization
    frequFftPeriod2Plot = frequFft(1,pLimInd+1:end);
    frequFftPeriod2Plot = frequFftPeriod2Plot / max(frequFftPeriod2Plot);
else
    frequFftPeriod2Plot = frequFft(1,pLimInd+1:end);
end
plot(periodAxis(1,pLimInd:end),frequFftPeriod2Plot)
[minX maxX minY maxY] = SP2_IdealAxisValues(periodAxis(1,pLimInd:end),frequFftPeriod2Plot);
axis([minX maxX minY maxY])
xlabel('oscillation period [s]') 

%--- plot data to separate figure for export ---
if flag.stabExpFftFrequ
    fh_fftFrequ = figure;
    namestr = sprintf(' Frequency Domain');
    set(fh_fftFrequ,'NumberTitle','off','Name',namestr,'Position',stab.fftFrequPos);
    fftFrequPh = plot(frequAxis(1,stab.frequLim:end),frequFft2Plot);
    set(fftFrequPh,'Color',stab.fftFrequColor)
	[minX maxX minY maxY] = SP2_IdealAxisValues(frequAxis(1,stab.frequLim:end),frequFft2Plot);
    if flag.stabFftAmplMax>0
        axis([minX maxX minY flag.stabFftAmplMax])
    elseif flag.stabFftAmplMax==0
        axis([minX maxX minY maxY])
    else
        fprintf('%s -> flag value f_fftAmplMax=%.0f is not allowed (legal values: >=0)',FCTNAME,flag.stabFftAmplMax);
        return
    end
    if flag.stabLb
        titleStr = sprintf('Fourier analysis of frequencies (lb %.1f Hz)',stab.lb);
	else
        titleStr = 'Fourier analysis of frequencies (lb 0Hz)';
    end
    title(titleStr)
	xlabel('frequency [Hz]')
    ylabel('amplitude [a.u.]')
end

%---------------------------------------------------------------------------------
function StabAnaLoc_PlotCalcTracking

global stab

fh_db = figure;
namestr = sprintf(' Calculation Tracking of 3rd FID, datShift=%i, PhaseFac=%.3f',...
                  stab.datShift,stab.phaseFac);
set(fh_db,'NumberTitle','off','Name',namestr);
subplot(2,2,1)
plot(abs(stab.dbFid(1,1:200)))
[minX maxX minY maxY] = SP2_IdealAxisValues(abs(stab.dbFid(1,1:200)));
axis([minX maxX minY maxY])
xlabel('magn. of FID (orig)') 
subplot(2,2,2)
plot(abs(stab.dbFidConv(1,1:200)))
[minX maxX minY maxY] = SP2_IdealAxisValues(abs(stab.dbFidConv(1,1:200)));
axis([minX maxX minY maxY])
xlabel('magn. of FID (convdta)') 
subplot(2,2,3)
plot(real(stab.dbSpec))
[minX maxX minY maxY] = SP2_IdealAxisValues(real(stab.dbSpec));
axis([minX maxX minY maxY])
xlabel('real spectrum') 
subplot(2,2,4)
plot(abs(stab.dbSpec))
[minX maxX minY maxY] = SP2_IdealAxisValues(abs(stab.dbSpec));
axis([minX maxX minY maxY])
xlabel('magn. spectrum') 


%---------------------------------------------------------------------------------
% plot single each acquisition to separate figure
function StabAnaLoc_PlotSingleAcqs

global stab

% particular scan(s) of acqVec
for icnt = 1:stab.ana.nr
    fh_extr1 = figure;
    namestr = sprintf(' Acquisition #%i',stab.ana.specFirst+icnt-1);
    set(fh_extr1,'NumberTitle','off','Name',namestr);
    subplot(2,2,1)
	plot(real(stab.ana.fid(:,icnt)))
	[minX maxX minY maxY] = SP2_IdealAxisValues(real(stab.ana.fid(:,icnt)));
	axis([minX maxX minY maxY])
	xlabel('FID (real part)') 
    subplot(2,2,2)
	plot(abs(stab.ana.fid(:,icnt)))
	[minX maxX minY maxY] = SP2_IdealAxisValues(abs(stab.ana.fid(:,icnt)));
	axis([minX maxX minY maxY])
	xlabel('FID (magnitude)') 
	subplot(2,2,3)
	plot(real(stab.spec(:,icnt)))
	[minX maxX minY maxY] = SP2_IdealAxisValues(real(stab.spec(:,icnt)));
	axis([minX maxX minY maxY])
	xlabel('spectrum (real part)')
	subplot(2,2,4)
	plot(abs(stab.spec(:,icnt)))
	[minX maxX minY maxY] = SP2_IdealAxisValues(abs(stab.spec(:,icnt)));
	axis([minX maxX minY maxY])
	xlabel('spectrum (magnitude)') 
end

%---------------------------------------------------------------------------------------------------------
% superposition of selected range, if acqVec consists of more than on scan
if stab.ana.nr>1
	fh_extr2 = figure;
	namestr = sprintf(' Acquisitions #%i..#%i',stab.acqVec);
	set(fh_extr2,'NumberTitle','off','Name',namestr);
	subplot(2,2,1)
	plot(real(stab.ana.fid))
	[minX maxX minY maxY] = SP2_IdealAxisValues(real(stab.ana.fid(:,1)));
	axis([minX maxX minY maxY])
	xlabel('FID (real part)') 
	subplot(2,2,2)
	plot(abs(stab.ana.fid))
	[minX maxX minY maxY] = SP2_IdealAxisValues(abs(stab.ana.fid(:,1)));
	axis([minX maxX minY maxY])
	xlabel('FID (magnitude)') 
	subplot(2,2,3)
	plot(real(stab.spec))
	[minX maxX minY maxY] = SP2_IdealAxisValues(real(stab.spec(:,1)));
	axis([minX maxX minY maxY])
	xlabel('spectrum (real part)')
	subplot(2,2,4)
	plot(abs(stab.spec))
	[minX maxX minY maxY] = SP2_IdealAxisValues(abs(stab.spec(:,1)));
	axis([minX maxX minY maxY])
	xlabel('spectrum (magnitude)')
end


