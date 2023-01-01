%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaDoCalcCRLB_Combined( f_plot )
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

FCTNAME = 'SP2_LCM_AnaDoCalcCRLB_Combined';

flag.debug = 0;

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
flag.lcmSaveFisherFig    = 0;               % save figure with amplitude correlation matrix to file

%--- PHC1 NOT SUPPORTED ---
if flag.lcmAnaPhc1
    fprintf('\n\nCRLB for first order phase PHC1 is not supported yet. Program aborted.\n\n')
    return
end

%--- check existence of LCM analysis ---
if ~isfield(lcm.fit,'resid')
    fprintf('No LCModel analysis found. Perform first.\n')
    return
end

%--- consistency check ---
if ~flag.lcmComb1 && ~flag.lcmComb2 && ~flag.lcmComb3
   fprintf('%s ->\nAt least one combination needs to be selected for this type of analysis.\nProgram aborted.\n',FCTNAME)
   return
end
% multifold assignment
if flag.lcmComb1 && flag.lcmComb2
   if any(intersect(lcm.comb1Ind,lcm.comb2Ind))
       fprintf('%s ->\nMultifold assignment of summation metabolites detected between combinations 1 & 2.\nAnalysis aborted.\n',FCTNAME)
       return
   end
end
if flag.lcmComb1 && flag.lcmComb3
   if any(intersect(lcm.comb1Ind,lcm.comb3Ind))
       fprintf('%s ->\nMultifold assignment of summation metabolites detected between combinations 1 & 3.\nAnalysis aborted.\n',FCTNAME)
       return
   end
end
if flag.lcmComb2 && flag.lcmComb3
   if any(intersect(lcm.comb2Ind,lcm.comb3Ind))
       fprintf('%s ->\nMultifold assignment of summation metabolites detected between combinations 2 & 3.\nAnalysis aborted.\n',FCTNAME)
       return
   end
end
% selection of channels that are not supported or not active 
if flag.lcmComb1
   if any(~ismember(lcm.comb1Ind,lcm.fit.applied))
       fprintf('%s ->\nAt least one basis of combination 1 is not supported or activated.\nProgram aborted.\n',FCTNAME)
       fprintf('Note that the combination indexing refers to the general basis numbers (in parenthesis),\nnot the set of basis functions selected to be employed\n')
       return
   end
end
if flag.lcmComb2
   if any(~ismember(lcm.comb2Ind,lcm.fit.applied))
       fprintf('%s ->\nAt least one basis of combination 2 is not supported or activated.\nProgram aborted.\n',FCTNAME)
       fprintf('Note that the combination indexing refers to the general basis numbers (in parenthesis),\nnot the set of basis functions selected to be employed\n')
       return
   end
end
if flag.lcmComb3
   if any(~ismember(lcm.comb3Ind,lcm.fit.applied))
       fprintf('%s ->\nAt least one basis of combination 3 is not supported or activated.\nProgram aborted.\n',FCTNAME)
       fprintf('Note that the combination indexing refers to the general basis numbers (in parenthesis),\nnot the set of basis functions selected to be employed\n')
       return
   end
end


%--- open log file ---
% if flag.lcmSaveLog && ~f_plot
%     lcm.log = fopen(lcm.logPath,'a');
% end

%--- extraction of (pure) spectral noise ---
[noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
    SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,real(lcm.spec));
if ~f_done
    fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME)
    return
end

% part of SP2_LCM_AnaDoCalcCRLB.m, therefore display disabled here
% fprintf('Noise range %.3f..%.3f ppm, original:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
%         min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))
if flag.lcmSaveLog && ~f_plot
    fprintf(lcm.log,'Noise range %.3f..%.3f ppm, original:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom));
end

%--- removal of 2nd order polynomial fit from spectral noise area ---
coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom.',2);    % fit
noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1)).';   % fitted noise vector
noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
fprintf('2nd order corrected: min/max/SD %.1f/%.1f/%.1f\n',min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))
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

% number of effective metabolties after combinations have been considered
nMetabEff = lcm.fit.appliedN - flag.lcmComb1*(lcm.comb1N-1) ...
            - flag.lcmComb2*(lcm.comb2N-1) - flag.lcmComb3*(lcm.comb3N-1);

%--- number of metabolite-specific parameters in D ---
% note that so far (before P is applied) every parameter is metabolite-specific
parsPerMetabD = 1 + ...                                          % amplitudes (always included)
                flag.lcmAnaLb + ...                              % LB
                flag.lcmAnaGb + ...                              % GB
                flag.lcmAnaShift + ...                           % frequency shift
                flag.lcmAnaPhc0 + ...                            % PHC0
                flag.lcmAnaPhc1;                                 % PHC1
               
%--- final number of metabolite-specific parameters ---
% after P has been applied
parsPerMetab = 1 + ...                                          % amplitudes (always included)
               flag.lcmAnaLb * ~flag.lcmLinkLb + ...            % LB if uncoupled
               flag.lcmAnaGb * ~flag.lcmLinkGb + ...            % GB if uncoupled
               flag.lcmAnaShift * ~flag.lcmLinkShift;           % frequency shift if uncoupled

%--- number of global (linked) parameters ---
nGlobal = flag.lcmAnaLb * flag.lcmLinkLb + ...                  % LB if coupled
          flag.lcmAnaGb * flag.lcmLinkGb + ...                  % GB if coupled
          flag.lcmAnaShift * flag.lcmLinkShift + ...            % frequency shift if coupled
          flag.lcmAnaPhc0 + ...                                 % PHC0 (always global)
          flag.lcmAnaPhc1;                                      % PHC1 (always global)

      
%--- reformat basis FIDs ---
basisFid   = complex(zeros(lcm.nFidCrlb,nMetab));
basisNames = {};
for mCnt = 1:nMetab
    fidTmp = lcm.basis.data{lcm.fit.applied(mCnt)}{4};                      % get data
    if lcm.nFidCrlb<=length(fidTmp)                                             % basis FID is long enough
        basisFid(:,mCnt) = fidTmp(1:lcm.nFidCrlb);                          % cut down or leave as is
    else                                                                        % basis FID is too short
        basisFidZF = complex(zeros(lcm.nFidCrlb,1));                            % apply zero-filling
        basisFidZF(1:length(fidTmp),1) = fidTmp;
        basisFid(:,mCnt)           = basisFidZF;            
    end
    basisNames{mCnt} = lcm.basis.data{lcm.fit.applied(mCnt)}{1};        % retrieve metabolite names
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
D    = zeros(lcm.nFidCrlb,(parsPerMetab+nGlobal)*nMetab);       % init derivative matrix D in time domain
Dfft = D;                                                       % init derivative matrix Dfft in frequency domain
% note that before the prior knowledge matrix P is applied all parameters
% are independent, therefore (parsPerMetab+nGlobal)*nMetab
dCnt    = 0;                                                    % init D index counter
legCell = {};                                                   % name cell for D
legCnt  = 0;                                                    % init legend counter

%--- init (analysis window-specific) frequency domain D ---
DfftZoom = zeros(lcm.anaAllIndN,(parsPerMetab+nGlobal)*nMetab);

