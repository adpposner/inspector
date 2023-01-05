%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_SvdPeakAnalysis( specNumber )
%%
%%  Hankel SVD-based water removal. Note that the Lanczos algorithm
%%  exploiting the symmetry of the Hankel form to focus on the strongest
%%  signals only (thereby reducing the computational load) has not been
%%  implemented yet, i.e. it's not used here.
%%  Literature: PijnappelWWF92a, DeBeerR92b
%%
%%  07-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm

FCTNAME = 'SP2_LCM_SvdPeakAnalysis';


%--- init success flag ---
f_succ = 0;

%--- info printout ---
fprintf('%s started...\n',FCTNAME);

%--- check data existence ---
if specNumber==1
    if ~isfield(lcm.spec1,'fid')
        fprintf('%s ->\nNo FID of spectral data set 1 found. Load data first.\n',FCTNAME);
        return
    end
elseif specNumber==2
    if ~isfield(lcm.spec2,'fid')
        fprintf('%s ->\nNo FID of spectral data set 2 found. Load data first.\n',FCTNAME);
        return
    end
else
    if ~isfield(lcm.expt,'fid')
        fprintf('%s ->\nNo export FID found. Load data first.\n',FCTNAME);
        return
    end
end

%--- data assignment ---
if specNumber==1        % spectrum 1
    lcm.svd.fid    = conj(lcm.spec1.fid);
    lcm.svd.sf     = lcm.spec1.sf;
    lcm.svd.sw_h   = lcm.spec1.sw_h;
    lcm.svd.sw     = lcm.spec1.sw;
    lcm.svd.nspecC = lcm.spec1.nspecC;
    lcm.svd.tDwell = 1/lcm.spec1.sw_h;
    lcm.svd.tTotal = lcm.spec1.nspecC/lcm.spec1.sw_h;                            % total acquisition time
    lcm.svd.tVec   = 0:lcm.svd.tTotal/(lcm.spec1.nspecC-1):lcm.svd.tTotal;      % acqusition time vector
    lcm.svd.fVec   = (0:lcm.spec1.sw_h/(lcm.spec1.nspecC-1):lcm.spec1.sw_h)-lcm.spec1.sw_h/2;      % frequency vector
    lcm.svd.pVec   = lcm.svd.fVec/lcm.spec1.sf+lcm.ppmCalib;                    % frequency vector
elseif specNumber==2    % spectrum 2
    lcm.svd.fid    = conj(lcm.spec2.fid);
    lcm.svd.sf     = lcm.spec2.sf;
    lcm.svd.sw_h   = lcm.spec2.sw_h;
    lcm.svd.sw     = lcm.spec2.sw;
    lcm.svd.nspecC = lcm.spec2.nspecC;
    lcm.svd.tDwell = 1/lcm.spec2.sw_h;
    lcm.svd.tTotal = lcm.spec2.nspecC/lcm.spec2.sw_h;                            % total acquisition time
    lcm.svd.tVec   = 0:lcm.svd.tTotal/(lcm.spec2.nspecC-1):lcm.svd.tTotal;      % acqusition time vector
    lcm.svd.fVec   = (0:lcm.spec2.sw_h/(lcm.spec2.nspecC-1):lcm.spec2.sw_h)-lcm.spec2.sw_h/2;      % frequency vector
    lcm.svd.pVec   = lcm.svd.fVec/lcm.spec2.sf+lcm.ppmCalib;                    % frequency vector
