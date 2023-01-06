%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaDoCalcCRLB_Individual( f_plot )
%%
%%  Calculate CRLBs of LCModel analysis.
%%  Literature:
%%  1) CavasillaS00a (JMR)
%%  2) CavasillaS01a (NMR Biomed, main resource)
%%
%%  11-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_AnaDoCalcCRLB_Individual';


%   Comments / To Do:
%   1) CRLB of non-Voigt shapes, e.g. polynomial baseline)
%   2) CRLB in frequency domain: here, 'time-domain for algebraic convenience'
%     
%   Notes:
%   * Evaluation of the CRB requires inversion of the Fisher information matrix F
%   * The size of F equals the number Np of free real-valued parameters to be estimated
%   * Therefore, incorporation of prior knowledge reduces the size of F
%   * Hermitian conjugate = transpose and complex conjugate
%   * D: derivative
%   * computaton of D requires the derivative of the functions xn with
%     respect to the parameters pl using their true values
%   * note that (as opposed to the paper) only one global phase is
%   * There is no sum in the derivative (as opposed to the model sampel) as the partial derivative is p_l-specific
%     considered, i.e. the individual signals are phase-locked
%   * P: prior knowledge
%   * CRBs are proportional to the square root of the sampling interval
%   

%--- init success flag ---
f_succ = 0;

%--- parameter assignment ---
% lcm.nFidCrlb             = 2048;              % number of points considered for CRLB calculation in D/P (random), zero-filled if needed
lcm.nFidCrlb             = lcm.anaNspecC;       % number of points considered for CRLB calculation in D/P (random), zero-filled if needed
flag.lcmSaveFisherFig    = 0;                   % save figure with amplitude correlation matrix to file

%--- PHC1 NOT SUPPORTED ---
if flag.lcmAnaPhc1
    fprintf('\n\nCRLB for first order phase PHC1 is not supported yet. Program aborted.\n\n');
    return
end

%--- check existence of LCM analysis ---
if ~isfield(lcm.fit,'resid')
    fprintf('No LCModel analysis found. Perform first.\n');
    return
end

%--- open log file ---
if flag.lcmSaveLog && ~f_plot
    lcm.log = fopen(lcm.logPath,'a');
end

%--- extraction of (pure) spectral noise ---
[noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
    SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,real(lcm.spec));
if ~f_done
    fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME);
    return
end
fprintf('Spectral noise range %.3f..%.3f ppm\nOriginal: min/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
        min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))
if flag.lcmSaveLog && ~f_plot
    fprintf(lcm.log,'Spectral noise range %.3f..%.3f ppm\nOriginal: min/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom));
end

%--- removal of 2nd order polynomial fit from spectral noise area ---
coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom.',2);    % fit
noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1)).';   % fitted noise vector
noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
fprintf('2nd order corrected: min/max/SD %.1f/%.1f/%.1f\n',min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom));
if flag.lcmSaveLog && ~f_plot
    fprintf(lcm.log,'2nd order corrected: min/max/SD %.1f/%.1f/%.1f\n',min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom));