%--- individual metabolite-specific paramters ---
for mCnt = 1:nMetab         % somewhat redundant as strings are identical for all metabolites
    %--- amplitude parameter c_k ---
    % note: always included
    % init c_k string
    cKStr = 'basisFid(:,mCnt)';           % this is the way it should
%     be according to the paper, but that leads to CRLB scaling as a
%     function of the overall target amplitude
    % cKStr = 'basisFid(:,mCnt) * lcmAmpVec(mCnt)';        % this is the way that works, [%], removed in 06/2020        
    % Lorentzian (individual)
    % changing the LB exponential scaling does affect the amplitude CRLB
    if flag.lcmAnaLb % && ~flag.lcmLinkLb
        cKStr = [cKStr ' .* exp(-lcmLbVec(mCnt)*pi.*tVec)'];
    end
    % Gaussian (individual)
    if flag.lcmAnaGb % && ~flag.lcmLinkGb
        cKStr = [cKStr ' .* exp(-lcmGbVec(mCnt)*pi^2.*tVec.^2)'];
        % cKStr = [cKStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(mCnt)^2.*tVec.^2)'];
    end
    % frequency shift (individual)
    if flag.lcmAnaShift % && ~flag.lcmLinkShift
        cKStr = [cKStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*tVec)'];
    end
    % PHC0 (always global)
    if flag.lcmAnaPhc0
        cKStr = [cKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
    end
    % PHC1 (always global)
    if flag.lcmAnaPhc1
        cKStr = [cKStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*lcm.anaPhc1*pi/180)'];
    end
        
    %--- calculate partial derivative ---
    dCnt = dCnt + 1;
    eval(['D(:,dCnt) = ' cKStr ';']);
    Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
    DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
    %--- name handling ---
    legCnt = legCnt + 1;
    legCell{legCnt} = [basisNames{mCnt} ' amp(i)'];
        
    
    %--- Lorentzian parameter alpha_k (individual) ---
    if flag.lcmAnaLb
        % init alpha_k string
        % note that removing the -pi before the exponential does not affect the amplitude CRLB
        % changing the exponential scaling does affect the amplitude CRLB
        % (for a 2-parameter fit of amplitude and LB only)
        alphaKStr = 'basisFid(:,mCnt) .* (lcmAmpVec(mCnt) * -pi.*tVec) .* exp(-lcmLbVec(mCnt)*pi*tVec)';   
        % Gaussian (individual)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            alphaKStr = [alphaKStr ' .* exp(-lcmGbVec(mCnt)*pi^2.*tVec.^2)'];
            % alphaKStr = [alphaKStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(mCnt)^2.*tVec.^2)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            alphaKStr = [alphaKStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt).*tVec)'];
        end
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            alphaKStr = [alphaKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            alphaKStr = [alphaKStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*lcm.anaPhc1*pi/180)'];
        end
        
        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' alphaKStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
        %--- name handling ---
        if ~flag.lcmLinkLb
            legCnt = legCnt + 1;
            legCell{legCnt} = [basisNames{mCnt} sprintf(' LB (i)')];
        end
    end
    
    %--- Gaussian parameter beta_k (individual) ---
    if flag.lcmAnaGb
        % init beta_k string
        betaKStr = 'basisFid(:,mCnt) .* (lcmAmpVec(mCnt) * -(pi^2).*tVec.^2) .* exp(-lcmGbVec(mCnt)*pi^2*tVec.^2)';    
        % betaKStr = 'basisFid(:,mCnt) .* (lcmAmpVec(mCnt) * -2*pi^2 .* tVec.^2 / (4*log(2)) * lcmGbVec(mCnt)) .* exp(-pi^2/(4*log(2)) * lcmGbVec(mCnt)^2 * tVec.^2)';    
        % Lorentzian (individual)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            betaKStr = [betaKStr ' .* exp(-lcmLbVec(mCnt)*pi.*tVec)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            betaKStr = [betaKStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*tVec)'];
        end
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            betaKStr = [betaKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            betaKStr = [betaKStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*lcm.anaPhc1*pi/180)'];
        end
        
        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' betaKStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
        %--- name handling ---
        if  ~flag.lcmLinkGb
            legCnt = legCnt + 1;
            legCell{legCnt} = [basisNames{mCnt} sprintf(' GB (i))')];
        end
    end
    
    %--- frequency parameter omega_k (individual) ---
    if flag.lcmAnaShift
        % init omega_k string
        if flag.lcmAnaPhc1              % with PHC1, there are two omega dependencies
            omegaKStr = 'basisFid(:,mCnt) .* lcmAmpVec(mCnt) * 1i .* (2*pi.*tVec + 2*pi*lcm.anaPhc1*pi/180) .* exp(1i*2*pi*lcmShiftVec(mCnt)*tVec)';    
        else                            % without PHC1, there is only one
            omegaKStr = 'basisFid(:,mCnt) .* lcmAmpVec(mCnt) * 1i .* 2*pi.*tVec .* exp(1i*2*pi*lcmShiftVec(mCnt)*tVec)';
        end
        % Lorentzian (individual)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            omegaKStr = [omegaKStr ' .* exp(-lcmLbVec(mCnt)*pi*tVec)'];
        end
        % Gaussian (individual)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            omegaKStr = [omegaKStr ' .* exp(-lcmGbVec(mCnt)*pi^2*tVec.^2)'];
            % omegaKStr = [omegaKStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(mCnt)^2.*tVec.^2)'];
        end
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            omegaKStr = [omegaKStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            omegaKStr = [omegaKStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*lcm.anaPhc1*pi/180)'];
        end
        
        %--- calculate partial derivative ---
        dCnt = dCnt + 1;
        eval(['D(:,dCnt) = ' omegaKStr ';']);
        Dfft(:,dCnt)     = fftshift(fft(D(:,dCnt)));
        DfftZoom(:,dCnt) = Dfft(lcm.anaAllInd,dCnt);
    
        %--- name handling ---
        if ~flag.lcmLinkShift
            legCnt = legCnt + 1;
            legCell{legCnt} = [basisNames{mCnt} sprintf(' shift (i)')];
        end
    end
    
    %--- global zero-order phase (PHC0) ---
    if flag.lcmAnaPhc0   
        %--- init global phase part ---
        % init phc0 string (always global)
        phc0KStr = 'basisFid(:,mCnt) .* lcmAmpVec(mCnt) * (1i*pi/180) .* exp(1i*lcm.anaPhc0*pi/180)';
        % PHC1 (always global)
        if flag.lcmAnaPhc1
            phc0KStr = [phc0KStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*lcm.anaPhc1*pi/180)'];
        end
        % Lorentzian (global)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            phc0KStr = [phc0KStr ' .* exp(-lcmLbVec(mCnt)*pi*tVec)'];
        end
        % Gaussian (global)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            phc0KStr = [phc0KStr ' .* exp(-lcmGbVec(mCnt)*pi^2*tVec.^2)'];
            % phc0KStr = [phc0KStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(mCnt)^2.*tVec.^2)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            phc0KStr = [phc0KStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*tVec)'];
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
        phc1KStr = '1i * basisFid(:,mCnt) * 2*pi*lcmShiftVec(mCnt) * exp(1i*2*pi*lcmShiftVec(mCnt)*lcm.anaPhc1*pi/180)';
        % PHC0 (always global)
        if flag.lcmAnaPhc0
            phc1KStr = [phc1KStr ' .* exp(1i*lcm.anaPhc0*pi/180)'];
        end
        % Lorentzian (global)
        if flag.lcmAnaLb % && ~flag.lcmLinkLb
            phc1KStr = [phc1KStr ' .* exp(-lcmLbVec(mCnt)*pi*tVec)'];
        end
        % Gaussian (global)
        if flag.lcmAnaGb % && ~flag.lcmLinkGb
            phc1KStr = [phc1KStr ' .* exp(-lcmGbVec(mCnt)*pi^2*tVec.^2)'];
            % phc1KStr = [phc1KStr ' .* exp(-pi^2/(4*log(2))*lcmGbVec(mCnt)^2.*tVec.^2)'];
        end
        % frequency shift (individual)
        if flag.lcmAnaShift % && ~flag.lcmLinkShift
            phc1KStr = [phc1KStr ' .* exp(1i*2*pi*lcmShiftVec(mCnt)*tVec)'];
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


%--- transformation of D to D_eff ---
% number of hypothetical CRLB parameters including combinations, but before
% prior knowledge is applied
crlbRawN   = (parsPerMetab+nGlobal)*(nMetab - flag.lcmComb1*(lcm.comb1N-1) ...
             - flag.lcmComb2*(lcm.comb2N-1) - flag.lcmComb3*(lcm.comb3N-1));
% effective number of CRLB coefficients after everything is set and done:
% 1) combination of metabolites
% 2) application of prior knowledge
nCRLB   = parsPerMetab*nMetabEff+nGlobal;    % = size(P,2) = size(F,1) = size(F,2)
         
% again, note that before P is applied, all fitting parameters are
% considered independent, therefore (parsPerMetab+nGlobal)*...
D_eff      = zeros(lcm.nFidCrlb,crlbRawN);                  % init effective derivative matrix D in time domain
Dfft_eff   = zeros(lcm.nFidCrlb,crlbRawN);                  % init effective derivative matrix D in frequency domain
origUsed   = zeros(1,nMetab);                               % logical vector tracking the unassigned lines of D representing the indivdiual parameters
legEffCell = {}; 

%--- init frequency domain DfftZoom_eff ---
DfftZoom_eff = zeros(lcm.anaAllIndN,parsPerMetab*nMetabEff+nGlobal);

% Note:
% Individual and linked (i.e. global) fitting parameters are treated
% equally in D and D_eff as they are only later linked through the
% application of the prior knowledge matrix P
[ismBin,lcm.comb1IndAppl] = ismember(lcm.comb1Ind,lcm.fit.applied);     % combination indices among applied metabolites
[ismBin,lcm.comb2IndAppl] = ismember(lcm.comb2Ind,lcm.fit.applied);     % combination indices among applied metabolites
[ismBin,lcm.comb3IndAppl] = ismember(lcm.comb3Ind,lcm.fit.applied);     % combination indices among applied metabolites

%--- amplitude (always individual) ---
effCnt = 0;                                             % init local copy of mCnt to prevent duplicate assignment of combination metabolites
if flag.debug
    fprintf('\nAssignment D -> D_eff:\n')
end
legCnt      = 0;                                        % metabolite counter for legend labels
multiShift  = 0;                                        % cumulative index shifting in final metabolite labeling with the combination of metabolites
comb1Shift  = 0;                                        % label shift component due to combination 1
comb2Shift  = 0;                                        % label shift component due to combination 2
comb3Shift  = 0;                                        % label shift component due to combination 3
f_comb1Done = 0;                                        % combination 1 applied
f_comb2Done = 0;                                        % combination 2 applied
f_comb3Done = 0;                                        % combination 3 applied
% note that all indexing refers to the applied metabolites only
for mCnt = 1:nMetab                                     % loop over applied original individual metabolites
    if ~origUsed(mCnt)                                  % skip line has been used already 
        effCnt = effCnt + 1;
        if flag.lcmComb1 && any(mCnt==lcm.comb1IndAppl)
            if flag.debug
                fprintf('Scale: %s -> %.0f (comb 1)\n',SP2_Vec2PrintStr((lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+1,0),(effCnt-1)*(parsPerMetab+nGlobal)+1);      % combined metabolites
            end
            % D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)        =
            % sum(D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+1),2);        % combined metabolites, TD, until 11/2020
            D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)        = ...
                 sum(repmat(lcm.anaScale(lcm.comb1Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+1)/sum(lcm.anaScale(lcm.comb1Ind)),2);        
            % combined metabolites, TD, amplitude-weighted
            % (lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+1  is optimization parameter index across all metabolites
            % for instance, 3 metabolites and 2 variables (amp, LB): 1, (amp1), 2 (lb1), 3 (amp2), 4 (lb2), ...
            Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)));      % combined metabolites, FD
            DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+1);      % combined metabolites, FD zoom
            origUsed(lcm.comb1IndAppl) = 1;                             % mark as used
            lcm.comb1Label = '';                                        % core metab label for result display
            for lCnt = 1:lcm.comb1N
                applInd = find(lcm.comb1Ind(lCnt)==lcm.fit.applied);    % metab index within applied vector (as shown on fit window)
                if lCnt==1
                    applInd1st = applInd;
                    legEffCell{applInd1st-multiShift} = sprintf('%s(%.0f)',basisNames{applInd},applInd);
                    lcm.comb1Label = sprintf('%s',basisNames{applInd});
                    lcm.comb1Pos   = applInd1st-multiShift;
                else
                    legEffCell{applInd1st-multiShift} = sprintf('%s+%s(%.0f)',legEffCell{applInd1st-multiShift},basisNames{applInd},applInd);
                    lcm.comb1Label = sprintf('%s+%s',lcm.comb1Label,basisNames{applInd});
                end    
            end
            if flag.debug
                fprintf('mCnt %.0f -> %.0f: %s\n',mCnt,applInd1st-multiShift,legEffCell{applInd1st-multiShift})
            end
            f_comb1Done = 1;
            legCnt      = legCnt + 1;                                   % increase metabolite legend counter
        elseif flag.lcmComb2 && any(mCnt==lcm.comb2IndAppl)
            if flag.debug
                fprintf('Scale: %s -> %.0f (comb 2)\n',SP2_Vec2PrintStr((lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+1,0),(effCnt-1)*(parsPerMetab+nGlobal)+1);      % combined metabolites
            end
            % D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)        = sum(D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+1),2);        % combined metabolites, TD
            D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)        = ...
                 sum(repmat(lcm.anaScale(lcm.comb2Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+1)/sum(lcm.anaScale(lcm.comb2Ind)),2);        
            Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)));      % combined metabolites, FD
            DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+1);      % combined metabolites, FD zoom
            origUsed(lcm.comb2IndAppl) = 1;                             % mark as used
            lcm.comb2Label = '';                                        % core metab label for result display
            for lCnt = 1:lcm.comb2N
                applInd = find(lcm.comb2Ind(lCnt)==lcm.fit.applied);    % metab index within applied vector (as shown on fit window)
                if lCnt==1
                    applInd1st = applInd;
                    legEffCell{applInd1st-multiShift} = sprintf('%s(%.0f)',basisNames{applInd},applInd);
                    lcm.comb2Label = sprintf('%s',basisNames{applInd});
                    lcm.comb2Pos   = applInd1st-multiShift;
                else
                    legEffCell{applInd1st-multiShift} = sprintf('%s+%s(%.0f)',legEffCell{applInd1st-multiShift},basisNames{applInd},applInd);
                    lcm.comb2Label = sprintf('%s+%s',lcm.comb2Label,basisNames{applInd});
                end
            end
            if flag.debug
                fprintf('mCnt %.0f -> %.0f: %s\n',mCnt,applInd1st-multiShift,legEffCell{applInd1st-multiShift})
            end
            f_comb2Done = 1;
            legCnt      = legCnt + 1;                                   % increase metabolite legend counter
        elseif flag.lcmComb3 && any(mCnt==lcm.comb3IndAppl)
            if flag.debug
                fprintf('Scale: %s -> %.0f (comb 3)\n',SP2_Vec2PrintStr((lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+1,0),(effCnt-1)*(parsPerMetab+nGlobal)+1);      % combined metabolites
            end
            % D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)        = sum(D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+1),2);        % combined metabolites, TD
            D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)        = ...
                 sum(repmat(lcm.anaScale(lcm.comb3Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+1)/sum(lcm.anaScale(lcm.comb3Ind)),2);        
            Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)));      % combined metabolites, FD
            DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+1);      % combined metabolites, FD zoom
            origUsed(lcm.comb3IndAppl) = 1;                             % mark as used
            lcm.comb3Label = '';                                        % core metab label for result display
            for lCnt = 1:lcm.comb3N
                applInd = find(lcm.comb3Ind(lCnt)==lcm.fit.applied);    % metab index within applied vector (as shown on fit window)
                if lCnt==1
                    applInd1st = applInd;
                    legEffCell{applInd1st-multiShift} = sprintf('%s(%.0f)',basisNames{applInd},applInd);
                    lcm.comb3Label = sprintf('%s',basisNames{applInd});
                    lcm.comb3Pos   = applInd1st-multiShift;
                else
                    legEffCell{applInd1st-multiShift} = sprintf('%s+%s(%.0f)',legEffCell{applInd1st-multiShift},basisNames{applInd},applInd);
                    lcm.comb3Label = sprintf('%s+%s',lcm.comb3Label,basisNames{applInd});
                end    
            end
            if flag.debug
                fprintf('mCnt %.0f -> %.0f: %s\n',mCnt,applInd1st-multiShift,legEffCell{applInd1st-multiShift})
            end
            f_comb3Done = 1;
            legCnt      = legCnt + 1;                                   % increase metabolite legend counter
        else
            if flag.debug
                fprintf('Scale: %.0f -> %.0f\n',(mCnt-1)*(parsPerMetab+nGlobal)+1,(effCnt-1)*(parsPerMetab+nGlobal)+1);      % combined metabolites
            end
            D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)        = D(:,(mCnt-1)*(parsPerMetab+nGlobal)+1);                           % TD
            Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1)));      % FD
            DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+1) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+1);      % FD zoom
            origUsed(mCnt) = 1;
            
            %--- legend handling ---
            % shift labels up for the combination once that have been
            % merged if their position has already passed
            if f_comb1Done              % combination 1 has been applied already
                comb1ShiftTmp = length(find(mCnt>=lcm.comb1IndAppl))-1;
                if comb1ShiftTmp>comb1Shift         % update only once
                    comb1Shift = comb1ShiftTmp; 
                end
            end
            if f_comb2Done              % combination 2 has been applied already
                comb2ShiftTmp = length(find(mCnt>=lcm.comb2IndAppl))-1;
                if comb2ShiftTmp>comb2Shift         % update only once
                    comb2Shift = comb2ShiftTmp; 
                end
            end
            if f_comb3Done              % combination 3 has been applied already
                comb3ShiftTmp = length(find(mCnt>=lcm.comb3IndAppl))-1;
                if comb3ShiftTmp>comb3Shift         % update only once
                    comb3Shift = comb3ShiftTmp; 
                end
            end
            multiShift = comb1Shift + comb2Shift + comb3Shift;
            
            % only add label if the metabolite is not part of any
            % combination. Since the first appearances of every combination
            % are covered by the cases above, the following effectively
            % only applies to the combination partners
            if flag.lcmComb1
                if ~any(mCnt==lcm.comb1IndAppl)
                    f_comb1OK = 1;
                else
                    f_comb1OK = 0;
                end
            else
                f_comb1OK = 1;
            end
            if flag.lcmComb2
                if ~any(mCnt==lcm.comb2IndAppl)
                    f_comb2OK = 1;
                else
                    f_comb2OK = 0;
                end
            else
                f_comb2OK = 1;
            end
            if flag.lcmComb3
                if ~any(mCnt==lcm.comb3IndAppl)
                    f_comb3OK = 1;
                else
                    f_comb3OK = 0;
                end
            else
                f_comb3OK = 1;
            end
            if f_comb1OK && f_comb2OK && f_comb3OK                  % 
                legCnt = legCnt + 1;            % increase metabolite legend counter
                legEffCell{legCnt} = basisNames{mCnt};
                if flag.debug
                    fprintf('mCnt %.0f -> %.0f: %s\n',mCnt,legCnt,legEffCell{legCnt})
                end
            end
        end
    end
