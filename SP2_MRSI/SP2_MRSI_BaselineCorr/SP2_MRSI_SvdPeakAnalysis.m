%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MRSI_SvdPeakAnalysis( specNumber )
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

global mrsi

FCTNAME = 'SP2_MRSI_SvdPeakAnalysis';


%--- init success flag ---
f_succ = 0;

%--- info printout ---
fprintf('%s started...\n',FCTNAME)

%--- check data existence ---
if specNumber==1
    if ~isfield(mrsi.spec1,'fid')
        fprintf('%s ->\nNo FID of spectral data set 1 found. Load data first.\n',FCTNAME)
        return
    end
elseif specNumber==2
    if ~isfield(mrsi.spec2,'fid')
        fprintf('%s ->\nNo FID of spectral data set 2 found. Load data first.\n',FCTNAME)
        return
    end
else
    if ~isfield(mrsi.expt,'fid')
        fprintf('%s ->\nNo export FID found. Load data first.\n',FCTNAME)
        return
    end
end

%--- data assignment ---
if specNumber==1        % spectrum 1
    mrsi.svd.fid    = conj(mrsi.spec1.fid);
    mrsi.svd.sf     = mrsi.spec1.sf;
    mrsi.svd.sw_h   = mrsi.spec1.sw_h;
    mrsi.svd.sw     = mrsi.spec1.sw;
    mrsi.svd.nspecC = mrsi.spec1.nspecC;
    mrsi.svd.tDwell = 1/mrsi.spec1.sw_h;
    mrsi.svd.tTotal = mrsi.spec1.nspecC/mrsi.spec1.sw_h;                            % total acquisition time
    mrsi.svd.tVec   = 0:mrsi.svd.tTotal/(mrsi.spec1.nspecC-1):mrsi.svd.tTotal;      % acqusition time vector
    mrsi.svd.fVec   = (0:mrsi.spec1.sw_h/(mrsi.spec1.nspecC-1):mrsi.spec1.sw_h)-mrsi.spec1.sw_h/2;      % frequency vector
    mrsi.svd.pVec   = mrsi.svd.fVec/mrsi.spec1.sf+mrsi.ppmCalib;                    % frequency vector
elseif specNumber==2    % spectrum 2
    mrsi.svd.fid    = conj(mrsi.spec2.fid);
    mrsi.svd.sf     = mrsi.spec2.sf;
    mrsi.svd.sw_h   = mrsi.spec2.sw_h;
    mrsi.svd.sw     = mrsi.spec2.sw;
    mrsi.svd.nspecC = mrsi.spec2.nspecC;
    mrsi.svd.tDwell = 1/mrsi.spec2.sw_h;
    mrsi.svd.tTotal = mrsi.spec2.nspecC/mrsi.spec2.sw_h;                            % total acquisition time
    mrsi.svd.tVec   = 0:mrsi.svd.tTotal/(mrsi.spec2.nspecC-1):mrsi.svd.tTotal;      % acqusition time vector
    mrsi.svd.fVec   = (0:mrsi.spec2.sw_h/(mrsi.spec2.nspecC-1):mrsi.spec2.sw_h)-mrsi.spec2.sw_h/2;      % frequency vector
    mrsi.svd.pVec   = mrsi.svd.fVec/mrsi.spec2.sf+mrsi.ppmCalib;                    % frequency vector