end
    
    
%--- removal of 2nd order polynomial fit from FID noise area ---
% fidMinPos = 20000;
% noiseFidZoom = real(lcm.fidOrig(fidMinPos:end));
% coeff = polyfit(1:length(noiseFidZoom),noiseFidZoom',2);    % fit
% noiseFidZoomFit = polyval(coeff,1:length(noiseFidZoom))';   % fitted noise vector
% noiseFidZoom    = noiseFidZoom - noiseFidZoomFit;            % fit correction
% fprintf('FID noise range %.0f..%.0f pts, 2nd order corrected:\nmin/max/SD %.1f/%.1f/%.1f\n',fidMinPos,...
%         lcm.nspecC,min(noiseFidZoom),max(noiseFidZoom),std(noiseFidZoom))
    
%--- noise ---
% noise  = std(noiseSpecZoom)/sqrt(lcm.nspecC); before 06/2020
noise = std(noiseSpecZoom);    

%--- time vector for FID ---
tVec = (0:lcm.dwell:(lcm.nFidCrlb-1)*lcm.dwell).';

%--- number of fitted metabolites ---
nMetab = lcm.fit.appliedN;      % baseline not included

%--- number of metabolite-specific parameters in D ---
% note that so far (before P is applied) every parameter is metabolite-specific
parsPerMetabD = 1 + ...                                          % amplitudes (always included)
                flag.lcmAnaLb + ...                              % LB if included
                flag.lcmAnaGb + ...                              % GB if included
                flag.lcmAnaShift + ...                           % frequency shift if included
                flag.lcmAnaPhc0 + ...                            % PHC0 if included
                flag.lcmAnaPhc1;                                 % PHC1 if included
               
%--- final number of metabolite-specific parameters ---
% after P has been applied
parsPerMetab = 1 + ...                                          % amplitudes (always included)
               flag.lcmAnaLb * ~flag.lcmLinkLb + ...            % LB if uncoupled
               flag.lcmAnaGb * ~flag.lcmLinkGb + ...            % GB if uncoupled
               flag.lcmAnaShift * ~flag.lcmLinkShift;           % frequency shift if uncoupled

%--- number of global (linked) parameters ---
nglobal = flag.lcmAnaLb * flag.lcmLinkLb + ...                  % LB if coupled
          flag.lcmAnaGb * flag.lcmLinkGb + ...                  % GB if coupled
          flag.lcmAnaShift * flag.lcmLinkShift + ...            % frequency shift if coupled
          flag.lcmAnaPhc0 + ...                                 % PHC0 (always global)
          flag.lcmAnaPhc1;                                      % PHC1 (always global)

      
%--- reformat basis FIDs ---
basisFid   = complex(zeros(lcm.nFidCrlb,nMetab));
basisNames = {};
for metabCnt = 1:nMetab
    fidTmp = lcm.basis.data{lcm.fit.applied(metabCnt)}{4};                      % get data
    if lcm.nFidCrlb<=length(fidTmp)                                             % basis FID is long enough
        basisFid(:,metabCnt) = fidTmp(1:lcm.nFidCrlb);                          % cut down or leave as is
    else                                                                        % basis FID is too short
        basisFidZF = complex(zeros(lcm.nFidCrlb,1));                            % apply zero-filling
        basisFidZF(1:length(fidTmp),1) = fidTmp;
        basisFid(:,metabCnt)           = basisFidZF;            
    end
    basisNames{metabCnt} = lcm.basis.data{lcm.fit.applied(metabCnt)}{1};        % retrieve metabolite names
end
% lcm.anaMetabs = basisNames;    % keep...

%--- reformat LCM result vectors ---
lcmAmpVec   = lcm.anaScale(lcm.fit.applied);            % reduce to applied ones
lcmLbVec    = lcm.anaLb(lcm.fit.applied);
lcmGbVec    = lcm.anaGb(lcm.fit.applied);
lcmShiftVec = lcm.anaShift(lcm.fit.applied);

%--- calculation of derivative D ---
% Note the parameter units and the necessary conversions:
% LB, GB and Shift are all in Hertz, LB and GB are positive, Phc0 is in degrees
% alpha, beta and omega in x_k already include the signs
% t_n therefore becomes -pi*tVec
%
%--- parameter init ---
D    = zeros(lcm.nFidCrlb,(parsPerMetab+nglobal)*nMetab);       % init derivative matrix D in time domain
Dfft = D;                                                       % init derivative matrix Dfft in frequency domain
% note that before the prior knowledge matrix P is applied all parameters
% are independent, therefore (parsPerMetab+nglobal)*nMetab
dCnt    = 0;                                                    % init D index counter
legCell = {};                                                   % name cell for D
legCnt  = 0;                                                    % init legend counter

%--- init (analysis window-specific) frequency domain D ---
DfftZoom = zeros(lcm.anaAllIndN,(parsPerMetab+nglobal)*nMetab);

%--- individual metabolite-specific paramters ---
for metabCnt = 1:nMetab         % somewhat redundant as strings are identical for all metabolites
    %--- amplitude parameter c_k ---
    % note: always included
    % init c_k string
    cKStr = 'basisFid(:,metabCnt)';           % this is the way it should
%     be according to the paper, but that leads to CRLB scaling as a
%     function of the overall target amplitude
    % cKStr = 'basisFid(:,metabCnt) * lcmAmpVec(metabCnt)';        % this is the way that works, [%], note: this was changed/removed in 06/2020        
    % Lorentzian (individual)
    % changing the LB exponential scaling does affect the amplitude CRLB
    if flag.lcmAnaLb % && ~flag.lcmLinkLb
        cKStr = [cKStr ' .* exp(-lcmLbVec(metabCnt)*pi.*tVec)'];
    end
    % Gaussian (individual)
    if flag.lcmAnaGb % && ~flag.lcmLinkGb
        cKStr = [cKStr ' .* exp(-lcmGbVec(metabCnt)*pi^2.*tVec.^2)'];
        % cKStr = [cKStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(metabCnt)^2.*tVec.^2)'];
    end
    % frequency shift (individual)
    if flag.lcmAnaShift % && ~flag.lcmLinkShift
        cKStr = [cKStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*tVec)'];
    end
    % PHC0 (always global)
    if flag.lcmAnaPhc0
        cKStr = [cKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
    end
    % PHC1 (always global)
    if flag.lcmAnaPhc1
        cKStr = [cKStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*lcm.anaPhc1*pi/180)'];
    end
        
    %--- calculate partial derivative ---
    dCnt = dCnt + 1;
    eval(['D(:,dCnt) = ' cKStr ';']);
    Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
    DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
    %--- name handling ---
    legCnt = legCnt + 1;
    legCell{legCnt} = [basisNames{metabCnt} ' amp(i)'];
    
    
    %--- Lorentzian parameter alpha_k (individual) ---
    if flag.lcmAnaLb
        % init alpha_k string
        % note that removing the -pi before the exponential does not affect the amplitude CRLB
        % changing the exponential scaling does affect the amplitude CRLB
        % (for a 2-parameter fit of amplitude and LB only)
        alphaKStr = 'basisFid(:,metabCnt) .* (lcmAmpVec(metabCnt) * -pi.*tVec) .* exp(-lcmLbVec(metabCnt)*pi*tVec)';   
        % Gaussian (individual)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            alphaKStr = [alphaKStr ' .* exp(-lcmGbVec(metabCnt)*pi^2.*tVec.^2)'];
            % alphaKStr = [alphaKStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(metabCnt)^2.*tVec.^2)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            alphaKStr = [alphaKStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt).*tVec)'];
        end
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            alphaKStr = [alphaKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            alphaKStr = [alphaKStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*lcm.anaPhc1*pi/180)'];
        end
        
        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' alphaKStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
        %--- name handling ---
        if ~flag.lcmLinkLb
            legCnt = legCnt + 1;
            legCell{legCnt} = [basisNames{metabCnt} sprintf(' LB (i)')];
        end
    end
    
    %--- Gaussian parameter beta_k (individual) ---
    if flag.lcmAnaGb
        % init beta_k string
        betaKStr = 'basisFid(:,metabCnt) .* (lcmAmpVec(metabCnt) * -(pi^2).*tVec.^2) .* exp(-lcmGbVec(metabCnt)*pi^2*tVec.^2)';    
        % betaKStr = 'basisFid(:,metabCnt) .* (lcmAmpVec(metabCnt) * -2*pi^2 .* tVec.^2 / (4*log(2)) * lcmGbVec(metabCnt)) .* exp(-pi^2/(4*log(2)) * lcmGbVec(metabCnt)^2 * tVec.^2)';    
        % Lorentzian (individual)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            betaKStr = [betaKStr ' .* exp(-lcmLbVec(metabCnt)*pi.*tVec)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            betaKStr = [betaKStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*tVec)'];
        end
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            betaKStr = [betaKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            betaKStr = [betaKStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*lcm.anaPhc1*pi/180)'];
        end
        
        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' betaKStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
        %--- name handling ---
        if  ~flag.lcmLinkGb
            legCnt = legCnt + 1;
            legCell{legCnt} = [basisNames{metabCnt} sprintf(' GB (i))')];
        end
    end
    
    %--- frequency parameter omega_k (individual) ---
    if flag.lcmAnaShift
        % init omega_k string
        if flag.lcmAnaPhc1              % with PHC1, there are two omega dependencies
            omegaKStr = 'basisFid(:,metabCnt) .* lcmAmpVec(metabCnt) * 1i .* (2*pi.*tVec + 2*pi*lcm.anaPhc1*pi/180) .* exp(1i*2*pi*lcmShiftVec(metabCnt)*tVec)';    
        else                            % without PHC1, there is only one
            omegaKStr = 'basisFid(:,metabCnt) .* lcmAmpVec(metabCnt) * 1i .* 2*pi.*tVec .* exp(1i*2*pi*lcmShiftVec(metabCnt)*tVec)';
        end
        % Lorentzian (individual)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            omegaKStr = [omegaKStr ' .* exp(-lcmLbVec(metabCnt)*pi*tVec)'];
        end
        % Gaussian (individual)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            omegaKStr = [omegaKStr ' .* exp(-lcmGbVec(metabCnt)*pi^2*tVec.^2)'];
            % omegaKStr = [omegaKStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(metabCnt)^2.*tVec.^2)'];
        end
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            omegaKStr = [omegaKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            omegaKStr = [omegaKStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*lcm.anaPhc1*pi/180)'];
        end
        
        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' omegaKStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
        %--- name handling ---
        if ~flag.lcmLinkShift
            legCnt = legCnt + 1;
            legCell{legCnt} = [basisNames{metabCnt} sprintf(' shift (i)')];
        end
    end
    
    %--- global zero-order phase (PHC0) ---
    if flag.lcmAnaPhc0   
        %--- init global phase part ---
        % init phc0 string (always global)
        phc0KStr = 'basisFid(:,metabCnt) .* lcmAmpVec(metabCnt) * (1i*pi/180) .* exp(1i*lcm.anaPhc0*pi/180)';
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            phc0KStr = [phc0KStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*lcm.anaPhc1*pi/180)'];
        end
        % Lorentzian (global)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            phc0KStr = [phc0KStr ' .* exp(-lcmLbVec(metabCnt)*pi*tVec)'];
        end
        % Gaussian (global)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            phc0KStr = [phc0KStr ' .* exp(-lcmGbVec(metabCnt)*pi^2*tVec.^2)'];
            % phc0KStr = [phc0KStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(metabCnt)^2.*tVec.^2)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            phc0KStr = [phc0KStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*tVec)'];
        end

        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' phc0KStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    end
    
    %--- global first-order phase (PHC1) ---
    if flag.lcmAnaPhc1   
        %--- init global phase part ---
        % init phc1 string (always global)
        phc1KStr = '1i * basisFid(:,metabCnt) * 2*pi*lcmShiftVec(metabCnt) * exp(1i*2*pi*lcmShiftVec(metabCnt)*lcm.anaPhc1*pi/180)';
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            phc1KStr = [phc1KStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % Lorentzian (global)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            phc1KStr = [phc1KStr ' .* exp(-lcmLbVec(metabCnt)*pi*tVec)'];
        end
        % Gaussian (global)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            phc1KStr = [phc1KStr ' .* exp(-lcmGbVec(metabCnt)*pi^2*tVec.^2)'];
            % phc1KStr = [phc1KStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(metabCnt)^2.*tVec.^2)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            phc1KStr = [phc1KStr ' .* exp(1i*2*pi*lcmShiftVec(metabCnt)*tVec)'];
        end

        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' phc1KStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    end
end

%--- legend name handling for global parameters ---
%--- Lorentzian line broadening ---
if flag.lcmAnaLb && flag.lcmLinkLb
    legCnt = legCnt + 1;
    legCell{legCnt} = ' LB (g)';
end
%--- Gaussian line broadening ---
if flag.lcmAnaGb && flag.lcmLinkGb
    legCnt = legCnt + 1;
    legCell{legCnt} = ' GB (g)';
end
%--- frequency shift ---
if flag.lcmAnaShift && flag.lcmLinkShift
    legCnt = legCnt + 1;
    legCell{legCnt} = ' Shift (g)';
end
%--- PHC0 ---
if flag.lcmAnaPhc0
    legCnt = legCnt + 1;
    legCell{legCnt} = ' PHC0 (g)';
end
%--- PHC1 ---
if flag.lcmAnaPhc1
    legCnt = legCnt + 1;
    legCell{legCnt} = ' PHC1 (g)';
end    


% %--- total number of CRLB parameters ---
% nCRLB = parsPerMetab*nMetab + nglobal;
% 
% %--- creation of prior knowledge matrix ---
% % 1st working version: 3 parameters per metabolite plus 1 global phase
% P = zeros(dCnt,nCRLB-nMetab);
% indVec = parsPerMetab:parsPerMetab:dCnt;
% rowCnt = 1;     % init row position counter
% for colCnt = 1:dCnt
%     if mod(colCnt,parsPerMetab)~=0
%         P(colCnt,rowCnt) = 1;
%     else
%         rowCnt = rowCnt - 1;
%     end
%     rowCnt = rowCnt + 1;
% end
% P(indVec,end) = 1;

% generation of P for arbitrary combination of independent and global parameters
P = zeros(dCnt,parsPerMetab*nMetab+nglobal);      % 1: all pars, 2: effective size
% indVec = parsPerMetab:parsPerMetab:dCnt;
indVec1st = 1:parsPerMetabD:dCnt;        % (1st) index vector for global parameter dimension
rowInd    = 1;                          % init row index
colInd    = 1;                          % init column index
%--- metabolite-specific parameters ---
for colCnt = 1:nMetab
    %--- amplitude (always included and independent) ---
    P(colInd,rowInd) = 1;
    rowInd = rowInd + 1;
    colInd = colInd + 1;
    
    %--- Lorentzian line broadening ---
    if flag.lcmAnaLb
        if ~flag.lcmLinkLb
            P(colInd,rowInd) = 1;
            rowInd = rowInd + 1;
        end
        
        % assign LB index
        if colCnt==1
            lbInd = colInd;
        end
        
        % index handling
        colInd = colInd + 1;
    end
    
    %--- Gaussian line broadening ---
    if flag.lcmAnaGb
        if ~flag.lcmLinkGb
            P(colInd,rowInd) = 1;
            rowInd = rowInd + 1;
        end

        % assign GB index
        if colCnt==1
            gbInd = colInd;
        end
        
        % index handling 
        colInd = colInd + 1;
    end
    
    %--- frequency shift ---
    if flag.lcmAnaShift
        if ~flag.lcmLinkShift
            P(colInd,rowInd) = 1;
            rowInd = rowInd + 1;
        end
    
        % assign shift index
        if colCnt==1
            shiftInd = colInd;
        end
        
        % index handling
        colInd = colInd + 1;
    end
    
    %--- PHC0 ---
    if flag.lcmAnaPhc0
        % assign PHC0 index
        if colCnt==1
            phc0Ind = colInd;
        end
        
        % index handling
        colInd = colInd + 1;
    end
    
    %--- PHC1 ---
    if flag.lcmAnaPhc1
        % assign PHC0 index
        if colCnt==1
            phc1Ind = colInd;
        end
        
        % index handling
        colInd = colInd + 1;
    end
end

%--- global parameter dimensions ---
% note reversed order
globCnt   = 0;                          % counter of global parameters
%--- PHC1 ---
if flag.lcmAnaPhc1
    globCnt = globCnt + 1;
    P(indVec1st+phc1Ind-1,end-(globCnt-1)) = 1;
end    

%--- PHC0 ---
if flag.lcmAnaPhc0
    globCnt = globCnt + 1;
    P(indVec1st+phc0Ind-1,end-(globCnt-1)) = 1;
end

%--- frequency shift ---
if flag.lcmAnaShift && flag.lcmLinkShift
    globCnt = globCnt + 1;
    P(indVec1st+shiftInd-1,end-(globCnt-1)) = 1;
end

%--- GB ---
if flag.lcmAnaGb && flag.lcmLinkGb
    globCnt = globCnt + 1;
    P(indVec1st+gbInd-1,end-(globCnt-1)) = 1;
end

%--- LB ---
if flag.lcmAnaLb && flag.lcmLinkLb
    globCnt = globCnt + 1;
    P(indVec1st+lbInd-1,end-(globCnt-1)) = 1;
end


%--- display prior knowledge P ---
if flag.verbose
%     if flag.debug
        if 1
        fprintf('\nPrior knowledge P:\n');
        for rowCnt = 1:dCnt
            fprintf('| %s |\n',SP2_Vec2PrintStr(P(rowCnt,:),0,0));
        end
    end
    fprintf('size(D) = [%.0f %.0f], size(P) = [%.0f %.0f]\n',size(D,1),size(D,2),size(P,1),size(P,2));
    fprintf('Full D:  %.0f metabs * %.0f metab-specific pars = %.0f\n',nMetab,parsPerMetabD,dCnt);
    fprintf('After P: %.0f metabs * %.0f metab-specific pars + %.0f global pars = %.0f fit pars (CRLB)\n',...
            nMetab,parsPerMetabD-globCnt,globCnt,parsPerMetab*nMetab+nglobal)

    %--- log file ---
    if flag.lcmSaveLog && ~f_plot
        if flag.debug
            fprintf(lcm.log,'\nPrior knowledge P:\n');
            for rowCnt = 1:dCnt
                fprintf(lcm.log,'| %s |\n',SP2_Vec2PrintStr(P(rowCnt,:),0,0));
            end
        end
        fprintf(lcm.log,'size(D) = [%.0f %.0f], size(P) = [%.0f %.0f]\n',size(D,1),size(D,2),size(P,1),size(P,2));
        fprintf(lcm.log,'Full D:  %.0f metabs * %.0f metab-specific pars = %.0f\n',nMetab,parsPerMetabD,dCnt);
        fprintf(lcm.log,'After P: %.0f metabs * %.0f metab-specific pars + %.0f global pars = %.0f fit pars (CRLB)\n',...
                nMetab,parsPerMetabD-globCnt,globCnt,parsPerMetab*nMetab+nglobal);
    end
end

%--- Fisher information matrix ---
% note that here prior knowledge is explicitly included
% non-conjugate transpose: .'
% conjugate transpose: ' (i.e. hermitian transpose)
% F = 1/(noise^2) * real(P.' * D' * D * P);   before 06/2020, D in time
% domain, effectively full bandwidth
% new: frequency domain, limited to analyzed frequency window
F = 1/(noise^2) * real(P.' * DfftZoom' * DfftZoom * P);


%--- figure creation: Fisher information matrix ---
if f_plot && flag.verbose
    lcm.fhFisher = figure;
    set(lcm.fhFisher,'NumberTitle','off','Name',sprintf(' Fisher Information Matrix'),...
               'Position',[100 100 692 550],'Color',[1 1 1],'Tag','LCM')
    imagesc(flipud(F),[-5 5])
%     imagesc(flipud(F))
    
    if flag.lcmColorMap<2           % uni OR jet
        colormap(jet)
    elseif flag.lcmColorMap==2      % hsv
        colormap(hsv)
    else                            % hot
        colormap(hot)
    end
    colorbar
    daspect([1 1 1])

    %--- save complete correlation matrix to file ---
    if flag.lcmSaveFisherFig
        fisherFigPath = [lcm.expt.dataDir 'SPX_LcmFisher.fig'];
        saveas(lcm.fhFisher,fisherFigPath,'fig');
        fprintf('Fisher information matrix saved to file:\n%s\n',fisherFigPath);
    end
end

%--- dimension update ---
% parsPerMetab = parsPerMetab-nglobal;                % since PHC0 is now global 
nCRLB = parsPerMetab*nMetab+nglobal;            % = size(P,2) = size(F,1) = size(F,2)

%--- Cramer-Rao Lower Bounds ---
invF = inv(F);
lcm.fit.crlb = zeros(1,nCRLB);                  % complete CRLB vector included metabolite-specific and global parameters
for crlbCnt = 1:nCRLB
    lcm.fit.crlb(crlbCnt) = sqrt(invF(crlbCnt,crlbCnt));
%     lcm.fit.crlb(crlbCnt) = sqrt(invF(crlbCnt,crlbCnt))/lcm.anaScale(lcm.fit.appliedFit(crlbCnt));
end

%--- real vs. complex FID (and fit) ---
% note that every FID that does not derive from quadrature detection
% contains correlated noise in both real and imaginary parts which leads
% to an underestimation of the CRLB by a factor of 0.71 = 1/sqrt(2). As
% such every such FID should be considered (and fitted) as real spectrum
% and the CRLB should be rescaled, i.e. upscaled, accordingly.
if flag.lcmRealComplex
    lcm.fit.crlb = sqrt(2) * lcm.fit.crlb;
    fprintf('\nCRLBs scaled by sqrt(2) to account for real-valued FID.\n');
    
    %--- log file ---
    if flag.lcmSaveLog && ~f_plot
        fprintf(lcm.log,'\nCRLBs scaled by sqrt(2) to account for real-valued FID.\n');
    end
end

%--- save data to file ---
% save('F_withP','F')
% save('invF_withP','invF')

%--------------------------------------------------------------------------
%--- extract metabolite-specific CRLBs                                  ---
% amplitude
indCnt          = 1;                                            % init individual parameter counter
% lcm.fit.crlbAmp = min(100*lcm.fit.crlb(indCnt:parsPerMetab:nCRLB-nglobal),666);
lcm.fit.crlbAmp = lcm.fit.crlb(indCnt:parsPerMetab:nCRLB-nglobal);

% Lorentzian broadening
if flag.lcmAnaLb && ~flag.lcmLinkLb
    indCnt         = indCnt + 1;
    lcm.fit.crlbLb = lcm.fit.crlb(indCnt:parsPerMetab:nCRLB-nglobal);
end

% Gaussian broadening
if flag.lcmAnaGb && ~flag.lcmLinkGb
    indCnt         = indCnt + 1;
    lcm.fit.crlbGb = lcm.fit.crlb(indCnt:parsPerMetab:nCRLB-nglobal);
end

% frequency shift
if flag.lcmAnaShift && ~flag.lcmLinkShift
    indCnt            = indCnt + 1;
    lcm.fit.crlbShift = lcm.fit.crlb(indCnt:parsPerMetab:nCRLB-nglobal);
end


%--------------------------------------------------------------------------
%--- extract global CRLBs                                               ---
globCnt = 0;                          % counter of global parameters
%--- PHC1 ---
if flag.lcmAnaPhc1
    globCnt = globCnt + 1;
    lcm.fit.crlbPhc1 = lcm.fit.crlb(nCRLB-globCnt+1);
end

%--- PHC0 ---
if flag.lcmAnaPhc0
    globCnt = globCnt + 1;
    lcm.fit.crlbPhc0 = lcm.fit.crlb(nCRLB-globCnt+1);
end    

%--- frequency shift ---
if flag.lcmAnaShift && flag.lcmLinkShift
    globCnt = globCnt + 1;
    lcm.fit.crlbShift = lcm.fit.crlb(nCRLB-globCnt+1);
end    

%--- GB ---
if flag.lcmAnaGb && flag.lcmLinkGb
    globCnt = globCnt + 1;
    lcm.fit.crlbGb = lcm.fit.crlb(nCRLB-globCnt+1);
end    

%--- LB ---
if flag.lcmAnaLb && flag.lcmLinkLb
    globCnt = globCnt + 1;
    lcm.fit.crlbLb = lcm.fit.crlb(nCRLB-globCnt+1);
end

%--- CRLB printout ---
if f_plot || flag.verbose
    mStrMax = 0;
    for mCnt = 1:lcm.fit.appliedN
        if length(lcm.anaMetabs{mCnt})>mStrMax
            mStrMax = length(lcm.anaMetabs{mCnt});
        end
    end
    fprintf('\nSummary of amplitude CRLBs:\n');
    for mCnt = 1:nMetab
        fprintf('%s:%s%.5f a.u. / %.3f%%\n',basisNames{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                lcm.fit.crlbAmp(mCnt),100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)))   
    end
    fprintf('\n');
end
% lcm.anaCrlb = crlbAmp;


%--- info printout: individual pars ---
% in original order
fprintf('CRLB(amplitude) = %s a.u.\n',SP2_Vec2PrintStr(lcm.fit.crlbAmp,3));
if flag.lcmAnaLb && ~flag.lcmLinkLb
    fprintf('CRLB(LB)        = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.crlbLb,3));
end
if flag.lcmAnaGb && ~flag.lcmLinkGb
    fprintf('CRLB(GB)        = %s Hz^2\n',SP2_Vec2PrintStr(lcm.fit.crlbGb,3));
end
if flag.lcmAnaShift && ~flag.lcmLinkShift
    fprintf('CRLB(Shift)     = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.crlbShift,3));
end


%--- info printout: global pars ---
% in original order
if flag.lcmAnaLb && flag.lcmLinkLb
    fprintf('CRLB(LB)        = %.3f Hz\n',lcm.fit.crlbLb);
end
if flag.lcmAnaGb && flag.lcmLinkGb
    fprintf('CRLB(GB)        = %.3f Hz^2\n',lcm.fit.crlbGb);
end
if flag.lcmAnaShift && flag.lcmLinkShift
    fprintf('CRLB(Shift)     = %.3f Hz\n',lcm.fit.crlbShift);
end
if flag.lcmAnaPhc0
    fprintf('CRLB(PHC0)      = %.3f deg\n',lcm.fit.crlbPhc0);
end
if flag.lcmAnaPhc1
    fprintf('CRLB(PHC1)      = %.3f deg\n',lcm.fit.crlbPhc1);
end



%--- info printout: individual/global parameters (log file) ---
if flag.lcmSaveLog && ~f_plot
    %--- info printout: individual pars ---
    % in original order
    fprintf(lcm.log,'CRLB(amplitude) = %s a.u.\n',SP2_Vec2PrintStr(lcm.fit.crlbAmp,3));
    if flag.lcmAnaLb && ~flag.lcmLinkLb
        fprintf(lcm.log,'CRLB(LB)        = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.crlbLb,3));
    end
    if flag.lcmAnaGb && ~flag.lcmLinkGb
        fprintf(lcm.log,'CRLB(GB)        = %s Hz^2\n',SP2_Vec2PrintStr(lcm.fit.crlbGb,3));
    end
    if flag.lcmAnaShift && ~flag.lcmLinkShift
        fprintf(lcm.log,'CRLB(Shift)     = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.crlbShift,3));
    end


    %--- info printout: global pars ---
    % in original order
    if flag.lcmAnaLb && flag.lcmLinkLb
        fprintf(lcm.log,'CRLB(LB)        = %.3f Hz\n',lcm.fit.crlbLb);
    end
    if flag.lcmAnaGb && flag.lcmLinkGb
        fprintf(lcm.log,'CRLB(GB)        = %.3f Hz^2\n',lcm.fit.crlbGb);
    end
    if flag.lcmAnaShift && flag.lcmLinkShift
        fprintf(lcm.log,'CRLB(Shift)     = %.3f Hz\n',lcm.fit.crlbShift);
    end
    if flag.lcmAnaPhc0
        fprintf(lcm.log,'CRLB(PHC0)      = %.3f deg\n',lcm.fit.crlbPhc0);
    end
    if flag.lcmAnaPhc1
        fprintf(lcm.log,'CRLB(PHC1)      = %.3f deg\n',lcm.fit.crlbPhc1);
    end
end 
    
%--- close log file ---
% if flag.lcmSaveLog && ~f_plot
%     fclose(lcm.log);
% end

%-------------------------------------------------
%--- correlation matrix                        ---
% CavasillaS00a, equ. 13
% The diagonal elements of F21 are the variance bounds on the parameters (squares of the CRBs)
corrMatCompl = zeros(nCRLB,nCRLB);          % init complete correlation matrix
for rowCnt = 1:nCRLB
    for colCnt = 1:nCRLB
        corrMatCompl(colCnt,rowCnt) = (invF(colCnt,rowCnt)/sqrt(invF(colCnt,colCnt)*invF(rowCnt,rowCnt)));
    end
end

%--------------------------------------------------------------------------------------------------
%--- extract correlation data of the same type (e.g. amplitudes) and reformat for visualization ---
% rearrange to have first metabolite in lower left corner (similar to Minnesota)
% amplitude
indCnt     = 1;             % init individual parameter counter
corrMatAmp = flipud(corrMatCompl(indCnt:parsPerMetab:nCRLB-nglobal,1:parsPerMetab:nCRLB-nglobal));

% Lorentzian broadening
if flag.lcmAnaLb && ~flag.lcmLinkLb
    indCnt    = indCnt + 1;
    corrMatLb = flipud(corrMatCompl(indCnt:parsPerMetab:nCRLB-nglobal,1:parsPerMetab:nCRLB-nglobal));
end

% Gaussian broadening
if flag.lcmAnaGb && ~flag.lcmLinkGb
    indCnt    = indCnt + 1;
    corrMatGb = flipud(corrMatCompl(indCnt:parsPerMetab:nCRLB-nglobal,1:parsPerMetab:nCRLB-nglobal));
end

% frequency shift
if flag.lcmAnaShift && ~flag.lcmLinkShift
    indCnt       = indCnt + 1;
    corrMatShift = flipud(corrMatCompl(indCnt:parsPerMetab:nCRLB-nglobal,1:parsPerMetab:nCRLB-nglobal));
end

%--- keep for potential saving to xls file ---
lcm.fit.corr = corrMatAmp;

%--- figure creation: amplitude correlation matrix ---
if f_plot
    lcm.fhCorrAmp = figure;
    set(lcm.fhCorrAmp,'NumberTitle','off','Name',sprintf(' LCModel Correlation Matrix: Amplitude'),...
               'Position',[500 320 692 550],'Color',[1 1 1],'Tag','LCM')
    imagesc(corrMatAmp,[-1 1])
    set(gca,'XTick',1:nMetab,'XTickLabel',SP2_PrVersionUscoreCell(basisNames),'YTick',1:nMetab,'YTickLabel',fliplr(basisNames));
    SP2_XTickLabelRotate
    if flag.lcmColorMap<2           % uni OR jet
        colormap(jet)
    elseif flag.lcmColorMap==2      % hsv
        colormap(hsv)
    else                            % hot
        colormap(hot)
    end
    colorbar
    daspect([1 1 1])
end
    
if f_plot && flag.verbose
    %--- LORENTZIAN LINE BROADENING ---
    if exist('corrMatLb','var')
        lcm.fhCorrLb = figure;
        set(lcm.fhCorrLb,'NumberTitle','off','Name',sprintf(' LCModel Correlation Matrix: Lorentzian Linebroadening'),...
                   'Position',[510 330 692 550],'Color',[1 1 1],'Tag','LCM')
        imagesc(corrMatLb,[-1 1])
        set(gca,'XTick',1:nMetab,'XTickLabel',SP2_PrVersionUscoreCell(basisNames),'YTick',1:nMetab,'YTickLabel',fliplr(basisNames));
        SP2_XTickLabelRotate
        if flag.lcmColorMap<2           % uni OR jet
            colormap(jet)
        elseif flag.lcmColorMap==2      % hsv
            colormap(hsv)
        else                            % hot
            colormap(hot)
        end
        colorbar
        daspect([1 1 1])
    end
    
    %--- GAUSSIAN LINE BROADENING ---
    if exist('corrMatGb','var')
        lcm.fhCorrGb = figure;
        set(lcm.fhCorrGb,'NumberTitle','off','Name',sprintf(' LCModel Correlation Matrix: Gaussian Linebroadening'),...
                   'Position',[520 340 692 550],'Color',[1 1 1],'Tag','LCM')
        imagesc(corrMatGb,[-1 1])
        set(gca,'XTick',1:nMetab,'XTickLabel',SP2_PrVersionUscoreCell(basisNames),'YTick',1:nMetab,'YTickLabel',fliplr(basisNames));
        SP2_XTickLabelRotate
        if flag.lcmColorMap<2           % uni OR jet
            colormap(jet)
        elseif flag.lcmColorMap==2      % hsv
            colormap(hsv)
        else                            % hot
            colormap(hot)
        end
        colorbar
        daspect([1 1 1])
    end
    
    %--- FREQUENCY ---
    if exist('corrMatShift','var')
        lcm.fhCorrShift = figure;
        set(lcm.fhCorrShift,'NumberTitle','off','Name',sprintf(' LCModel Correlation Matrix: Frequency Shift'),...
                   'Position',[530 350 692 550],'Color',[1 1 1],'Tag','LCM')
        imagesc(corrMatShift,[-1 1])
        set(gca,'XTick',1:nMetab,'XTickLabel',SP2_PrVersionUscoreCell(basisNames),'YTick',1:nMetab,'YTickLabel',fliplr(basisNames));
        SP2_XTickLabelRotate
        if flag.lcmColorMap<2           % uni OR jet
            colormap(jet)
        elseif flag.lcmColorMap==2      % hsv
            colormap(hsv)
        else                            % hot
            colormap(hot)
        end
        colorbar
        daspect([1 1 1])
    end
end

%--- figure creation: amplitude correlation matrix ---
if f_plot && flag.verbose
    lcm.fhCorrCompl = figure;
    set(lcm.fhCorrCompl,'NumberTitle','off','Name',sprintf(' LCModel Correlation Matrix: Complete'),...
               'Position',[100 100 692 550],'Color',[1 1 1],'Tag','LCM')
    imagesc(flipud(corrMatCompl),[-1 1])
    
    %--- display matrix ---
    set(gca,'XTick',1:nCRLB,'XTickLabel',SP2_PrVersionUscoreCell(legCell),'YTick',1:nCRLB,'YTickLabel',fliplr(legCell));
    SP2_XTickLabelRotate
    if flag.lcmColorMap<2           % uni OR jet
        colormap(jet)
    elseif flag.lcmColorMap==2      % hsv
        colormap(hsv)
    else                            % hot
        colormap(hot)
    end
    colorbar
    daspect([1 1 1])
end

%--- update success flag ---
f_succ = 1;





end