end


%--- Lorentzian line broadening ---
effCnt    = 0;                                              % init local copy of mCnt to prevent duplicate assignment of combination metabolites
origUsed  = zeros(1,nMetab);                                % reset logical vector tracking the unassigned lines of D representing the indivdiual parameters
if flag.lcmAnaLb
    for mCnt = 1:nMetab                                     % loop over original individual metabolites
        if ~origUsed(mCnt)                                  % skip lines that have been used already 
            effCnt = effCnt + 1;
            if flag.lcmComb1 && any(mCnt==lcm.comb1IndAppl)
                if flag.debug
                    fprintf('LB:    %s -> %.0f (comb 1)\n',SP2_Vec2PrintStr((lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)        = sum(D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+2),2);        % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb1Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+2)/sum(lcm.anaScale(lcm.comb1Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)));      % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+2);      % combined metabolites, FD zoom
                origUsed(lcm.comb1IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb2 && any(mCnt==lcm.comb2IndAppl)
                if flag.debug
                    fprintf('LB:    %s -> %.0f (comb 2)\n',SP2_Vec2PrintStr((lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)        = sum(D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+2),2);        % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb2Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+2)/sum(lcm.anaScale(lcm.comb2Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)));      % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+2);      % combined metabolites, FD zoom
                origUsed(lcm.comb2IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb3 && any(mCnt==lcm.comb3IndAppl)
                if flag.debug
                    fprintf('LB:    %s -> %.0f (comb 3)\n',SP2_Vec2PrintStr((lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)        = sum(D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+2),2);        % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb3Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+2)/sum(lcm.anaScale(lcm.comb3Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)));      % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+2);      % combined metabolites, FD zoom
                origUsed(lcm.comb3IndAppl) = 1;                     % mark as used
            else
                if flag.debug
                    fprintf('LB:    %.0f -> %.0f\n',(mCnt-1)*(parsPerMetab+nGlobal)+2,...
                        (effCnt-1)*(parsPerMetab+nGlobal)+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)        = D(:,(mCnt-1)*(parsPerMetab+nGlobal)+2);                           % TD
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)     = fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2)));      % FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+2) = Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+2);      % FD zoom
                origUsed(mCnt) = 1;
            end
        end
    end
