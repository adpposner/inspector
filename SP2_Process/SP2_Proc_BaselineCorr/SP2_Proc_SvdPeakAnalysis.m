%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_SvdPeakAnalysis( specNumber )
%%
%%  Hankel SVD-based water removal. Note that the Lanczos algorithm
%%  exploiting the symmetry of the Hankel form to focus on the strongest
%%  signals only (thereby reducing the computational load) has not been
%%  implemented yet, i.e. it's not used here.
%%  Literature: PijnappelWWF92a, DeBeerR92b
%%
%%  07-2012, Christop Juchem
%%
%%  Additional reference:
%%  H Barkhuijsen, R de Beer, D van Ormondt, JMR 73:553-557 (1987)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc

FCTNAME = 'SP2_Proc_SvdPeakAnalysis';


%--- init success flag ---
f_succ = 0;

%--- info printout ---
fprintf('%s started...\n',FCTNAME);

%--- check data existence ---
if specNumber==1
    if ~isfield(proc.spec1,'fid')
        fprintf('%s ->\nNo FID of spectral data set 1 found. Load data first.\n',FCTNAME);
        return
    end
elseif specNumber==2
    if ~isfield(proc.spec2,'fid')
        fprintf('%s ->\nNo FID of spectral data set 2 found. Load data first.\n',FCTNAME);
        return
    end
else
    if ~isfield(proc.expt,'fid')
        fprintf('%s ->\nNo export FID found. Load data first.\n',FCTNAME);
        return
    end
end

%--- data assignment ---
if specNumber==1        % spectrum 1
    proc.svd.fid    = conj(proc.spec1.fid);
    proc.svd.sf     = proc.spec1.sf;
    proc.svd.sw_h   = proc.spec1.sw_h;
    proc.svd.sw     = proc.spec1.sw;
    proc.svd.nspecC = proc.spec1.nspecC;
    proc.svd.tDwell = 1/proc.spec1.sw_h;
    proc.svd.tTotal = proc.spec1.nspecC/proc.spec1.sw_h;                            % total acquisition time
    proc.svd.tVec   = 0:proc.svd.tTotal/(proc.spec1.nspecC-1):proc.svd.tTotal;      % acqusition time vector
    proc.svd.fVec   = (0:proc.spec1.sw_h/(proc.spec1.nspecC-1):proc.spec1.sw_h)-proc.spec1.sw_h/2;      % frequency vector
    proc.svd.pVec   = proc.svd.fVec/proc.spec1.sf+proc.ppmCalib;                    % frequency vector
elseif specNumber==2    % spectrum 2
    proc.svd.fid    = conj(proc.spec2.fid);
    proc.svd.sf     = proc.spec2.sf;
    proc.svd.sw_h   = proc.spec2.sw_h;
    proc.svd.sw     = proc.spec2.sw;
    proc.svd.nspecC = proc.spec2.nspecC;
    proc.svd.tDwell = 1/proc.spec2.sw_h;
    proc.svd.tTotal = proc.spec2.nspecC/proc.spec2.sw_h;                            % total acquisition time
    proc.svd.tVec   = 0:proc.svd.tTotal/(proc.spec2.nspecC-1):proc.svd.tTotal;      % acqusition time vector
    proc.svd.fVec   = (0:proc.spec2.sw_h/(proc.spec2.nspecC-1):proc.spec2.sw_h)-proc.spec2.sw_h/2;      % frequency vector
    proc.svd.pVec   = proc.svd.fVec/proc.spec2.sf+proc.ppmCalib;                    % frequency vector