elseif specNumber==3    % export spectrum
    mrsi.expt.spec  = fftshift(fft(mrsi.expt.fid,[],1),1);      % calculate since used throughout the processing
    mrsi.svd.fid    = conj(mrsi.expt.fid);
    mrsi.svd.spec   = fftshift(fft(mrsi.svd.fid'));
    mrsi.svd.sf     = mrsi.expt.sf;
    mrsi.svd.sw_h   = mrsi.expt.sw_h;
    mrsi.svd.sw     = mrsi.expt.sw;
    mrsi.svd.nspecC = mrsi.expt.nspecC;
    mrsi.svd.tDwell = 1/mrsi.expt.sw_h;
    mrsi.svd.tTotal = mrsi.expt.nspecC/mrsi.expt.sw_h;                            % total acquisition time
    mrsi.svd.tVec   = 0:mrsi.svd.tTotal/(mrsi.expt.nspecC-1):mrsi.svd.tTotal;      % acqusition time vector
    mrsi.svd.fVec   = (0:mrsi.expt.sw_h/(mrsi.expt.nspecC-1):mrsi.expt.sw_h)-mrsi.expt.sw_h/2;      % frequency vector
    mrsi.svd.pVec   = mrsi.svd.fVec/mrsi.expt.sf+mrsi.ppmCalib;                    % frequency vector
else                    % error 
    fprintf('%s ->\nData assignment failed. Program aborted.\n',FCTNAME)
    return
end
mrsi.svd.specNumber = specNumber;           % for LSQ fitting function

%********************
%--- SVD analysis ---
%********************
%--- init SVD parameters ---
lMax = round(0.4*mrsi.svd.nspecC);          % Hankel matrix, dimension 1 
mMax = mrsi.svd.nspecC+1-lMax;              % Hankel matrix, dimension 2

%--- assign Hankel matrix ---
Hankel = zeros(lMax,mMax);
for m = 1:mMax
    for l = 1:lMax
      Hankel(m,l) = mrsi.svd.fid(l+m-1);
   end
end

%--- singular value decomposition (SVD) ---
fprintf('SVD started...\n')
[U,S,V] = svd(Hankel);
fprintf('SVD completed...\n')

%--- derive truncated SVD matrix ---
Uup = zeros(lMax-1,mrsi.baseSvdPeakN);
Udn = zeros(lMax-1,mrsi.baseSvdPeakN);
Utr = permute(U(:,1:mrsi.baseSvdPeakN)',[2 1]);
for l1 = 2:lMax
   for l2 = 1:mrsi.baseSvdPeakN
      Uup(l1-1,l2) = Utr(l1,l2);
      Udn(l1-1,l2) = Utr(l1-1,l2);
   end
end

%--- calculation of eigenvalues ---
Z = ctranspose(Udn)*Uup;
[V,D] = eig(Z);
% note that this is a different V than in the SVD of the Hankel matrix

%--- calculation of frequencies and dampings ---
mrsi.svd.frequAll = zeros(1,mrsi.baseSvdPeakN);
mrsi.svd.dampAll  = zeros(1,mrsi.baseSvdPeakN);
for peakCnt = 1:mrsi.baseSvdPeakN
   mrsi.svd.frequAll(peakCnt) = (1/(2*pi*mrsi.svd.tDwell))*atan2(imag(D(peakCnt,peakCnt)),real(D(peakCnt,peakCnt)));
   mrsi.svd.dampAll(peakCnt)  = -mrsi.svd.tDwell/(log(real(D(peakCnt,peakCnt))/cos(2*pi*mrsi.svd.frequAll(peakCnt)*mrsi.svd.tDwell)));
end

%--- info printout ---
fprintf('SVD frequencies:\n%sHz\n',SP2_Vec2PrintStr(mrsi.svd.frequAll,0))
fprintf('%sppm\n',SP2_Vec2PrintStr(mrsi.svd.frequAll/mrsi.svd.sf+mrsi.ppmCalib,2))
fprintf('SVD T2''s:\n%sms\n',SP2_Vec2PrintStr(mrsi.svd.dampAll*1000))

%--- extraction of baseline parts to be fitted ---
mrsi.svd.binVec = zeros(1,mrsi.svd.nspecC);  % init global bin vector of ppm ranges to be used
mrsi.svd.indVec = 0;                         % init global index vector of ppm ranges to be used
indCnt          = 0;                         % index counter (for global index vector)
minIndVec = zeros(1,mrsi.baseSvdPpmN);           % init minimum ppm index vector for specific ppm windows
maxIndVec = zeros(1,mrsi.baseSvdPpmN);           % init maximum ppm index vector for specific ppm windows
for winCnt = 1:mrsi.baseSvdPpmN
    [minIndVec(winCnt),maxIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_MRSI_ExtractPpmRange(mrsi.baseSvdPpmMin(winCnt),mrsi.baseSvdPpmMax(winCnt),...
                                 mrsi.ppmCalib,mrsi.svd.sw,mrsi.svd.fid);
    % note that the FID (used here) by itself has no meaning
    mrsi.svd.binVec(minIndVec(winCnt):maxIndVec(winCnt)) = 1;
    winLen = maxIndVec(winCnt)-minIndVec(winCnt)+1;         % individual window length
    mrsi.svd.indVec(indCnt+1:indCnt+winLen) = minIndVec(winCnt):maxIndVec(winCnt);
    indCnt = length(mrsi.svd.indVec);                       % update global index vector
end

%--- selection of valid frequencies ---
validCnt    = 0;            % valid entry counter
validIndVec = 0;            % vector containing the valid indices
for peakCnt = 1:mrsi.baseSvdPeakN
    for winCnt = 1:mrsi.baseSvdPpmN
        if mrsi.svd.frequAll(peakCnt)>=mrsi.svd.fVec(minIndVec(winCnt)) && ...
           mrsi.svd.frequAll(peakCnt)<=mrsi.svd.fVec(maxIndVec(winCnt))
            validCnt = validCnt + 1;
            validIndVec(validCnt) = peakCnt;
        end
    end
end

%---- sorting of frequencies and dampings ---
if validIndVec==0 
    %--- check whether valid peaks were found ---
    fprintf('%s ->\nNone of the SVD peaks falls in the assigned ppm window.\nProgram aborted.\n',FCTNAME)
    mrsi.svd.nValid = 0;
    return
else
    %--- value extraction ---
    mrsi.svd.frequ  = mrsi.svd.frequAll(validIndVec);
    mrsi.svd.damp   = mrsi.svd.dampAll(validIndVec);
    mrsi.svd.nValid = validCnt;
end

%--- info printout ---
fprintf('%.0f valid peaks:\nFrequencies:\n%sHz\n',mrsi.svd.nValid,SP2_Vec2PrintStr(mrsi.svd.frequ,0))
fprintf('%sppm\n',SP2_Vec2PrintStr(mrsi.svd.frequ/mrsi.svd.sf+mrsi.ppmCalib,2))
fprintf('T2:\n%sms\n',SP2_Vec2PrintStr(mrsi.svd.damp*1000))


%***********************************
%--- amplitude and phase fitting ---
%***********************************
%--- boundary init ---
opt   = [];
lb    = zeros(1,2*mrsi.svd.nValid);                                     % amplitudes and phases
ub    = [1e7*ones(1,mrsi.svd.nValid) 360*ones(1,mrsi.svd.nValid)];      % amplitudes and phases
coeff = [100*ones(1,mrsi.svd.nValid) 180*ones(1,mrsi.svd.nValid)];      % basic init, will be adjusted below

%--- fit coefficient init ---
% phase and amplitude of spectral point closest to the determined SVD peak
% position
for peakCnt = 1:mrsi.svd.nValid
    peakInd = round(SP2_BestApprox(mrsi.svd.fVec,mrsi.svd.frequ(peakCnt)));
    if specNumber==1
        coeff(peakCnt)                 = abs(mrsi.spec1.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(mrsi.svd.nValid+peakCnt) = angle(mrsi.spec1.spec(peakInd))*180/pi;    % angle init
    elseif specNumber==2
        coeff(peakCnt)                 = abs(mrsi.spec2.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(mrsi.svd.nValid+peakCnt) = angle(mrsi.spec2.spec(peakInd))*180/pi;    % angle init
    else
        coeff(peakCnt)                 = abs(mrsi.expt.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(mrsi.svd.nValid+peakCnt) = angle(mrsi.expt.spec(peakInd))*180/pi;    % angle init
    end
end
fprintf('Coefficient init:\n')
fprintf('Amplitudes %s [a.u.]\n',SP2_Vec2PrintStr(coeff(1:mrsi.svd.nValid),0))
fprintf('Phases %s [deg]\n',SP2_Vec2PrintStr(coeff(mrsi.svd.nValid+1:end)))

%--- least-squares fit ---
[coeffFit,resnorm,resid,exitflag,output] = lsqcurvefit('SP2_MRSI_SvdPhaseAndAmpFitFct',coeff,[],zeros(1,length(mrsi.svd.indVec)),lb,ub,opt);
mrsi.svd.amp   = coeffFit(1:mrsi.svd.nValid);
mrsi.svd.phase = coeffFit(mrsi.svd.nValid+1:end);

%--- info printout ---
fprintf('Least-square fit of amplitudes and phases:\n')
fprintf('Amplitudes %s [a.u.]\n',SP2_Vec2PrintStr(mrsi.svd.amp,0))
fprintf('Phases %s [deg]\n',SP2_Vec2PrintStr(mrsi.svd.phase))

%--- resultant SVD FID creation and summation ---
mrsi.svd.fid = zeros(1,mrsi.svd.nspecC);
mrsi.svd.fidPeak = zeros(mrsi.svd.nValid,mrsi.svd.nspecC);
for peakCnt = 1:mrsi.svd.nValid
    mrsi.svd.fidPeak(peakCnt,:) = coeffFit(peakCnt) * exp(-1i*coeffFit(mrsi.svd.nValid+peakCnt)*pi/180) * ...
                                  exp(-2*pi*1i*mrsi.svd.frequ(peakCnt)*mrsi.svd.tVec) .* ...
                                  exp(-mrsi.svd.tVec/mrsi.svd.damp(peakCnt));
end

%--- SVD peak summation ---
if mrsi.svd.nValid>1        % multiple peaks
    mrsi.svd.fid = sum(mrsi.svd.fidPeak)';
else                        % single peak
    mrsi.svd.fid = mrsi.svd.fidPeak';
end
mrsi.svd.fidPeak  = mrsi.svd.fidPeak';
mrsi.svd.specPeak = fftshift(fft(mrsi.svd.fidPeak));

%--- derive SVD spectrum and difference traces ---
mrsi.svd.spec = fftshift(fft(mrsi.svd.fid));
if specNumber==1
    mrsi.svd.specDiff = mrsi.spec1.spec-mrsi.svd.spec;
elseif specNumber==2
    mrsi.svd.specDiff = mrsi.spec2.spec-mrsi.svd.spec;
else
    mrsi.svd.specDiff = mrsi.expt.spec-mrsi.svd.spec;
end
mrsi.svd.fidDiff = ifft(ifftshift(mrsi.svd.specDiff,1),[],1);

%--- result visualization ---
SP2_MRSI_SvdResultVisualization

%--- update success flag ---
f_succ = 1;