end

%--- Gaussian line broadening ---
effCnt    = 0;                                              % init local copy of mCnt to prevent duplicate assignment of combination metabolites
origUsed  = zeros(1,nMetab);                                % reset logical vector tracking the unassigned lines of D representing the indivdiual parameters
if flag.lcmAnaGb
    for mCnt = 1:nMetab                                     % loop over original individual metabolites
        if ~origUsed(mCnt)                                  % skip line has been used already 
            effCnt = effCnt + 1;
            if flag.lcmComb1 && any(mCnt==lcm.comb1IndAppl)
                if flag.debug
                    fprintf('GB:    %s -> %.0f (comb 1)\n',SP2_Vec2PrintStr((lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)        = ...
                    sum(D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2),2);        % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb1Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)/sum(lcm.anaScale(lcm.comb1Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)));      % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % combined metabolites, FD zoom
                origUsed(lcm.comb1IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb2 && any(mCnt==lcm.comb2IndAppl)
                if flag.debug
                    fprintf('GB:    %s -> %.0f (comb 2)\n',SP2_Vec2PrintStr((lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)        = ...
                    sum(D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2),2);        % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb2Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)/sum(lcm.anaScale(lcm.comb2Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)));      % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % combined metabolites, FD zoom
                origUsed(lcm.comb2IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb3 && any(mCnt==lcm.comb3IndAppl)
                if flag.debug
                    fprintf('GB:    %s -> %.0f (comb 3)\n',SP2_Vec2PrintStr((lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)        = ...
                    sum(D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2),2);        % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb3Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)/sum(lcm.anaScale(lcm.comb3Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)));      % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % combined metabolites, FD zoom
                origUsed(lcm.comb3IndAppl) = 1;                     % mark as used
            else
                if flag.debug
                    fprintf('GB:    %.0f -> %.0f\n',(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2,...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)        = ...             
                    D(:,(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);                           % TD
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2)));      % FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+2);      % FD zoom
                origUsed(mCnt) = 1;
            end
        end
    end