elseif specNumber==3    % export spectrum
    proc.expt.spec  = fftshift(fft(proc.expt.fid,[],1),1);      % calculate since used throughout the processing
    proc.svd.fid    = conj(proc.expt.fid);
    proc.svd.spec   = fftshift(fft(proc.svd.fid'));
    proc.svd.sf     = proc.expt.sf;
    proc.svd.sw_h   = proc.expt.sw_h;
    proc.svd.sw     = proc.expt.sw;
    proc.svd.nspecC = proc.expt.nspecC;
    proc.svd.tDwell = 1/proc.expt.sw_h;
    proc.svd.tTotal = proc.expt.nspecC/proc.expt.sw_h;                            % total acquisition time
    proc.svd.tVec   = 0:proc.svd.tTotal/(proc.expt.nspecC-1):proc.svd.tTotal;      % acqusition time vector
    proc.svd.fVec   = (0:proc.expt.sw_h/(proc.expt.nspecC-1):proc.expt.sw_h)-proc.expt.sw_h/2;      % frequency vector
    proc.svd.pVec   = proc.svd.fVec/proc.expt.sf+proc.ppmCalib;                    % frequency vector
else                    % error 
    fprintf('%s ->\nData assignment failed. Program aborted.\n',FCTNAME);
    return
end
proc.svd.specNumber = specNumber;           % for LSQ fitting function

%********************
%--- SVD analysis ---
%********************
%--- init SVD parameters ---
lMax = round(0.4*proc.svd.nspecC);          % Hankel matrix, dimension 1 
mMax = proc.svd.nspecC+1-lMax;              % Hankel matrix, dimension 2

%--- assign Hankel matrix ---
Hankel = zeros(lMax,mMax);
for m = 1:mMax
    for l = 1:lMax
      Hankel(m,l) = proc.svd.fid(l+m-1);
   end
end

%--- singular value decomposition (SVD) ---
fprintf('SVD started...\n');
[U,S,V] = svd(Hankel);
% S: matrix containing singular values
fprintf('SVD completed...\n');

%--- derive truncated SVD matrix ---
Uup = zeros(lMax-1,proc.baseSvdPeakN);
Udn = zeros(lMax-1,proc.baseSvdPeakN);
Utr = permute(U(:,1:proc.baseSvdPeakN)',[2 1]);
for l1 = 2:lMax
   for l2 = 1:proc.baseSvdPeakN
      Uup(l1-1,l2) = Utr(l1,l2);
      Udn(l1-1,l2) = Utr(l1-1,l2);
   end
end

%--- calculation of eigenvalues ---
Z = ctranspose(Udn)*Uup;
[V,D] = eig(Z);
% note that this is a different V than in the SVD of the Hankel matrix

%--- calculation of frequencies and dampings ---
proc.svd.frequAll = zeros(1,proc.baseSvdPeakN);
proc.svd.dampAll  = zeros(1,proc.baseSvdPeakN);
for peakCnt = 1:proc.baseSvdPeakN
   proc.svd.frequAll(peakCnt) = (1/(2*pi*proc.svd.tDwell))*atan2(imag(D(peakCnt,peakCnt)),real(D(peakCnt,peakCnt)));
   proc.svd.dampAll(peakCnt)  = -proc.svd.tDwell/(log(real(D(peakCnt,peakCnt))/cos(2*pi*proc.svd.frequAll(peakCnt)*proc.svd.tDwell)));
   % abs() instead of real()?!
   % proc.svd.dampAll(peakCnt)  = -proc.svd.tDwell/(log(abs(D(peakCnt,peakCnt))/cos(2*pi*proc.svd.frequAll(peakCnt)*proc.svd.tDwell)));
end

%--- info printout ---
fprintf('SVD frequencies:\n%sHz\n',SP2_Vec2PrintStr(proc.svd.frequAll,0));
fprintf('%sppm\n',SP2_Vec2PrintStr(proc.svd.frequAll/proc.svd.sf+proc.ppmCalib,2));
fprintf('SVD T2''s:\n%sms\n',SP2_Vec2PrintStr(proc.svd.dampAll*1000));

%--- extraction of baseline parts to be fitted ---
proc.svd.binVec = zeros(1,proc.svd.nspecC);  % init global bin vector of ppm ranges to be used
proc.svd.indVec = 0;                         % init global index vector of ppm ranges to be used
indCnt          = 0;                         % index counter (for global index vector)
minIndVec = zeros(1,proc.baseSvdPpmN);           % init minimum ppm index vector for specific ppm windows
maxIndVec = zeros(1,proc.baseSvdPpmN);           % init maximum ppm index vector for specific ppm windows
for winCnt = 1:proc.baseSvdPpmN
    [minIndVec(winCnt),maxIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(proc.baseSvdPpmMin(winCnt),proc.baseSvdPpmMax(winCnt),...
                                 proc.ppmCalib,proc.svd.sw,proc.svd.fid);
    if ~f_done
        fprintf('\n%s ->\nFrequency window extraction failed for section #2 (%.2f-%.2f ppm). Program aborted.\n',...
                winCnt,proc.baseSvdPpmMin(winCnt),proc.baseSvdPpmMax(winCnt))
        return
    end   
                             
    % note that the FID (used here) by itself has no meaning
    proc.svd.binVec(minIndVec(winCnt):maxIndVec(winCnt)) = 1;
    winLen = maxIndVec(winCnt)-minIndVec(winCnt)+1;         % individual window length
    proc.svd.indVec(indCnt+1:indCnt+winLen) = minIndVec(winCnt):maxIndVec(winCnt);
    indCnt = length(proc.svd.indVec);                       % update global index vector
end

%--- selection of valid frequencies ---
validCnt    = 0;            % valid entry counter
validIndVec = 0;            % vector containing the valid indices
for peakCnt = 1:proc.baseSvdPeakN
    for winCnt = 1:proc.baseSvdPpmN
        if proc.svd.frequAll(peakCnt)>=proc.svd.fVec(minIndVec(winCnt)) && ...
           proc.svd.frequAll(peakCnt)<=proc.svd.fVec(maxIndVec(winCnt))
            validCnt = validCnt + 1;
            validIndVec(validCnt) = peakCnt;
        end
    end
end

%---- sorting of frequencies and dampings ---
if validIndVec==0 
    %--- check whether valid peaks were found ---
    fprintf('%s ->\nNone of the SVD peaks falls in the assigned ppm window.\nProgram aborted.\n',FCTNAME);
    proc.svd.nValid = 0;
    return
else
    %--- value extraction ---
    proc.svd.frequ  = proc.svd.frequAll(validIndVec);
    proc.svd.damp   = proc.svd.dampAll(validIndVec);
    proc.svd.nValid = validCnt;
end

%--- info printout ---
fprintf('%.0f valid peaks:\nFrequencies:\n%sHz\n',proc.svd.nValid,SP2_Vec2PrintStr(proc.svd.frequ,0));
fprintf('%sppm\n',SP2_Vec2PrintStr(proc.svd.frequ/proc.svd.sf+proc.ppmCalib,2));
fprintf('T2:\n%sms\n',SP2_Vec2PrintStr(proc.svd.damp*1000));


%***********************************
%--- amplitude and phase fitting ---
%***********************************
%--- boundary init ---
opt   = [];
lb    = zeros(1,2*proc.svd.nValid);                                     % amplitudes and phases
ub    = [1e7*ones(1,proc.svd.nValid) 360*ones(1,proc.svd.nValid)];      % amplitudes and phases
coeff = [100*ones(1,proc.svd.nValid) 180*ones(1,proc.svd.nValid)];      % basic init, will be adjusted below

%--- fit coefficient init ---
% phase and amplitude of spectral point closest to the determined SVD peak position
for peakCnt = 1:proc.svd.nValid
    peakInd = round(SP2_BestApprox(proc.svd.fVec,proc.svd.frequ(peakCnt)));
    if specNumber==1
        coeff(peakCnt)                 = abs(proc.spec1.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(proc.svd.nValid+peakCnt) = angle(proc.spec1.spec(peakInd))*180/pi;    % angle init
    elseif specNumber==2
        coeff(peakCnt)                 = abs(proc.spec2.spec(peakInd))/10;          % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(proc.svd.nValid+peakCnt) = angle(proc.spec2.spec(peakInd))*180/pi;    % angle init
    else
        coeff(peakCnt)                 = abs(proc.expt.spec(peakInd))/10;           % amplitude init, 100 random (accounting for spec vs. FID)
        coeff(proc.svd.nValid+peakCnt) = angle(proc.expt.spec(peakInd))*180/pi;     % angle init
    end
end
fprintf('Coefficient init:\n');
fprintf('Amplitudes %s [a.u.]\n',SP2_Vec2PrintStr(coeff(1:proc.svd.nValid),0));
fprintf('Phases %s [deg]\n',SP2_Vec2PrintStr(coeff(proc.svd.nValid+1:end)));

%--- least-squares fit ---
[coeffFit,resnorm,resid,exitflag,output] = lsqcurvefit('SP2_Proc_SvdPhaseAndAmpFitFct',coeff,[],zeros(1,length(proc.svd.indVec)),lb,ub,opt);
proc.svd.amp   = coeffFit(1:proc.svd.nValid);
proc.svd.phase = coeffFit(proc.svd.nValid+1:end);

%--- info printout ---
fprintf('Least-square fit of amplitudes and phases:\n');
fprintf('Amplitudes %s [a.u.]\n',SP2_Vec2PrintStr(proc.svd.amp,0));
fprintf('Phases %s [deg]\n',SP2_Vec2PrintStr(proc.svd.phase));

%--- resultant SVD FID creation and summation ---
proc.svd.fid = zeros(1,proc.svd.nspecC);
proc.svd.fidPeak = zeros(proc.svd.nValid,proc.svd.nspecC);
for peakCnt = 1:proc.svd.nValid
    proc.svd.fidPeak(peakCnt,:) = coeffFit(peakCnt) * exp(-1i*coeffFit(proc.svd.nValid+peakCnt)*pi/180) * ...
                                  exp(-2*pi*1i*proc.svd.frequ(peakCnt)*proc.svd.tVec) .* ...
                                  exp(-proc.svd.tVec/proc.svd.damp(peakCnt));
end

%--- SVD peak summation ---
if proc.svd.nValid>1        % multiple peaks
    proc.svd.fid = sum(proc.svd.fidPeak)';
else                        % single peak
    proc.svd.fid = proc.svd.fidPeak';
end
proc.svd.fidPeak  = proc.svd.fidPeak';
proc.svd.specPeak = fftshift(fft(proc.svd.fidPeak));

%--- derive SVD spectrum and difference traces ---
proc.svd.spec = fftshift(fft(proc.svd.fid));
if specNumber==1
    proc.svd.specDiff = proc.spec1.spec-proc.svd.spec;
elseif specNumber==2
    proc.svd.specDiff = proc.spec2.spec-proc.svd.spec;
else
    proc.svd.specDiff = proc.expt.spec-proc.svd.spec;
end
proc.svd.fidDiff = ifft(ifftshift(proc.svd.specDiff,1),[],1);

%--- result visualization ---
SP2_Proc_SvdResultVisualization

%--- update success flag ---
f_succ = 1;