elseif specNumber==3    % export spectrum
    lcm.expt.spec  = fftshift(fft(lcm.expt.fid,[],1),1);      % calculate since used throughout the processing
    lcm.svd.fid    = conj(lcm.expt.fid);
    lcm.svd.spec   = fftshift(fft(lcm.svd.fid'));
    lcm.svd.sf     = lcm.expt.sf;
    lcm.svd.sw_h   = lcm.expt.sw_h;
    lcm.svd.sw     = lcm.expt.sw;
    lcm.svd.nspecC = lcm.expt.nspecC;
    lcm.svd.tDwell = 1/lcm.expt.sw_h;
    lcm.svd.tTotal = lcm.expt.nspecC/lcm.expt.sw_h;                            % total acquisition time
    lcm.svd.tVec   = 0:lcm.svd.tTotal/(lcm.expt.nspecC-1):lcm.svd.tTotal;      % acqusition time vector
    lcm.svd.fVec   = (0:lcm.expt.sw_h/(lcm.expt.nspecC-1):lcm.expt.sw_h)-lcm.expt.sw_h/2;      % frequency vector
    lcm.svd.pVec   = lcm.svd.fVec/lcm.expt.sf+lcm.ppmCalib;                    % frequency vector
else                    % error 
    fprintf('%s ->\nData assignment failed. Program aborted.\n',FCTNAME);
    return
end
lcm.svd.specNumber = specNumber;           % for LSQ fitting function

%********************
%--- SVD analysis ---
%********************
%--- init SVD parameters ---
lMax = round(0.4*lcm.svd.nspecC);          % Hankel matrix, dimension 1 
mMax = lcm.svd.nspecC+1-lMax;              % Hankel matrix, dimension 2

%--- assign Hankel matrix ---
Hankel = zeros(lMax,mMax);
for m = 1:mMax
    for l = 1:lMax
      Hankel(m,l) = lcm.svd.fid(l+m-1);
   end
end

%--- singular value decomposition (SVD) ---
fprintf('SVD started...\n');
[U,S,V] = svd(Hankel);
fprintf('SVD completed...\n');

%--- derive truncated SVD matrix ---
Uup = zeros(lMax-1,lcm.baseSvdPeakN);
Udn = zeros(lMax-1,lcm.baseSvdPeakN);
Utr = permute(U(:,1:lcm.baseSvdPeakN)',[2 1]);
for l1 = 2:lMax
   for l2 = 1:lcm.baseSvdPeakN
      Uup(l1-1,l2) = Utr(l1,l2);
      Udn(l1-1,l2) = Utr(l1-1,l2);
   end
end

%--- calculation of eigenvalues ---
Z = ctranspose(Udn)*Uup;
[V,D] = eig(Z);
% note that this is a different V than in the SVD of the Hankel matrix

%--- calculation of frequencies and dampings ---
lcm.svd.frequAll = zeros(1,lcm.baseSvdPeakN);
lcm.svd.dampAll  = zeros(1,lcm.baseSvdPeakN);
for peakCnt = 1:lcm.baseSvdPeakN
   lcm.svd.frequAll(peakCnt) = (1/(2*pi*lcm.svd.tDwell))*atan2(imag(D(peakCnt,peakCnt)),real(D(peakCnt,peakCnt)));
   lcm.svd.dampAll(peakCnt)  = -lcm.svd.tDwell/(log(real(D(peakCnt,peakCnt))/cos(2*pi*lcm.svd.frequAll(peakCnt)*lcm.svd.tDwell)));
end

%--- info printout ---
fprintf('SVD frequencies:\n%sHz\n',SP2_Vec2PrintStr(lcm.svd.frequAll,0));
fprintf('%sppm\n',SP2_Vec2PrintStr(lcm.svd.frequAll/lcm.svd.sf+lcm.ppmCalib,2));
fprintf('SVD T2''s:\n%sms\n',SP2_Vec2PrintStr(lcm.svd.dampAll*1000));

%--- extraction of baseline parts to be fitted ---
lcm.svd.binVec = zeros(1,lcm.svd.nspecC);  % init global bin vector of ppm ranges to be used
lcm.svd.indVec = 0;                         % init global index vector of ppm ranges to be used
indCnt          = 0;                         % index counter (for global index vector)
minIndVec = zeros(1,lcm.baseSvdPpmN);           % init minimum ppm index vector for specific ppm windows
maxIndVec = zeros(1,lcm.baseSvdPpmN);           % init maximum ppm index vector for specific ppm windows
for winCnt = 1:lcm.baseSvdPpmN
    [minIndVec(winCnt),maxIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_LCM_ExtractPpmRange(lcm.baseSvdPpmMin(winCnt),lcm.baseSvdPpmMax(winCnt),...
                                 lcm.ppmCalib,lcm.svd.sw,lcm.svd.fid);
    % note that the FID (used here) by itself has no meaning
    lcm.svd.binVec(minIndVec(winCnt):maxIndVec(winCnt)) = 1;
    winLen = maxIndVec(winCnt)-minIndVec(winCnt)+1;         % individual window length
    lcm.svd.indVec(indCnt+1:indCnt+winLen) = minIndVec(winCnt):maxIndVec(winCnt);
    indCnt = length(lcm.svd.indVec);                       % update global index vector
end

%--- selection of valid frequencies ---
validCnt    = 0;            % valid entry counter
validIndVec = 0;            % vector containing the valid indices
for peakCnt = 1:lcm.baseSvdPeakN
    for winCnt = 1:lcm.baseSvdPpmN
        if lcm.svd.frequAll(peakCnt)>=lcm.svd.fVec(minIndVec(winCnt)) && ...
           lcm.svd.frequAll(peakCnt)<=lcm.svd.fVec(maxIndVec(winCnt))
            validCnt = validCnt + 1;
            validIndVec(validCnt) = peakCnt;
        end
    end
end

%---- sorting of frequencies and dampings ---
if validIndVec==0 
    %--- check whether valid peaks were found ---
    fprintf('%s ->\nNone of the SVD peaks falls in the assigned ppm window.\nProgram aborted.\n',FCTNAME);
    lcm.svd.nValid = 0;
    return
else
    %--- value extraction ---
    lcm.svd.frequ  = lcm.svd.frequAll(validIndVec);
    lcm.svd.damp   = lcm.svd.dampAll(validIndVec);
    lcm.svd.nValid = validCnt;
end

%--- info printout ---
fprintf('%.0f valid peaks:\nFrequencies:\n%sHz\n',lcm.svd.nValid,SP2_Vec2PrintStr(lcm.svd.frequ,0));
fprintf('%sppm\n',SP2_Vec2PrintStr(lcm.svd.frequ/lcm.svd.sf+lcm.ppmCalib,2));
fprintf('T2:\n%sms\n',SP2_Vec2PrintStr(lcm.svd.damp*1000));


%***********************************
%--- amplitude and phase fitting ---
%***********************************
%--- boundary init ---
opt   = [];
lb    = zeros(1,2*lcm.svd.nValid);                                     % amplitudes and phases
ub    = [1e7*ones(1,lcm.svd.nValid) 360*ones(1,lcm.svd.nValid)];      % amplitudes and phases
coeff = [100*ones(1,lcm.svd.nValid) 180*ones(1,lcm.svd.nValid)];      % basic init, will be adjusted below

%--- fit coefficient init ---
% phase and amplitude of spectral point closest to the determined SVD peak
% position
for peakCnt = 1:lcm.svd.nValid
    peakInd = round(SP2_BestApprox(lcm.svd.fVec,lcm.svd.frequ(peakCnt)));
    if specNumber==1
        coeff(peakCnt)                 = abs(lcm.spec1.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(lcm.svd.nValid+peakCnt) = angle(lcm.spec1.spec(peakInd))*180/pi;    % angle init
    elseif specNumber==2
        coeff(peakCnt)                 = abs(lcm.spec2.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(lcm.svd.nValid+peakCnt) = angle(lcm.spec2.spec(peakInd))*180/pi;    % angle init
    else
        coeff(peakCnt)                 = abs(lcm.expt.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(lcm.svd.nValid+peakCnt) = angle(lcm.expt.spec(peakInd))*180/pi;    % angle init
    end
end
fprintf('Coefficient init:\n');
fprintf('Amplitudes %s [a.u.]\n',SP2_Vec2PrintStr(coeff(1:lcm.svd.nValid),0));
fprintf('Phases %s [deg]\n',SP2_Vec2PrintStr(coeff(lcm.svd.nValid+1:end)));

%--- least-squares fit ---
[coeffFit,resnorm,resid,exitflag,output] = lsqcurvefit('SP2_LCM_SvdPhaseAndAmpFitFct',coeff,[],zeros(1,length(lcm.svd.indVec)),lb,ub,opt);
lcm.svd.amp   = coeffFit(1:lcm.svd.nValid);
lcm.svd.phase = coeffFit(lcm.svd.nValid+1:end);

%--- info printout ---
fprintf('Least-square fit of amplitudes and phases:\n');
fprintf('Amplitudes %s [a.u.]\n',SP2_Vec2PrintStr(lcm.svd.amp,0));
fprintf('Phases %s [deg]\n',SP2_Vec2PrintStr(lcm.svd.phase));

%--- resultant SVD FID creation and summation ---
lcm.svd.fid = zeros(1,lcm.svd.nspecC);
lcm.svd.fidPeak = zeros(lcm.svd.nValid,lcm.svd.nspecC);
for peakCnt = 1:lcm.svd.nValid
    lcm.svd.fidPeak(peakCnt,:) = coeffFit(peakCnt) * exp(-1i*coeffFit(lcm.svd.nValid+peakCnt)*pi/180) * ...
                                  exp(-2*pi*1i*lcm.svd.frequ(peakCnt)*lcm.svd.tVec) .* ...
                                  exp(-lcm.svd.tVec/lcm.svd.damp(peakCnt));
end

%--- SVD peak summation ---
if lcm.svd.nValid>1        % multiple peaks
    lcm.svd.fid = sum(lcm.svd.fidPeak)';
else                        % single peak
    lcm.svd.fid = lcm.svd.fidPeak';
end
lcm.svd.fidPeak  = lcm.svd.fidPeak';
lcm.svd.specPeak = fftshift(fft(lcm.svd.fidPeak));

%--- derive SVD spectrum and difference traces ---
lcm.svd.spec = fftshift(fft(lcm.svd.fid));
if specNumber==1
    lcm.svd.specDiff = lcm.spec1.spec-lcm.svd.spec;
elseif specNumber==2
    lcm.svd.specDiff = lcm.spec2.spec-lcm.svd.spec;
else
    lcm.svd.specDiff = lcm.expt.spec-lcm.svd.spec;
end
lcm.svd.fidDiff = ifft(ifftshift(lcm.svd.specDiff,1),[],1);

%--- result visualization ---
SP2_LCM_SvdResultVisualization

%--- update success flag ---
f_succ = 1;