end

%--- frequency shift ---
effCnt    = 0;                                              % init local copy of mCnt to prevent duplicate assignment of combination metabolites
origUsed  = zeros(1,nMetab);                                % reset logical vector tracking the unassigned lines of D representing the indivdiual parameters
if flag.lcmAnaShift
    for mCnt = 1:nMetab                                     % loop over original individual metabolites
        if ~origUsed(mCnt)                                  % skip line if it has been used already 
            effCnt = effCnt + 1;
            if flag.lcmComb1 && any(mCnt==lcm.comb1IndAppl)
                if flag.debug
                    fprintf('Shift: %s -> %.0f (comb 1)\n',SP2_Vec2PrintStr((lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)        = ...
                    sum(D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2),2);          % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb1Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)/sum(lcm.anaScale(lcm.comb1Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)));        % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);        % combined metabolites, FD zoom
                origUsed(lcm.comb1IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb2 && any(mCnt==lcm.comb2IndAppl)
                if flag.debug
                    fprintf('Shift: %s -> %.0f (comb 2)\n',SP2_Vec2PrintStr((lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)        = ...
                    sum(D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2),2);          % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb2Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)/sum(lcm.anaScale(lcm.comb2Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)));        % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);        % combined metabolites, FD zoom
                origUsed(lcm.comb2IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb3 && any(mCnt==lcm.comb3IndAppl)
                if flag.debug
                    fprintf('Shift: %s -> %.0f (comb 3)\n',SP2_Vec2PrintStr((lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)        = ....
                    sum(D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2),2);          % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb3Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)/sum(lcm.anaScale(lcm.comb3Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)));        % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);        % combined metabolites, FD zoom
                origUsed(lcm.comb3IndAppl) = 1;                     % mark as used
            else
                if flag.debug
                    fprintf('Shift: %.0f -> %.0f\n',(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2,...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)        = ...
                    D(:,(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);                             % TD
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2)));        % FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+2);        % FD zoom
                origUsed(mCnt) = 1;
            end
        end
    end
end

%--- PHC0 ---
effCnt    = 0;                                              % init local copy of mCnt to prevent duplicate assignment of combination metabolites
origUsed  = zeros(1,nMetab);                                % reset logical vector tracking the unassigned lines of D representing the indivdiual parameters
if flag.lcmAnaPhc0
    for mCnt = 1:nMetab                                     % loop over original individual metabolites
        if ~origUsed(mCnt)                                  % skip line has been used already 
            effCnt = effCnt + 1;
            if flag.lcmComb1 && any(mCnt==lcm.comb1IndAppl)
                if flag.debug
                    fprintf('PHC0:  %s -> %.0f (comb 1)\n',SP2_Vec2PrintStr((lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)        = ...
                    sum(D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2),2);         % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb1Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)/sum(lcm.anaScale(lcm.comb1Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)));       % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);       % combined metabolites, FD zoom
                origUsed(lcm.comb1IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb2 && any(mCnt==lcm.comb2IndAppl)
                if flag.debug
                    fprintf('PHC0:  %s -> %.0f (comb 2)\n',SP2_Vec2PrintStr((lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)        = ...
                    sum(D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2),2);         % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb2Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)/sum(lcm.anaScale(lcm.comb2Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)));       % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);       % combined metabolites, FD zoom
                origUsed(lcm.comb2IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb3 && any(mCnt==lcm.comb3IndAppl)
                if flag.debug
                    fprintf('PHC0:  %s -> %.0f (comb 3)\n',SP2_Vec2PrintStr((lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)        = ...
                    sum(D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2),2);         % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb3Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)/sum(lcm.anaScale(lcm.comb3Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)));       % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);       % combined metabolites, FD zoom
                origUsed(lcm.comb3IndAppl) = 1;                     % mark as used
            else
                if flag.debug
                    fprintf('PHC0:  %.0f -> %.0f\n',(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2,...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)        = ...
                    D(:,(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);                            % TD
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2)));       % FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+2);       % FD zoom
                origUsed(mCnt) = 1;
            end
        end
    end
end

%--- PHC1 ---
effCnt    = 0;                                              % init local copy of mCnt to prevent duplicate assignment of combination metabolites
origUsed  = zeros(1,nMetab);                                % reset logical vector tracking the unassigned lines of D representing the indivdiual parameters
if flag.lcmAnaPhc1
    for mCnt = 1:nMetab                                     % loop over original individual metabolites
        if ~origUsed(mCnt)                                  % skip line has been used already 
            effCnt = effCnt + 1;
            if flag.lcmComb1 && any(mCnt==lcm.comb1IndAppl)
                if flag.debug
                    fprintf('PHC1:  %s -> %.0f (comb 1)\n',SP2_Vec2PrintStr((lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)        = ...
                    sum(D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2),2);         % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb1Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb1IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)/sum(lcm.anaScale(lcm.comb1Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)));       % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);       % combined metabolites, FD zoom
                origUsed(lcm.comb1IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb2 && any(mCnt==lcm.comb2IndAppl)
                if flag.debug
                    fprintf('PHC1:  %s -> %.0f (comb 2)\n',SP2_Vec2PrintStr((lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)        = ...
                    sum(D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2),2);         % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb2Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb2IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)/sum(lcm.anaScale(lcm.comb2Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)));       % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);       % combined metabolites, FD zoom
                origUsed(lcm.comb2IndAppl) = 1;                     % mark as used
            elseif flag.lcmComb3 && any(mCnt==lcm.comb3IndAppl)
                if flag.debug
                    fprintf('PHC1:  %s -> %.0f (comb 3)\n',SP2_Vec2PrintStr((lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2,0),...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)        = ...
                    sum(D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2),2);         % combined metabolites, TD
%                 D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)        = ...
%                      sum(repmat(lcm.anaScale(lcm.comb3Ind),[lcm.nFidCrlb 1]).*D(:,(lcm.comb3IndAppl-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)/sum(lcm.anaScale(lcm.comb3Ind)),2);        
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)));       % combined metabolites, FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);       % combined metabolites, FD zoom
                origUsed(lcm.comb3IndAppl) = 1;                     % mark as used
            else
                if flag.debug
                    fprintf('PHC0:  %.0f -> %.0f\n',(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2,...
                        (effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);      % combined metabolites
                end
                D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)        = ...
                    D(:,(mCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);                            % TD
                Dfft_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)     = ...
                    fftshift(fft(D_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2)));       % FD
                DfftZoom_eff(:,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2) = ...
                    Dfft_eff(lcm.anaAllInd,(effCnt-1)*(parsPerMetab+nGlobal)+flag.lcmAnaLb+flag.lcmAnaGb+flag.lcmAnaShift+flag.lcmAnaPhc0+2);       % FD zoom
                origUsed(mCnt) = 1;
            end
        end
    end
end

%--- replace original cell with combined one ---
legCell   = legEffCell;
if length(legEffCell)~=nMetabEff
    fprintf('%s ->\nDimensionality inconsistency detected. Program aborted.\n',FCTNAME)
    return
end
       
%--- result assignment ---          
D        = D_eff;           % TD, no longer used in F (and CRLB) calculation
Dfft     = Dfft_eff;        % FD, not used in F (and CRLB) calculation
DfftZoom = DfftZoom_eff;    % FD, specific to analyzed frequency window: used in F (and CRLB) calculation
dCnt = crlbRawN;

% generation of P for arbitrary combination of independent and global parameters
P = zeros(dCnt,nCRLB);         % 1: all pars, 2: effective size
% indVec = parsPerMetab:parsPerMetab:dCnt;
indVec1st = 1:parsPerMetabD:dCnt;                       % (1st) index vector for global parameter dimension
rowInd    = 1;                                          % init row index
colInd    = 1;                                          % init column index
%--- metabolite-specific parameters ---
for colCnt = 1:nMetabEff
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
    if flag.debug
        fprintf('\nCombined prior knowledge P:\n')
        for rowCnt = 1:dCnt
            fprintf('| %s |\n',SP2_Vec2PrintStr(P(rowCnt,:),0,0))
        end
    end
    fprintf('size(D combined) = [%.0f %.0f], size(P) = [%.0f %.0f]\n',size(D,1),size(D,2),size(P,1),size(P,2))
    fprintf('Full combined D:  %.0f metabs * %.0f metab-specific pars = %.0f\n',nMetabEff,parsPerMetabD,dCnt)
    fprintf('After combined P: %.0f metabs * %.0f metab-specific pars + %.0f global pars = %.0f fit pars (CRLB)\n',...
            nMetabEff,parsPerMetabD-globCnt,globCnt,nCRLB)

    %--- log file ---
    if flag.lcmSaveLog && ~f_plot
        if flag.debug
            fprintf(lcm.log,'\nCombined prior knowledge P:\n');
            for rowCnt = 1:dCnt
                fprintf(lcm.log,'| %s |\n',SP2_Vec2PrintStr(P(rowCnt,:),0,0));
            end
        end
        fprintf(lcm.log,'size(D combined) = [%.0f %.0f], size(P) = [%.0f %.0f]\n',size(D,1),size(D,2),size(P,1),size(P,2));
        fprintf(lcm.log,'Full combined D:  %.0f metabs * %.0f metab-specific pars = %.0f\n',nMetabEff,parsPerMetabD,dCnt);
        fprintf(lcm.log,'After combined P: %.0f metabs * %.0f metab-specific pars + %.0f global pars = %.0f fit pars (CRLB)\n',...
                nMetabEff,parsPerMetabD-globCnt,globCnt,nCRLB);
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
    lcm.fhCombFisher = figure;
    set(lcm.fhCombFisher,'NumberTitle','off','Name',sprintf(' Combined Fisher Information Matrix'),...
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
        fisherFigPath = [lcm.expt.dataDir 'SPX_LcmCombFisher.fig'];
        saveas(lcm.fhCombFisher,fisherFigPath,'fig');
        fprintf('Fisher information matrix saved to file:\n%s\n',fisherFigPath);
    end
end

%--- dimension update ---
% parsPerMetab = parsPerMetab-nGlobal;                % since PHC0 is now global 
% nCRLB = crlbEffN;            

%--- Cramer-Rao Lower Bounds ---
invF = inv(F);
lcm.fit.combCrlb = zeros(1,nCRLB);                  % complete CRLB vector included metabolite-specific and global parameters
for crlbCnt = 1:nCRLB
    lcm.fit.combCrlb(crlbCnt) = sqrt(invF(crlbCnt,crlbCnt));
%     lcm.fit.combCrlb(crlbCnt) = sqrt(invF(crlbCnt,crlbCnt))/lcm.anaScale(lcm.fit.appliedFit(crlbCnt));
end

%--- real vs. complex FID (and fit) ---
% note that every FID that does not derive from quadrature detection
% contains correlated noise in both real and imaginary parts which leads
% to an underestimation of the CRLB by a factor of 0.71 = 1/sqrt(2). As
% such every such FID should be considered (and fitted) as real spectrum
% and the CRLB should be rescaled, i.e. upscaled, accordingly.
if flag.lcmRealComplex
    lcm.fit.combCrlb = sqrt(2) * lcm.fit.combCrlb;
    fprintf('\nCRLBs scaled by sqrt(2) to account for real-valued FID.\n')
    
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
indCnt = 1;                                            % init individual parameter counter
% lcm.fit.combCrlbAmp = min(100*lcm.fit.combCrlb(indCnt:parsPerMetab:nCRLB-nGlobal),666);
lcm.fit.combCrlbAmp = lcm.fit.combCrlb(indCnt:parsPerMetab:nCRLB-nGlobal);

% Lorentzian broadening
if flag.lcmAnaLb && ~flag.lcmLinkLb
    indCnt = indCnt + 1;
    lcm.fit.combCrlbLb = lcm.fit.combCrlb(indCnt:parsPerMetab:nCRLB-nGlobal);
end

% Gaussian broadening
if flag.lcmAnaGb && ~flag.lcmLinkGb
    indCnt = indCnt + 1;
    lcm.fit.combCrlbGb = lcm.fit.combCrlb(indCnt:parsPerMetab:nCRLB-nGlobal);
end

% frequency shift
if flag.lcmAnaShift && ~flag.lcmLinkShift
    indCnt = indCnt + 1;
    lcm.fit.combCrlbShift = lcm.fit.combCrlb(indCnt:parsPerMetab:nCRLB-nGlobal);
end


%--------------------------------------------------------------------------
%--- extract global CRLBs                                               ---
globCnt = 0;                          % counter of global parameters
%--- PHC1 ---
if flag.lcmAnaPhc1
    globCnt = globCnt + 1;
    lcm.fit.combCrlbPhc1 = lcm.fit.combCrlb(nCRLB-globCnt+1);
end

%--- PHC0 ---
if flag.lcmAnaPhc0
    globCnt = globCnt + 1;
    lcm.fit.combCrlbPhc0 = lcm.fit.combCrlb(nCRLB-globCnt+1);
end    

%--- frequency shift ---
if flag.lcmAnaShift && flag.lcmLinkShift
    globCnt = globCnt + 1;
    lcm.fit.combCrlbShift = lcm.fit.combCrlb(nCRLB-globCnt+1);
end    

%--- GB ---
if flag.lcmAnaGb && flag.lcmLinkGb
    globCnt = globCnt + 1;
    lcm.fit.combCrlbGb = lcm.fit.combCrlb(nCRLB-globCnt+1);
end    

%--- LB ---
if flag.lcmAnaLb && flag.lcmLinkLb
    globCnt = globCnt + 1;
    lcm.fit.combCrlbLb = lcm.fit.combCrlb(nCRLB-globCnt+1);
end

%--- CRLB printout ---
if f_plot || flag.verbose
    mStrMax = 0;
    for mCnt = 1:nMetabEff
        if length(legEffCell{mCnt})>mStrMax
            mStrMax = length(legEffCell{mCnt});
        end
    end
    fprintf('\nSummary of combined amplitude CRLBs:\n')
    for mCnt = 1:nMetabEff
        fprintf('%s%s%.5f a.u.\n',legEffCell{mCnt},SP2_NSpaces(mStrMax-length(legEffCell{mCnt})+2),lcm.fit.combCrlbAmp(mCnt))   
    end
    fprintf('\n')
end
% lcm.anaCrlb = crlbAmp;


%--- info printout: individual pars ---
% in original order
fprintf('CRLB(amplitude) = %s a.u.\n',SP2_Vec2PrintStr(lcm.fit.combCrlbAmp,3))
if flag.lcmAnaLb && ~flag.lcmLinkLb
    fprintf('CRLB(LB)        = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.combCrlbLb,3))
end
if flag.lcmAnaGb && ~flag.lcmLinkGb
    fprintf('CRLB(GB)        = %s Hz^2\n',SP2_Vec2PrintStr(lcm.fit.combCrlbGb,3))
end
if flag.lcmAnaShift && ~flag.lcmLinkShift
    fprintf('CRLB(Shift)     = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.combCrlbShift,3))
end


%--- info printout: global pars ---
% in original order
if flag.lcmAnaLb && flag.lcmLinkLb
    fprintf('CRLB(LB)        = %.3f Hz\n',lcm.fit.combCrlbLb)
end
if flag.lcmAnaGb && flag.lcmLinkGb
    fprintf('CRLB(GB)        = %.3f Hz^2\n',lcm.fit.combCrlbGb)
end
if flag.lcmAnaShift && flag.lcmLinkShift
    fprintf('CRLB(Shift)     = %.3f Hz\n',lcm.fit.combCrlbShift)
end
if flag.lcmAnaPhc0
    fprintf('CRLB(PHC0)      = %.3f deg\n',lcm.fit.combCrlbPhc0)
end
if flag.lcmAnaPhc1
    fprintf('CRLB(PHC1)      = %.3f deg\n',lcm.fit.combCrlbPhc1)
end



%--- info printout: individual/global parameters (log file) ---
if flag.lcmSaveLog && ~f_plot
    %--- info printout: individual pars ---
    % in original order
    fprintf(lcm.log,'CRLB(amplitude) = %s a.u.\n',SP2_Vec2PrintStr(lcm.fit.combCrlbAmp,3));
    if flag.lcmAnaLb && ~flag.lcmLinkLb
        fprintf(lcm.log,'CRLB(LB)        = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.combCrlbLb,3));
    end
    if flag.lcmAnaGb && ~flag.lcmLinkGb
        fprintf(lcm.log,'CRLB(GB)        = %s Hz^2\n',SP2_Vec2PrintStr(lcm.fit.combCrlbGb,3));
    end
    if flag.lcmAnaShift && ~flag.lcmLinkShift
        fprintf(lcm.log,'CRLB(Shift)     = %s Hz\n',SP2_Vec2PrintStr(lcm.fit.combCrlbShift,3));
    end


    %--- info printout: global pars ---
    % in original order
    if flag.lcmAnaLb && flag.lcmLinkLb
        fprintf(lcm.log,'CRLB(LB)        = %.3f Hz\n',lcm.fit.combCrlbLb);
    end
    if flag.lcmAnaGb && flag.lcmLinkGb
        fprintf(lcm.log,'CRLB(GB)        = %.3f Hz^2\n',lcm.fit.combCrlbGb);
    end
    if flag.lcmAnaShift && flag.lcmLinkShift
        fprintf(lcm.log,'CRLB(Shift)     = %.3f Hz\n',lcm.fit.combCrlbShift);
    end
    if flag.lcmAnaPhc0
        fprintf(lcm.log,'CRLB(PHC0)      = %.3f deg\n',lcm.fit.combCrlbPhc0);
    end
    if flag.lcmAnaPhc1
        fprintf(lcm.log,'CRLB(PHC1)      = %.3f deg\n',lcm.fit.combCrlbPhc1);
    end
end 
    
%--- close log file ---
% if flag.lcmSaveLog && ~f_plot
%     fclose(lcm.log);
% end


%--- data compilation for display/saving ---
combCnt = 0;        % combination counter
if flag.lcmComb1
    combCnt = combCnt + 1;
    lcm.combLabels{combCnt} = lcm.comb1Label;                      % metabolite combination label
    lcm.combScale(combCnt)  = sum(lcm.anaScale(lcm.comb1Ind));     % concentration sum
    if flag.lcmAnaLb && ~flag.lcmLinkLb
        lcm.combLb(combCnt) = mean(lcm.anaLb(lcm.comb1Ind));
    else
        lcm.combLb(combCnt) = 0;
    end
    if flag.lcmAnaGb && ~flag.lcmLinkGb
        lcm.combGb(combCnt) = mean(lcm.anaGb(lcm.comb1Ind));
    else
        lcm.combGb(combCnt) = 0;
    end
    if flag.lcmAnaShift && ~flag.lcmLinkShift
        lcm.combShift(combCnt) = mean(lcm.anaShift(lcm.comb1Ind));
    else
        lcm.combShift(combCnt) = 0;
    end
    lcm.combCrlbPos(combCnt) = lcm.comb1Pos;                        % index position in final combined result vectors of the respective CRLB types
end
if flag.lcmComb2
    combCnt = combCnt + 1;
    lcm.combLabels{combCnt} = lcm.comb2Label;                      % metabolite combination label
    lcm.combScale(combCnt)  = sum(lcm.anaScale(lcm.comb2Ind));     % concentration sum
    if flag.lcmAnaLb && ~flag.lcmLinkLb
        lcm.combLb(combCnt) = mean(lcm.anaLb(lcm.comb2Ind));
    else
        lcm.combLb(combCnt) = 0;
    end
    if flag.lcmAnaGb && ~flag.lcmLinkGb
        lcm.combGb(combCnt) = mean(lcm.anaGb(lcm.comb2Ind));
    else
        lcm.combGb(combCnt) = 0;
    end
    if flag.lcmAnaShift && ~flag.lcmLinkShift
        lcm.combShift(combCnt) = mean(lcm.anaShift(lcm.comb2Ind));
    else
        lcm.combShift(combCnt) = 0;
    end
    lcm.combCrlbPos(combCnt) = lcm.comb2Pos;
end
if flag.lcmComb3
    combCnt = combCnt + 1;
    lcm.combLabels{combCnt} = lcm.comb3Label;                      % metabolite combination label
    lcm.combScale(combCnt)  = sum(lcm.anaScale(lcm.comb3Ind));     % concentration sum
    if flag.lcmAnaLb && ~flag.lcmLinkLb
        lcm.combLb(combCnt) = mean(lcm.anaLb(lcm.comb3Ind));
    else
        lcm.combLb(combCnt) = 0;
    end
    if flag.lcmAnaGb && ~flag.lcmLinkGb
        lcm.combGb(combCnt) = mean(lcm.anaGb(lcm.comb3Ind));
    else
        lcm.combGb(combCnt) = 0;
    end
    if flag.lcmAnaShift && ~flag.lcmLinkShift
        lcm.combShift(combCnt) = mean(lcm.anaShift(lcm.comb3Ind));
    else
        lcm.combShift(combCnt) = 0;
    end
    lcm.combCrlbPos(combCnt) = lcm.comb3Pos;
end
lcm.combN   = combCnt;                                              % number of combination (= sum over flags)
lcm.combInd = find([flag.lcmComb1 flag.lcmComb2 flag.lcmComb3]);    % index vector of metabolite combinations selected out of [1 2 3]


%-------------------------------------------------
%--- correlation matrix                        ---
% CavasillaS00a, equ. 13
% The diagonal elements of F21 are the variance bounds on the parameters (squares of the CRBs)
combCorrMatCompl = zeros(nCRLB,nCRLB);          % init complete correlation matrix
for rowCnt = 1:nCRLB
    for colCnt = 1:nCRLB
        combCorrMatCompl(colCnt,rowCnt) = (invF(colCnt,rowCnt)/sqrt(invF(colCnt,colCnt)*invF(rowCnt,rowCnt)));
    end
end

%--------------------------------------------------------------------------------------------------
%--- extract correlation data of the same type (e.g. amplitudes) and reformat for visualization ---
% rearrange to have first metabolite in lower left corner (similar to Minnesota)
% amplitude
indCnt     = 1;             % init individual parameter counter
combCorrMatAmp = flipud(combCorrMatCompl(indCnt:parsPerMetab:nCRLB-nGlobal,1:parsPerMetab:nCRLB-nGlobal));

% Lorentzian broadening
if flag.lcmAnaLb && ~flag.lcmLinkLb
    indCnt    = indCnt + 1;
    combCorrMatLb = flipud(combCorrMatCompl(indCnt:parsPerMetab:nCRLB-nGlobal,1:parsPerMetab:nCRLB-nGlobal));
end

% Gaussian broadening
if flag.lcmAnaGb && ~flag.lcmLinkGb
    indCnt    = indCnt + 1;
    combCorrMatGb = flipud(combCorrMatCompl(indCnt:parsPerMetab:nCRLB-nGlobal,1:parsPerMetab:nCRLB-nGlobal));
end

% frequency shift
if flag.lcmAnaShift && ~flag.lcmLinkShift
    indCnt       = indCnt + 1;
    combCorrMatShift = flipud(combCorrMatCompl(indCnt:parsPerMetab:nCRLB-nGlobal,1:parsPerMetab:nCRLB-nGlobal));
end

%--- keep for potential saving to xls file ---
lcm.fit.combCorr = combCorrMatAmp;

%--- figure creation: amplitude correlation matrix ---
if f_plot
    lcm.fhCombCorrAmp = figure;
    set(lcm.fhCombCorrAmp,'NumberTitle','off','Name',sprintf(' Combined LCModel Correlation Matrix: Amplitude'),...
               'Position',[500 320 692 550],'Color',[1 1 1],'Tag','LCM')
    imagesc(combCorrMatAmp,[-1 1])
    set(gca,'XTick',1:length(legEffCell),'XTickLabel',SP2_PrVersionUscoreCell(legEffCell),'YTick',1:length(legEffCell),'YTickLabel',fliplr(legEffCell));
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
    if exist('combCorrMatLb','var')
        lcm.fhCombCorrLb = figure;
        set(lcm.fhCombCorrLb,'NumberTitle','off','Name',sprintf(' Combined LCModel Correlation Matrix: Lorentzian Linebroadening'),...
                   'Position',[510 330 692 550],'Color',[1 1 1],'Tag','LCM')
        imagesc(combCorrMatLb,[-1 1])
        set(gca,'XTick',1:length(legEffCell),'XTickLabel',SP2_PrVersionUscoreCell(legEffCell),'YTick',1:length(legEffCell),'YTickLabel',fliplr(legEffCell));
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
    if exist('combCorrMatGb','var')
        lcm.fhCombCorrGb = figure;
        set(lcm.fhCombCorrGb,'NumberTitle','off','Name',sprintf(' Combined LCModel Correlation Matrix: Gaussian Linebroadening'),...
                   'Position',[520 340 692 550],'Color',[1 1 1],'Tag','LCM')
        imagesc(combCorrMatGb,[-1 1])
        set(gca,'XTick',1:length(legEffCell),'XTickLabel',SP2_PrVersionUscoreCell(legEffCell),'YTick',1:length(legEffCell),'YTickLabel',fliplr(legEffCell));
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
    if exist('combCorrMatShift','var')
        lcm.fhCombCorrShift = figure;
        set(lcm.fhCombCorrShift,'NumberTitle','off','Name',sprintf(' Combined LCModel Correlation Matrix: Frequency Shift'),...
                   'Position',[530 350 692 550],'Color',[1 1 1],'Tag','LCM')
        imagesc(combCorrMatShift,[-1 1])
        set(gca,'XTick',1:nMetabEff,'XTickLabel',SP2_PrVersionUscoreCell(legEffCell),'YTick',1:nMetabEff,'YTickLabel',fliplr(legEffCell));
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
if 0        % labels not worked out yet, to be added
    % if f_plot && flag.verbose
    lcm.fhCombCorrCompl = figure;
    set(lcm.fhCombCorrCompl,'NumberTitle','off','Name',sprintf(' Combined LCModel Correlation Matrix: Complete'),...
               'Position',[100 100 692 550],'Color',[1 1 1],'Tag','LCM')
    imagesc(flipud(combCorrMatCompl),[-1 1])
    
    %--- display matrix ---
    set(gca,'XTick',1:length(legEffCell),'XTickLabel',SP2_PrVersionUscoreCell(legEffCell),'YTick',1:length(legEffCell),'YTickLabel',fliplr(legEffCell));
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




