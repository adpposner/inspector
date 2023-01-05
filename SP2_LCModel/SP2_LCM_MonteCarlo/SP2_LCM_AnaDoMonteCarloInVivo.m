%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaDoMonteCarloInVivo(varargin)
%% 
%%  Serial (batch) LCModel analysis of in vivo brain spectrum
%%  replicating the noise level of theo original experiment.
%%
%%  Note 1: The noise power remains unchanged, but it is re-created for 
%%          every LCModel analysis, i.e. it is analysis-specific.
%%  Note 2: All SPX parameter need to be set properly, especially the
%%          brain spectrum synthesis, the LCModel basis file and the
%%          corresponding metabolite selection for LCM
%%  
%%  The purpose of this script is to obtain an error/confidence estimate
%%  of the metabolite quantification.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm flag

FCTNAME = 'SP2_LCM_AnaDoMonteCarloInVivo';


%--- init success flag ---
f_succ = 0;

%--- parameter selection ---
f_lb    = flag.lcmAnaLb;        % show LB fitting result
f_gb    = flag.lcmAnaGb;        % show GB fitting result
f_shift = flag.lcmAnaShift;     % show shift fitting result
f_phc0  = flag.lcmAnaPhc0;      % show PHC0 fitting result


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     P R O G R A M     S T A R T                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %--- keep flag settings and adopt for MC analysis ---
% flagSimNoiseKeep  = flag.simNoiseKeep;
% flag.simNoiseKeep = 0;          % new calculation

%--- start clock ---
tStart = tic;       % start clock

%--- keep parameters ---
if ~flag.lcmMCarloInit                          % no parameter init, i.e. reset before every analysis
    flagLcmAnaScale  = flag.lcmAnaScale;      
    flag.lcmAnaScale = 1;                       % include amplitude scaling in reset
end

%--- result directory handling ---
narg = nargin;
if narg==1          % direct assignment of directory name (through master script)
    resultDir = [lcm.expt.dataDir SP2_Check4StrR(varargin{1}) '\'];
else                % default directory
    resultDir = [lcm.expt.dataDir 'SPX_LcmMonteCarlo\'];
end
% if SP2_CheckDirAccessR(resultDir)
%     [f_done,msg,msgId] = rmdir(resultDir);
%     if f_done
%         fprintf('Directory <%s> deleted.\n',resultDir);
%     else
%         fprintf('Directory deletion failed. Program aborted.\n%s\n\n',msg);
%         return
%     end
% end
if ~SP2_CheckDirAccessR(resultDir)
    [f_done,msg,msgId] = mkdir(resultDir);
    if f_done
        fprintf('Directory <%s> created.\n',resultDir);
    else
        fprintf('Directory creation failed. Program aborted.\n%s\n\n',msg);
        return
    end
end

%--- check for flag consistency ---
if flag.lcmMCarloCont && ~isfield(lcm.mc,'concMat')
    fprintf('\nWARNING:\nMC continuation flag selected, but no previous MC analysis found.\nDeselect flag and run MC simulation.\n\n');
    return
end

%--- init / extend statistics parameters ---
if flag.lcmMCarloCont               % extend statistics parameters
    lcm.mc.nPrev         = size(lcm.mc.concMat,1);
    lcm.mc.concMat       = [lcm.mc.concMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];                % concentration matrix
    lcm.mc.concCrlbMat   = [lcm.mc.concCrlbMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];            % corresponding CRLB matrix
    lcm.mc.concSdTrace   = [lcm.mc.concSdTrace; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];            % SD development over the course of # of iterations
    lcm.mc.noiseIterReal = [lcm.mc.noiseIterReal zeros(1,lcm.mc.n)];                          % SD development over the course of # of iterations
    lcm.mc.noiseIterImag = [lcm.mc.noiseIterImag zeros(1,lcm.mc.n)];                          % SD development over the course of # of iterations
    if f_lb
        if flag.lcmLinkLb
            lcm.mc.lbVec     = [lcm.mc.lbVec; zeros(lcm.mc.n,1)];                             % concentration matrix
            lcm.mc.lbCrlbVec = [lcm.mc.lbCrlbVec; zeros(lcm.mc.n,1)];                         % corresponding CRLB matrix
            lcm.mc.lbSdTrace = [lcm.mc.lbSdTrace; zeros(lcm.mc.n,1)];                         % SD development over the course of # of iterations
        else
            lcm.mc.lbMat     = [lcm.mc.lbMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];              % concentration matrix
            lcm.mc.lbCrlbMat = [lcm.mc.lbCrlbMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];          % corresponding CRLB matrix
            lcm.mc.lbSdTrace = [lcm.mc.lbSdTrace; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];          % SD development over the course of # of iterations
        end
    end
    if f_gb
        if flag.lcmLinkGb
            lcm.mc.gbVec     = [lcm.mc.gbVec; zeros(lcm.mc.n,1)];                             % concentration matrix
            lcm.mc.gbCrlbVec = [lcm.mc.gbCrlbVec; zeros(lcm.mc.n,1)];                         % corresponding CRLB matrix
            lcm.mc.gbSdTrace = [lcm.mc.gbSdTrace; zeros(lcm.mc.n,1)];                         % SD development over the course of # of iterations
        else
            lcm.mc.gbMat     = [lcm.mc.gbMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];              % concentration matrix
            lcm.mc.gbCrlbMat = [lcm.mc.gbCrlbMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];          % corresponding CRLB matrix
            lcm.mc.gbSdTrace = [lcm.mc.gbSdTrace; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];          % SD development over the course of # of iterations
        end
    end
    if f_shift
        if flag.lcmLinkShift
            lcm.mc.shiftVec     = [lcm.mc.shiftVec; zeros(lcm.mc.n,1)];                       % concentration matrix
            lcm.mc.shiftCrlbVec = [lcm.mc.shiftCrlbVec; zeros(lcm.mc.n,1)];                   % corresponding CRLB matrix
            lcm.mc.shiftSdTrace = [lcm.mc.shiftSdTrace; zeros(lcm.mc.n,1)];                   % SD development over the course of # of iterations
        else
            lcm.mc.shiftMat     = [lcm.mc.shiftMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];        % concentration matrix
            lcm.mc.shiftCrlbMat = [lcm.mc.shiftCrlbMat; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];    % corresponding CRLB matrix
            lcm.mc.shiftSdTrace = [lcm.mc.shiftSdTrace; zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN)];    % SD development over the course of # of iterations
        end
    end
    if f_phc0
        lcm.mc.phc0Vec     = [lcm.mc.phc0Vec; zeros(lcm.mc.n,1)];                             % concentration matrix
        lcm.mc.phc0CrlbVec = [lcm.mc.phc0CrlbVec; zeros(lcm.mc.n,1)];                         % corresponding CRLB matrix
        lcm.mc.phc0SdTrace = [lcm.mc.phc0SdTrace; zeros(lcm.mc.n,1)];                         % SD development over the course of # of iterations
    end
else                                % create statistics parameters
    lcm.mc.nPrev         = 0;                                             % no previous runs
    lcm.mc.concMat       = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);              % concentration matrix
    lcm.mc.concCrlbMat   = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);              % corresponding CRLB matrix
    lcm.mc.concSdTrace   = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);              % SD development over the course of # of iterations
    lcm.mc.noiseIterReal = zeros(1,lcm.mc.n);                             % SD development over the course of # of iterations
    lcm.mc.noiseIterImag = zeros(1,lcm.mc.n);                             % SD development over the course of # of iterations
    if f_lb
        if flag.lcmLinkLb
            lcm.mc.lbVec     = zeros(lcm.mc.n,1);                         % concentration matrix
            lcm.mc.lbCrlbVec = zeros(lcm.mc.n,1);                         % corresponding CRLB matrix
            lcm.mc.lbSdTrace = zeros(lcm.mc.n,1);                         % SD development over the course of # of iterations
        else
            lcm.mc.lbMat     = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);          % concentration matrix
            lcm.mc.lbCrlbMat = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);          % corresponding CRLB matrix
            lcm.mc.lbSdTrace = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);          % SD development over the course of # of iterations
        end
    end
    if f_gb
        if flag.lcmLinkGb
            lcm.mc.gbVec     = zeros(lcm.mc.n,1);                         % concentration matrix
            lcm.mc.gbCrlbVec = zeros(lcm.mc.n,1);                         % corresponding CRLB matrix
            lcm.mc.gbSdTrace = zeros(lcm.mc.n,1);                         % SD development over the course of # of iterations
        else
            lcm.mc.gbMat     = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);          % concentration matrix
            lcm.mc.gbCrlbMat = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);          % corresponding CRLB matrix
            lcm.mc.gbSdTrace = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);          % SD development over the course of # of iterations
        end
    end
    if f_shift
        if flag.lcmLinkShift
            lcm.mc.shiftVec     = zeros(lcm.mc.n,1);                      % concentration matrix
            lcm.mc.shiftCrlbVec = zeros(lcm.mc.n,1);                      % corresponding CRLB matrix
            lcm.mc.shiftSdTrace = zeros(lcm.mc.n,1);                      % SD development over the course of # of iterations
        else
            lcm.mc.shiftMat     = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);       % concentration matrix
            lcm.mc.shiftCrlbMat = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);       % corresponding CRLB matrix
            lcm.mc.shiftSdTrace = zeros(lcm.mc.n,lcm.fit.appliedN+lcm.combN);       % SD development over the course of # of iterations
        end
    end
    if f_phc0
        lcm.mc.phc0Vec     = zeros(lcm.mc.n,1);                           % concentration matrix
        lcm.mc.phc0CrlbVec = zeros(lcm.mc.n,1);                           % corresponding CRLB matrix
        lcm.mc.phc0SdTrace = zeros(lcm.mc.n,1);                           % SD development over the course of # of iterations
    end
end

%--- perform reference LCM analysis ---
if flag.lcmMCarloCont               % continue earlier analysis
    %--- check existence of previous LCM analysis ---
    if ~isfield(lcm.fit,'resid')
        fprintf('No LCModel analysis found. Performed first.\n');
        return
    end
    
    %--- check existence of previous Monte-Carlo analysis ---
    if ~isfield(lcm.mc,'fid')
        fprintf('No Monte-Carlo analysis found. Performed first.\n');
        return
    end
else                                    % new analysis
    if flag.lcmMCarloData    
        if flag.lcmMCarloRef            % perform reference LCM analysis
            %--- enable processing/updating of target spectrum ---
            flag.lcmMCarloRunning = 0;

            %--- perform reference analysis ---
            if ~SP2_LCM_AnaDoAnalysis(0)
                fprintf('%s ->\nLCModel analysis failed. Program aborted.\n\n',FCTNAME);
                return
            end

            %--- copy and rename log file ---
            if flag.lcmSaveLog
                if SP2_CheckFileExistenceR(lcm.logPath)
                    mcLogPath = sprintf('%sSPX_LcmAnalysis_Ref.log',resultDir);
                    [f_done,msg,msgId] = copyfile(lcm.logPath,mcLogPath);
                    if ~f_done
                        fprintf('\nCopying <%s>\nto <%s> failed.\nProgram aborted.\n%s\n\n',...
                                lcm.logPath,mcLogPath,msg)
                    end
                end
            end 
        else                            % check existence of LCM analysis (if to be used as reference) ---
            if ~isfield(lcm.fit,'resid')
                fprintf('No LCModel analysis found. Performed first.\n');
                return
            end
        end

        %--- summation fit ---
        lcm.mc.fid = ifft(ifftshift(lcm.fit.sumSpec,1),[],1);
    else            % original / experimental spectrum
        %--- reprocess for data vs. parameter consistency
        if isfield(lcm,'fid')
            if ~SP2_LCM_ProcLcmData
                fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
                return
            end
        else
            fprintf('%s ->\nTarget spectrum not found. Program aborted.\n',FCTNAME);
            return
        end
        
        %--- data assignment ---
        lcm.mc.fid = lcm.fid;
    end
end

%--- disable reprocessing of target spectrum ---
flag.lcmMCarloRunning = 1;
    
%--- fit result for potential init ---
lcm.anaScaleRef = lcm.anaScale(lcm.fit.applied);
%--- LB ---
if f_lb
    lcm.anaLbRef = lcm.anaLb(lcm.fit.applied);
end
%--- GB ---
if f_gb
    lcm.anaGbRef = lcm.anaGb(lcm.fit.applied);
end
%--- shift ---
if f_shift 
    lcm.anaShiftRef = lcm.anaShift(lcm.fit.applied);
end
%--- PHC0 ---
if f_phc0 
    lcm.anaPhc0Ref = lcm.anaPhc0;
end

%-------------------------------------------
%--- noise extraction                    ---
%-------------------------------------------
if ~flag.lcmMCarloCont               % continue earlier analysis
    %--- extraction of (pure) spectral noise: real part ---
    [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
        SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,real(lcm.spec));
    if ~f_done
        fprintf('%s ->\nReal noise area extraction failed. Program aborted.\n',FCTNAME);
        flag.lcmMCarloRunning = 0;
        return
    end
    fprintf('Real spectral noise range %.3f..%.3f ppm, original:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))

    %--- removal of 2nd order polynomial fit from spectral noise area ---
    coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
    noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1)).';   % fitted noise vector
    noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
    fprintf('Real spectral noise range %.3f..%.3f ppm, 2nd order corrected:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))

    %--- noise analysis: real part ---
    lcm.mc.noiseRefReal = std(noiseSpecZoom)/(sqrt(lcm.nspecC)*sqrt(lcm.sw_h));
    fprintf('MC real reference noise = %.6f\n',lcm.mc.noiseRefReal);
    
    %--- extraction of (pure) spectral noise: imaginary part ---
    [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
        SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,imag(lcm.spec));
    if ~f_done
        fprintf('%s ->\nImaginary noise area extraction failed. Program aborted.\n',FCTNAME);
        flag.lcmMCarloRunning = 0;
        return
    end
    fprintf('Imaginary spectral noise range %.3f..%.3f ppm, original:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))

    %--- removal of 2nd order polynomial fit from spectral noise area ---
    coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
    noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1)).';   % fitted noise vector
    noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
    fprintf('Imaginary spectral noise range %.3f..%.3f ppm, 2nd order corrected:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))

    %--- noise analysis: imaginary part ---
    lcm.mc.noiseRefImag = std(noiseSpecZoom)/(sqrt(lcm.nspecC)*sqrt(lcm.sw_h));
    fprintf('MC imaginary reference noise = %.6f\n',lcm.mc.noiseRefImag);
    
    %--- mean noise power ---
    lcm.mc.noiseRef = (lcm.mc.noiseRefReal + lcm.mc.noiseRefImag)/2;
end

%--- reference analysis and save noise figures to file ---
% LCM synthesized target only
if ~flag.lcmMCarloCont && isfield(lcm.fit,'resid') && flag.lcmMCarloData         % new analysis AND ref LCM done AND LCM synthesized
    if ~SP2_Loc_SaveLcmSummaryAndNoiseFigs(resultDir,'Ref')
        return
    end
end


%----------------------------------------------------
%--- Monte-Carlo analysis                         ---
%----------------------------------------------------
anaCnt             = 0;             % analysis counter for time management
flag.lcmMCarloStop = 0;             % break-off flag (functionality to be confirmed!)

%--- serial LCModel analysis ---
for nCnt = lcm.mc.nPrev+1:lcm.mc.nPrev+lcm.mc.n
    %--- end MC analysis gracefully ---
    if flag.lcmMCarloStop
        fprintf('\n\nMC simulation aborted.\n\n');
        flag.lcmMCarloRunning = 0;
        return
    end
    
    %--- info printout ---
    fprintf('\n\nANALYSIS %03i OF %03i\n',nCnt,lcm.mc.nPrev+lcm.mc.n);
    if nCnt>lcm.mc.nPrev+1
        anaCnt     = anaCnt + 1;
        tElapsed   = toc(tStart)/60;
        tTotal     = lcm.mc.n*tElapsed/anaCnt;
        tRemaining = tTotal-tElapsed;
        fprintf('%.1f min of %.1f min completed (%.0f%%), %.1f min remaining\n\n',...
                tElapsed,tTotal,100*anaCnt/lcm.mc.n,tRemaining)
    else
        fprintf('\n');
    end

    %--- synthesis of target FID ---
    % note that the target # pts is preserved from original analysis, but
    % no new apodization/ZF is applied here
    if flag.lcmMCarloData           % synthesize from reference LCM analysis
        % note: full noise scaling factor
        lcm.fid  = lcm.mc.fid(1:lcm.nspecC) + ...
                   (lcm.mc.noiseFac*lcm.mc.noiseRef*sqrt(lcm.sw_h)) * randn(1,lcm.nspecC)' + ...
                   1i*(lcm.mc.noiseFac*lcm.mc.noiseRef*sqrt(lcm.sw_h)) * randn(1,lcm.nspecC)';
    else                            % original / experimental data
        % note: noise scaling factor - 1 (since the experimental data
        % already has its noise floor)
        lcm.fid  = lcm.mc.fid(1:lcm.nspecC) + ...
                   (sqrt(lcm.mc.noiseFac^2-1)*lcm.mc.noiseRef*sqrt(lcm.sw_h)) * randn(1,lcm.nspecC)' + ...
                   1i*(sqrt(lcm.mc.noiseFac^2-1)*lcm.mc.noiseRef*sqrt(lcm.sw_h)) * randn(1,lcm.nspecC)';
    end
    lcm.spec = fftshift(fft(lcm.fid,[],1),1);
    
    %--- warning if lcm.mc.noiseFac>1 applied ---
    if lcm.mc.noiseFac>1
        fprintf('WARNING: noise amplification >1 applied (lcm.mc.noiseFac=%.2f).\n',lcm.mc.noiseFac);
    end
    
    %--- noise tracking: real part ---
    [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
    SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,real(lcm.spec));
    if ~f_done
        fprintf('%s ->\nNoise area extraction of real part failed. Program aborted.\n',FCTNAME);
        flag.lcmMCarloRunning = 0;
        return
    end
    
    %--- removal of 2nd order polynomial fit from real spectral noise area ---
    coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
    noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1)).';  % fitted noise vector
    noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
    fprintf('Real spectral noise range %.3f..%.3f ppm, 2nd order corrected:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))
    lcm.mc.noiseIterReal(nCnt) = std(noiseSpecZoom)/(sqrt(lcm.nspecC)*sqrt(lcm.sw_h));
    fprintf('MC#%.0f: Real noise = %.6f\n',nCnt,lcm.mc.noiseIterReal(nCnt));
    
    
    %--- noise tracking: imaginary part ---
    [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
    SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,imag(lcm.spec));
    if ~f_done
        fprintf('%s ->\nNoise area extraction of imaginary part failed. Program aborted.\n',FCTNAME);
        flag.lcmMCarloRunning = 0;
        return
    end
    
    %--- removal of 2nd order polynomial fit from imaginary spectral noise area ---
    coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
    noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1)).';  % fitted noise vector
    noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
    fprintf('Imaginary spectral noise range %.3f..%.3f ppm, 2nd order corrected:\nmin/max/SD %.1f/%.1f/%.1f\n',noisePpmZoom(1),noisePpmZoom(end),...
            min(noiseSpecZoom),max(noiseSpecZoom),std(noiseSpecZoom))
    lcm.mc.noiseIterImag(nCnt) = std(noiseSpecZoom)/(sqrt(lcm.nspecC)*sqrt(lcm.sw_h));
    fprintf('MC#%.0f: Imaginary noise = %.6f\n',nCnt,lcm.mc.noiseIterImag(nCnt));
    
    
    %--- reset starting values ---
    if flag.lcmMCarloInit && lcm.mc.initSpread>0             % init with somewhat randomized previous result
        % note:
        % 1) spread is applied to fitted parameters only
        % 2) LB/GB/shift use a 5 Hz minimum reference value to assure some
        % spread, PHC0 uses a 10 deg minimum reference
        if flag.lcmMCarloData            % reference synthesized from LCM analysis: fixed reference
            %--- scaling ---
            lcm.anaScale(lcm.fit.applied) = lcm.anaScaleRef .* ...
                                            abs((1 + lcm.mc.initSpread/100*randn(1,lcm.fit.appliedN)));
            %--- LB ---
            if f_lb
                lcm.anaLb(lcm.fit.applied) = lcm.anaLbRef + ...
                                             max(abs(lcm.anaLbRef), 5*ones(1,lcm.fit.appliedN)) .* ...
                                             lcm.mc.initSpread/100.*randn(1,lcm.fit.appliedN);
            end
            %--- GB ---
            if f_gb
                lcm.anaGb(lcm.fit.applied) = lcm.anaGbRef + ...
                                             max(abs(lcm.anaGbRef), 5*ones(1,lcm.fit.appliedN)) .* ...
                                             lcm.mc.initSpread/100.*randn(1,lcm.fit.appliedN);
            end
            %--- shift ---
            if f_shift 
                lcm.anaShift(lcm.fit.applied) = lcm.anaShiftRef + ...
                                                max(abs(lcm.anaShift(lcm.fit.applied)), 5*ones(1,lcm.fit.appliedN)) .* ...
                                                lcm.mc.initSpread/100.*randn(1,lcm.fit.appliedN);
            end
            %--- PHC0 ---
            if f_phc0 
                lcm.anaPhc0 = lcm.anaPhc0Ref + max(abs(lcm.anaPhc0Ref),10)*lcm.mc.initSpread/100*randn(1,1);
            end
        else
            %--- reset before very first analysis ---
            if ~SP2_LCM_AnaStartValReset
                fprintf('%s ->\nReset of LCModel starting values failed. Program aborted.\n\n',FCTNAME);
                return
            end
            
            %--- scaling ---
            lcm.anaScale(lcm.fit.applied) = lcm.anaScale(lcm.fit.applied) .* ...
                                            abs((1 + lcm.mc.initSpread/100*randn(1,lcm.fit.appliedN)));
            %--- LB ---
            if f_lb
                lcm.anaLb(lcm.fit.applied) = lcm.anaLb(lcm.fit.applied) + ...
                                             max(abs(lcm.anaLbRef), 5*ones(1,lcm.fit.appliedN)) .* ...
                                             lcm.mc.initSpread/100.*randn(1,lcm.fit.appliedN);
            end
            %--- GB ---
            if f_gb
                lcm.anaGb(lcm.fit.applied) = lcm.anaGb(lcm.fit.applied) + ...
                                             max(abs(lcm.anaGbRef), 5*ones(1,lcm.fit.appliedN)) .* ...
                                             lcm.mc.initSpread/100.*randn(1,lcm.fit.appliedN);
            end
            %--- shift ---
            if f_shift 
                lcm.anaShift(lcm.fit.applied) = lcm.anaShift(lcm.fit.applied) + ...
                                                max(abs(lcm.anaShift(lcm.fit.applied)), 5*ones(1,lcm.fit.appliedN)) .* ...
                                                lcm.mc.initSpread/100.*randn(1,lcm.fit.appliedN);
            end
            %--- PHC0 ---
            if f_phc0 
                lcm.anaPhc0 = lcm.anaPhc0Ref + max(abs(lcm.anaPhc0),10)*lcm.mc.initSpread/100*randn(1,1);
            end
        end
    else                                    % reset all fitting parameters before new fit
        if ~SP2_LCM_AnaStartValReset
            fprintf('%s ->\nReset of LCModel starting values failed. Program aborted.\n\n',FCTNAME);
            flag.lcmMCarloRunning = 0;
            return
        end
    end
    
    %--- perform LCM analysis ---
    % note that the precessing/update function of the target spectrum has
    % been disabled in SP2_LCM_AnaDoAnalysis through flag.lcmMCarloRunning=1
    if ~SP2_LCM_AnaDoAnalysis(0)
        fprintf('%s ->\nLCModel analysis failed. Program aborted.\n\n',FCTNAME);
        flag.lcmMCarloRunning = 0;
        return
    end
    
%     %--- perform CRLB analysis ---
%     if ~SP2_LCM_AnaDoCalcCRLB(0)
%         fprintf('%s ->\nCRLB calculation failed. Program aborted.\n\n',FCTNAME);
%         flag.lcmMCarloRunning = 0;
%         return
%     end

        
    %--- save LCM summary figure to file ---
    lcmSummaryFigPath = sprintf('%sSPX_LcmSummary_MC%03.0f.fig',resultDir,nCnt);
    if ~SP2_LCM_AnaSaveSummaryFigure(lcmSummaryFigPath)
        return
    end

    %--- move log file ---
    if SP2_CheckFileExistenceR(lcm.logPath)
        mcLogPath = sprintf('%sSPX_LcmAnalysis_MC%03.0f.log',resultDir,nCnt);
        [f_done,msg,msgId] = copyfile(lcm.logPath,mcLogPath);
        if ~f_done
            fprintf('\nCopying <%s>\nto <%s> failed.\nProgram aborted.\n%s\n\n',...
                    lcm.logPath,mcLogPath,msg)
        end
        delete(lcm.logPath)
    end
    
    %--- save figures of very first MC simulation to file ---
    % experimental target only
    if nCnt==1
        if ~flag.lcmMCarloCont && isfield(lcm.fit,'resid') && ~flag.lcmMCarloData         % new analysis AND ref LCM done AND experimental target
            if ~SP2_Loc_SaveLcmSummaryAndNoiseFigs(resultDir,'MC001')
                return
            end
        end
    end    

    %--- transfer result: individual metabolites ---
    %--- scaling / concentration ---
    lcm.mc.concMat(nCnt,1:lcm.fit.appliedN)     = lcm.anaScale(lcm.fit.applied);                % full length vector
    lcm.mc.concCrlbMat(nCnt,1:lcm.fit.appliedN) = lcm.fit.crlbAmp;                              % fitted metabs only
    if nCnt>1
%         lcm.mc.concSdTrace(nCnt,1:lcm.fit.appliedN) = 100*std(lcm.mc.concMat(1:nCnt,1:lcm.fit.appliedN))./abs(mean(lcm.mc.concMat(1:nCnt,1:lcm.fit.appliedN)));    % [%]
        lcm.mc.concSdTrace(nCnt,1:lcm.fit.appliedN) = std(lcm.mc.concMat(1:nCnt,1:lcm.fit.appliedN));    % [a.u.]
    end
    
    %--- Lorentzian line broadening ---
    if f_lb
        if flag.lcmLinkLb
            lcm.mc.lbVec(nCnt)       = lcm.anaLb(lcm.fit.applied(1));          % full length vector
            lcm.mc.lbCrlbVec(nCnt)   = lcm.fit.crlbLb;                         % fitted metabs only
            % lcm.mc.lbSdTrace(nCnt)   = std(lcm.mc.lbVec(1:nCnt))./abs(mean(lcm.mc.lbVec(1:nCnt)));
            if nCnt>1
                lcm.mc.lbSdTrace(nCnt)   = std(lcm.mc.lbVec(1:nCnt));               % [Hz]
            end
        else
            lcm.mc.lbMat(nCnt,1:lcm.fit.appliedN)     = lcm.anaLb(lcm.fit.applied);             % full length vector
            lcm.mc.lbCrlbMat(nCnt,1:lcm.fit.appliedN) = lcm.fit.crlbLb;                         % fitted metabs only
            % lcm.mc.lbSdTrace(nCnt,1:lcm.fit.appliedN) = std(lcm.mc.lbMat(1:nCnt,1:lcm.fit.appliedN))./abs(mean(lcm.mc.lbMat(1:nCnt,1:lcm.fit.appliedN)));
            if nCnt>1
                lcm.mc.lbSdTrace(nCnt,1:lcm.fit.appliedN) = std(lcm.mc.lbMat(1:nCnt,1:lcm.fit.appliedN));             % [Hz]
            end
        end
    end
    
    %--- Gaussian broadening ---
    if f_gb
        if flag.lcmLinkGb
            lcm.mc.gbVec(nCnt)       = lcm.anaGb(lcm.fit.applied(1));          % full length vector
            lcm.mc.gbCrlbVec(nCnt)   = lcm.fit.crlbGb;                         % fitted metabs only
            % lcm.mc.gbSdTrace(nCnt)   = std(lcm.mc.gbVec(1:nCnt))./abs(mean(lcm.mc.gbVec(1:nCnt)));
            if nCnt>1
                lcm.mc.gbSdTrace(nCnt)   = std(lcm.mc.gbVec(1:nCnt));               % [Hz^2]
            end
        else
            lcm.mc.gbMat(nCnt,1:lcm.fit.appliedN)     = lcm.anaGb(lcm.fit.applied);             % full length vector
            lcm.mc.gbCrlbMat(nCnt,1:lcm.fit.appliedN) = lcm.fit.crlbGb;                         % fitted metabs only
            % lcm.mc.gbSdTrace(nCnt,1:lcm.fit.appliedN) = std(lcm.mc.gbMat(1:nCnt,1:lcm.fit.appliedN))./abs(mean(lcm.mc.gbMat(1:nCnt,1:lcm.fit.appliedN)));
            if nCnt>1
                lcm.mc.gbSdTrace(nCnt,1:lcm.fit.appliedN) = std(lcm.mc.gbMat(1:nCnt,1:lcm.fit.appliedN));             % [Hz^2]
            end
        end
    end
    
    %--- frequency shift ---
    if f_shift
        if flag.lcmLinkShift
            lcm.mc.shiftVec(nCnt)       = lcm.anaShift(lcm.fit.applied(1));    % full length vector
            lcm.mc.shiftCrlbVec(nCnt)   = lcm.fit.crlbShift;                   % fitted metabs only
            % lcm.mc.shiftSdTrace(nCnt)   = std(lcm.mc.shiftVec(1:nCnt))./abs(mean(lcm.mc.shiftVec(1:nCnt)));
            if nCnt>1
                lcm.mc.shiftSdTrace(nCnt)   = std(lcm.mc.shiftVec(1:nCnt));        % [Hz]
            end
        else
            lcm.mc.shiftMat(nCnt,1:lcm.fit.appliedN)     = lcm.anaShift(lcm.fit.applied);       % full length vector
            lcm.mc.shiftCrlbMat(nCnt,1:lcm.fit.appliedN) = lcm.fit.crlbShift;                   % fitted metabs only
            % lcm.mc.shiftSdTrace(nCnt,1:lcm.fit.appliedN) = std(lcm.mc.shiftMat(1:nCnt,1:lcm.fit.appliedN))./abs(mean(lcm.mc.shiftMat(1:nCnt,1:lcm.fit.appliedN)));
            if nCnt>1
                lcm.mc.shiftSdTrace(nCnt,1:lcm.fit.appliedN) = std(lcm.mc.shiftMat(1:nCnt,1:lcm.fit.appliedN));       % [Hz]
            end
        end
    end
    
%     %--- zero order phase correction ---
%     if f_phc0
%         lcm.mc.phc0Vec(nCnt)     = lcm.anaPhc0;                                % full length vector
%         lcm.mc.phc0CrlbVec(nCnt) = lcm.fit.crlbPhc0;                           % fitted metabs only
%         % lcm.mc.phc0SdTrace(nCnt) = std(lcm.mc.phc0Vec(1:nCnt))./abs(mean(lcm.mc.phc0Vec(1:nCnt)));
%         if nCnt>1
%             lcm.mc.phc0SdTrace(nCnt) = std(lcm.mc.phc0Vec(1:nCnt));                 % [deg]
%         end
%     end
    
    %--- transfer result: metabolite combinations ---
    if lcm.combN>0
        %--- scaling / concentration ---
        lcm.mc.concMat(nCnt,lcm.fit.appliedN+1:end)     = lcm.combScale(lcm.combInd);     % applied metabolite combinations
        % this needs to be tested for non-consecutive metabolite
        % combinations on Fit Details page...
        lcm.mc.concCrlbMat(nCnt,lcm.fit.appliedN+1:end) = lcm.fit.combCrlbAmp(lcm.combCrlbPos(lcm.combInd));                              % fitted metabs only
        if nCnt>1
%             lcm.mc.concSdTrace(nCnt,lcm.fit.appliedN+1:end) = 100*std(lcm.mc.concMat(1:nCnt,lcm.fit.appliedN+1:end))./abs(mean(lcm.mc.concMat(1:nCnt,lcm.fit.appliedN+1:end)));    % [%]
            lcm.mc.concSdTrace(nCnt,lcm.fit.appliedN+1:end) = std(lcm.mc.concMat(1:nCnt,lcm.fit.appliedN+1:end));    % [a.u.]
        end
        
        %--- Lorentzian line broadening ---
        if f_lb
            if ~flag.lcmLinkLb
                lcm.mc.lbMat(nCnt,lcm.fit.appliedN+1:end)         = lcm.combLb(lcm.combInd);    % applied metabolite combinations
                lcm.mc.lbCrlbMat(nCnt,lcm.fit.appliedN+1:end)     = lcm.fit.combCrlbLb(lcm.combCrlbPos(lcm.combInd));                         % fitted metabs only
                % lcm.mc.lbSdTrace(nCnt,lcm.fit.appliedN+1:end) = std(lcm.mc.lbMat(1:nCnt,lcm.fit.appliedN+1:end))./abs(mean(lcm.mc.lbMat(1:nCnt,lcm.fit.appliedN+1:end)));
                if nCnt>1
                    lcm.mc.lbSdTrace(nCnt,lcm.fit.appliedN+1:end) = std(lcm.mc.lbMat(1:nCnt,lcm.fit.appliedN+1:end));             % [Hz]
                end
            end
        end
        
        %--- Gaussian line broadening ---
        if f_gb
            if ~flag.lcmLinkGb
                lcm.mc.gbMat(nCnt,lcm.fit.appliedN+1:end)         = lcm.combGb(lcm.combInd);    % applied metabolite combinations
                lcm.mc.gbCrlbMat(nCnt,lcm.fit.appliedN+1:end)     = lcm.fit.combCrlbGb(lcm.combCrlbPos(lcm.combInd));                         % fitted metabs only
                % lcm.mc.gbSdTrace(nCnt,lcm.fit.appliedN+1:end) = std(lcm.mc.gbMat(1:nCnt,lcm.fit.appliedN+1:end))./abs(mean(lcm.mc.gbMat(1:nCnt,lcm.fit.appliedN+1:end)));
                if nCnt>1
                    lcm.mc.gbSdTrace(nCnt,lcm.fit.appliedN+1:end) = std(lcm.mc.gbMat(1:nCnt,lcm.fit.appliedN+1:end));             % [Hz^2]
                end
            end
        end
        
        %--- frequency shift ---
        if f_shift
            if ~flag.lcmLinkShift
                lcm.mc.shiftMat(nCnt,lcm.fit.appliedN+1:end)         = lcm.combShift(lcm.combInd);    % applied metabolite combinations
                lcm.mc.shiftCrlbMat(nCnt,lcm.fit.appliedN+1:end)     = lcm.fit.combCrlbShift(lcm.combCrlbPos(lcm.combInd));                   % fitted metabs only
                % lcm.mc.shiftSdTrace(nCnt,lcm.fit.appliedN+1:end) = std(lcm.mc.shiftMat(1:nCnt,lcm.fit.appliedN+1:end))./abs(mean(lcm.mc.shiftMat(1:nCnt,lcm.fit.appliedN+1:end)));
                if nCnt>1
                    lcm.mc.shiftSdTrace(nCnt,lcm.fit.appliedN+1:end) = std(lcm.mc.shiftMat(1:nCnt,lcm.fit.appliedN+1:end));       % [Hz]
                end
            end
        end
    end         % end of combined metabolites
    
    %--- zero order phase ---
    if f_phc0
        lcm.mc.phc0Vec(nCnt)     = lcm.anaPhc0;                                % full length vector
        lcm.mc.phc0CrlbVec(nCnt) = lcm.fit.crlbPhc0;                           % fitted metabs only
        % lcm.mc.phc0SdTrace(nCnt) = std(lcm.mc.phc0Vec(1:nCnt))./abs(mean(lcm.mc.phc0Vec(1:nCnt)));
        if nCnt>1
            lcm.mc.phc0SdTrace(nCnt) = std(lcm.mc.phc0Vec(1:nCnt));                 % [deg]
        end
    end
end


%----------------------------------------------------
%--- result statistics                            ---
%----------------------------------------------------
%--- add analysis statistics to result file ---
fprintf('\nMONTE-CARLO ANALYSIS STATISTICS\n');

%--- target data ---
if flag.lcmMCarloData           % synthesized from reference LCM analysis
    % note: full noise scaling factor
    fprintf('Target data: Spectrum synthesized from reference LCM analysis\n\n');
else                            % original / experimental data
    fprintf('Target data: Original / experimental spectrum\n\n');
end

fprintf('AMPLITUDE\n');
meanConcCrlbMat = mean(lcm.mc.concCrlbMat);
stdConcCrlbMat  = std(lcm.mc.concCrlbMat);
fprintf('Mean:      %s a.u.\n',SP2_Vec2PrintStr(mean(lcm.mc.concMat),4));
% fprintf('SD:        %s%%\n',SP2_Vec2PrintStr(100*std(lcm.mc.concMat)./abs(mean(lcm.mc.concMat)),4));
fprintf('SD:        %s a.u.\n',SP2_Vec2PrintStr(std(lcm.mc.concMat),4));
fprintf('CRLB Mean: %s a.u.\n',SP2_Vec2PrintStr(meanConcCrlbMat,4));
fprintf('CRLB SD:   %s a.u.\n',SP2_Vec2PrintStr(stdConcCrlbMat,4));
% concRatioCrlbSd = meanConcCrlbMat ./ (100*std(lcm.mc.concMat)./mean(lcm.mc.concMat));
concRatioCrlbSd = meanConcCrlbMat ./ std(lcm.mc.concMat);
fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(concRatioCrlbSd,3),mean(concRatioCrlbSd));
if f_lb 
    fprintf('LB\n');
    if flag.lcmLinkLb
        meanLbCrlbVec = mean(lcm.mc.lbCrlbVec);
        stdLbCrlbVec  = std(lcm.mc.lbCrlbVec);
        fprintf('Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.lbVec),4));
        fprintf('SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.lbVec),4));
        fprintf('CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanLbCrlbVec,4));
        fprintf('CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdLbCrlbVec,4));
        lbRatioCrlbSd = mean(lcm.mc.lbCrlbVec) ./ std(lcm.mc.lbVec);
    else
        meanLbCrlbMat = mean(lcm.mc.lbCrlbMat);
        stdLbCrlbMat  = std(lcm.mc.lbCrlbMat);
        fprintf('Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.lbMat),4));
        fprintf('SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.lbMat),4));
        fprintf('CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanLbCrlbMat,4));
        fprintf('CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdLbCrlbMat,4));
        lbRatioCrlbSd = mean(lcm.mc.lbCrlbMat) ./ std(lcm.mc.lbMat);
    end
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(lbRatioCrlbSd,3),mean(lbRatioCrlbSd));
end
if f_gb 
    fprintf('GB\n');
    if flag.lcmLinkGb
        meanGbCrlbVec = mean(lcm.mc.gbCrlbVec);
        stdGbCrlbVec  = std(lcm.mc.gbCrlbVec);
        fprintf('Mean:      %s Hz^2\n',SP2_Vec2PrintStr(mean(lcm.mc.gbVec),4));
        fprintf('SD:        %s Hz^2\n',SP2_Vec2PrintStr(std(lcm.mc.gbVec),4));
        fprintf('CRLB Mean: %s Hz^2\n',SP2_Vec2PrintStr(meanGbCrlbVec,4));
        fprintf('CRLB SD:   %s Hz^2\n',SP2_Vec2PrintStr(stdGbCrlbVec,4));
        gbRatioCrlbSd = mean(lcm.mc.gbCrlbVec) ./ std(lcm.mc.gbVec);
    else
        meanGbCrlbMat = mean(lcm.mc.gbCrlbMat);
        stdGbCrlbMat  = std(lcm.mc.gbCrlbMat);
        fprintf('Mean:      %s Hz^2\n',SP2_Vec2PrintStr(mean(lcm.mc.gbMat),4));
        fprintf('SD:        %s Hz^2\n',SP2_Vec2PrintStr(std(lcm.mc.gbMat),4));
        fprintf('CRLB Mean: %s Hz^2\n',SP2_Vec2PrintStr(meanGbCrlbMat,4));
        fprintf('CRLB SD:   %s Hz^2\n',SP2_Vec2PrintStr(stdGbCrlbMat,4));
        gbRatioCrlbSd = mean(lcm.mc.gbCrlbMat) ./ std(lcm.mc.gbMat);
    end
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(gbRatioCrlbSd,3),mean(gbRatioCrlbSd));
end
if f_shift
    fprintf('SHIFT\n');
    if flag.lcmLinkShift
        meanShiftCrlbVec = mean(lcm.mc.shiftCrlbVec);
        stdShiftCrlbVec  = std(lcm.mc.shiftCrlbVec);
        fprintf('Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.shiftVec),4));
        fprintf('SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.shiftVec),4));
        fprintf('CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanShiftCrlbVec,4));
        fprintf('CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdShiftCrlbVec,4));
        shiftRatioCrlbSd = mean(lcm.mc.shiftCrlbVec) ./ std(lcm.mc.shiftVec);
    else
        meanShiftCrlbMat = mean(lcm.mc.shiftCrlbMat);
        stdShiftCrlbMat  = std(lcm.mc.shiftCrlbMat);
        fprintf('Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.shiftMat),4));
        fprintf('SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.shiftMat),4));
        fprintf('CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanShiftCrlbMat,4));
        fprintf('CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdShiftCrlbMat,4));
        shiftRatioCrlbSd = mean(lcm.mc.shiftCrlbMat) ./ std(lcm.mc.shiftMat);
    end
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(shiftRatioCrlbSd,3),mean(shiftRatioCrlbSd));
end
if f_phc0
    fprintf('PHC0\n');
    meanPhc0CrlbVec = mean(lcm.mc.phc0CrlbVec);
    stdPhc0CrlbVec  = std(lcm.mc.phc0CrlbVec);
    fprintf('Mean:      %s deg\n',SP2_Vec2PrintStr(mean(lcm.mc.phc0Vec),4));
    fprintf('SD:        %s deg\n',SP2_Vec2PrintStr(std(lcm.mc.phc0Vec),4));
    fprintf('CRLB Mean: %s deg\n',SP2_Vec2PrintStr(meanPhc0CrlbVec,4));
    fprintf('CRLB SD:   %s deg\n',SP2_Vec2PrintStr(stdPhc0CrlbVec,4));
    phc0RatioCrlbSd = mean(lcm.mc.phc0CrlbVec) ./ std(lcm.mc.phc0Vec);
    fprintf('Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(phc0RatioCrlbSd,3),mean(phc0RatioCrlbSd));
end

%--- average noise ---
lcm.mc.noiseIter = (lcm.mc.noiseIterReal + lcm.mc.noiseIterImag)/2;

%--- noise statistics: real part ---
fprintf('Real noise:\nReference %.6f\n',lcm.mc.noiseRefReal);
fprintf('MC %s\n',SP2_Vec2PrintStr(lcm.mc.noiseIterReal,6));
fprintf('MC mean %.6f, SD %.6f (%.1f%%)\n\n',mean(lcm.mc.noiseIterReal),...
        std(lcm.mc.noiseIterReal),100*std(lcm.mc.noiseIterReal)/mean(lcm.mc.noiseIterReal));

%--- noise statistics: imaginary part ---
fprintf('Imaginary noise:\nReference %.6f\n',lcm.mc.noiseRefImag);
fprintf('MC %s\n',SP2_Vec2PrintStr(lcm.mc.noiseIterImag,6));
fprintf('MC mean %.6f, SD %.6f (%.1f%%)\n\n',mean(lcm.mc.noiseIterImag),...
        std(lcm.mc.noiseIterImag),100*std(lcm.mc.noiseIterImag)/mean(lcm.mc.noiseIterImag));

%--- noise statistics: combined ---
fprintf('Average noise:\nReference %.6f\n',lcm.mc.noiseRef);
fprintf('MC %s\n',SP2_Vec2PrintStr(lcm.mc.noiseIter,6));
fprintf('MC mean %.6f, SD %.6f (%.1f%%)\n\n',mean(lcm.mc.noiseIter),...
        std(lcm.mc.noiseIter),100*std(lcm.mc.noiseIter)/mean(lcm.mc.noiseIter));


%----------------------------------------------------
%--- log file creation                            ---
%----------------------------------------------------
%--- file handling ---
unit = fopen([resultDir 'SPX_MonteCarlo.txt'],'w');
if unit==-1
    fprintf('%s ->\nOpening Monte-Carlo result file failed. Program aborted.\n',FCTNAME);
    flag.lcmMCarloRunning = 0;
    return
end

%--- write results to file ---
fprintf(unit,'%%\n%%  MONTE-CARLO ANALYSIS STATISTICS\n%%\n');
fprintf(unit,'%%  function %s.m\n%%\n',FCTNAME);
clockVec = clock;
fprintf(unit,'%%  date %s, time %02i:%02i\n%%\n',date,clockVec(4),clockVec(5));

%--- target data ---
if flag.lcmMCarloData           % synthesized from reference LCM analysis
    fprintf(unit,'\nTarget: Spectrum synthesized from reference LCM analysis\n');
else                            % original / experimental data
    fprintf(unit,'\nTarget: Original / experimental spectrum\n');
end

%--- basis info ---
fprintf(unit,'\nMetabs: [');
for mCnt = 1:lcm.fit.appliedN
    if mCnt<lcm.fit.appliedN
        fprintf(unit,'%s (%.0f), ',lcm.anaMetabs{mCnt},mCnt);
    else
        fprintf(unit,'%s (%.0f)',lcm.anaMetabs{mCnt},mCnt);
    end
end
fprintf(unit,']\n');

% metabolite combinations
combCnt = 0;            % combination counter
% as combination flags on Fit Details page are independent and, for instance, 
% non-consecutive combinations can be selected (e.g. 1 and 3, but not 2)
if flag.lcmComb1
    combCnt = combCnt + 1;
    if combCnt==lcm.combN
        fprintf(unit,'%s (%.0f)',lcm.combLabels{1},lcm.fit.appliedN+combCnt);
    else
        fprintf(unit,'%s (%.0f), ',lcm.combLabels{1},lcm.fit.appliedN+combCnt);
    end
end
if flag.lcmComb2
    combCnt = combCnt + 1;
    if combCnt==lcm.combN
        fprintf(unit,'%s (%.0f)',lcm.combLabels{2},lcm.fit.appliedN+combCnt);
    else
        fprintf(unit,'%s (%.0f), ',lcm.combLabels{2},lcm.fit.appliedN+combCnt);
    end
end
if flag.lcmComb3
    combCnt = combCnt + 1;
    if combCnt==lcm.combN
        fprintf(unit,'%s (%.0f)',lcm.combLabels{3},lcm.fit.appliedN+combCnt);
    else
        fprintf(unit,'%s (%.0f), ',lcm.combLabels{3},lcm.fit.appliedN+combCnt);
    end
end
fprintf(unit,']\n');
    

%--- add analysis statistics to result file ---
fprintf(unit,'\nAMPLITUDE\n');
fprintf(unit,'Mean:      %s a.u.\n',SP2_Vec2PrintStr(mean(lcm.mc.concMat),4));
fprintf(unit,'SD:        %s a.u.\n',SP2_Vec2PrintStr(std(lcm.mc.concMat),4));
fprintf(unit,'CRLB Mean: %s a.u.\n',SP2_Vec2PrintStr(meanConcCrlbMat,4));
fprintf(unit,'CRLB SD:   %s a.u.\n',SP2_Vec2PrintStr(stdConcCrlbMat,4));
fprintf(unit,'Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(concRatioCrlbSd,3),mean(concRatioCrlbSd));
if f_lb 
    fprintf(unit,'LB\n');
    if flag.lcmLinkLb
        fprintf(unit,'Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.lbVec),4));
        fprintf(unit,'SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.lbVec),4));
        fprintf(unit,'CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanLbCrlbVec,4));
        fprintf(unit,'CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdLbCrlbVec,4));
    else
        fprintf(unit,'Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.lbMat),4));
        fprintf(unit,'SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.lbMat),4));
        fprintf(unit,'CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanLbCrlbMat,4));
        fprintf(unit,'CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdLbCrlbMat,4));
    end
    fprintf(unit,'Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(lbRatioCrlbSd,3),mean(lbRatioCrlbSd));
end
if f_gb 
    fprintf(unit,'GB\n');
    if flag.lcmLinkGb
        fprintf(unit,'Mean:      %s Hz^2\n',SP2_Vec2PrintStr(mean(lcm.mc.gbVec),4));
        fprintf(unit,'SD:        %s Hz^2\n',SP2_Vec2PrintStr(std(lcm.mc.gbVec),4));
        fprintf(unit,'CRLB Mean: %s Hz^2\n',SP2_Vec2PrintStr(meanGbCrlbVec,4));
        fprintf(unit,'CRLB SD:   %s Hz^2\n',SP2_Vec2PrintStr(stdGbCrlbVec,4));
    else
        fprintf(unit,'Mean:      %s Hz^2\n',SP2_Vec2PrintStr(mean(lcm.mc.gbMat),4));
        fprintf(unit,'SD:        %s Hz^2\n',SP2_Vec2PrintStr(std(lcm.mc.gbMat),4));
        fprintf(unit,'CRLB Mean: %s Hz^2\n',SP2_Vec2PrintStr(meanLbCrlbMat,4));
        fprintf(unit,'CRLB SD:   %s Hz^2\n',SP2_Vec2PrintStr(stdLbCrlbMat,4));
    end
    fprintf(unit,'Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(gbRatioCrlbSd,3),mean(gbRatioCrlbSd));
end
if f_shift
    fprintf(unit,'SHIFT\n');
    if flag.lcmLinkShift
        fprintf(unit,'Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.shiftVec),4));
        fprintf(unit,'SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.shiftVec),4));
        fprintf(unit,'CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanShiftCrlbVec,4));
        fprintf(unit,'CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdShiftCrlbVec,4));
    else
        fprintf(unit,'Mean:      %s Hz\n',SP2_Vec2PrintStr(mean(lcm.mc.shiftMat),4));
        fprintf(unit,'SD:        %s Hz\n',SP2_Vec2PrintStr(std(lcm.mc.shiftMat),4));
        fprintf(unit,'CRLB Mean: %s Hz\n',SP2_Vec2PrintStr(meanShiftCrlbMat,4));
        fprintf(unit,'CRLB SD:   %s Hz\n',SP2_Vec2PrintStr(stdShiftCrlbMat,4));
    end
    fprintf(unit,'Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(shiftRatioCrlbSd,3),mean(shiftRatioCrlbSd));
end
if f_phc0
    fprintf(unit,'PHC0\n');
    fprintf(unit,'Mean:      %s deg\n',SP2_Vec2PrintStr(mean(lcm.mc.phc0Vec),4));
    fprintf(unit,'SD:        %s deg\n',SP2_Vec2PrintStr(std(lcm.mc.phc0Vec),4));
    fprintf(unit,'CRLB Mean: %s deg\n',SP2_Vec2PrintStr(meanPhc0CrlbVec,4));
    fprintf(unit,'CRLB SD:   %s deg\n',SP2_Vec2PrintStr(stdPhc0CrlbVec,4));
    fprintf(unit,'Ratio CRLB / SD:\n%s, mean %.2f\n\n',SP2_Vec2PrintStr(phc0RatioCrlbSd,3),mean(phc0RatioCrlbSd));
end
% fprintf(unit,'MC reference noise %.6f\n',lcm.mc.noiseRef);
% fprintf(unit,'MC noise %s\n',SP2_Vec2PrintStr(lcm.mc.noiseIter,6));
% fprintf(unit,'MC noise mean %.6f, SD %.6f (%.1f%%)\n\n',mean(lcm.mc.noiseIter),...
%         std(lcm.mc.noiseIter),100*std(lcm.mc.noiseIter)/mean(lcm.mc.noiseIter));
    
%--- noise statistics: real part ---
fprintf(unit,'Real noise:\nReference %.6f\n',lcm.mc.noiseRefReal);
fprintf(unit,'MC %s\n',SP2_Vec2PrintStr(lcm.mc.noiseIterReal,6));
fprintf(unit,'MC mean %.6f, SD %.6f (%.1f%%)\n\n',mean(lcm.mc.noiseIterReal),...
        std(lcm.mc.noiseIterReal),100*std(lcm.mc.noiseIterReal)/mean(lcm.mc.noiseIterReal));

%--- noise statistics: imaginary part ---
fprintf(unit,'Imaginary noise:\nReference %.6f\n',lcm.mc.noiseRefImag);
fprintf(unit,'MC %s\n',SP2_Vec2PrintStr(lcm.mc.noiseIterImag,6));
fprintf(unit,'MC mean %.6f, SD %.6f (%.1f%%)\n\n',mean(lcm.mc.noiseIterImag),...
        std(lcm.mc.noiseIterImag),100*std(lcm.mc.noiseIterImag)/mean(lcm.mc.noiseIterImag));

%--- noise statistics: combined ---
fprintf(unit,'Average noise:\nReference %.6f\n',lcm.mc.noiseRef);
fprintf(unit,'MC %s\n',SP2_Vec2PrintStr(lcm.mc.noiseIter,6));
fprintf(unit,'MC mean %.6f, SD %.6f (%.1f%%)\n\n',mean(lcm.mc.noiseIter),...
        std(lcm.mc.noiseIter),100*std(lcm.mc.noiseIter)/mean(lcm.mc.noiseIter));
    
    
%--- write concentration traces to file ---
fprintf(unit,'\nConcentration traces:\n');
% individual metabolites
for mCnt = 1:lcm.fit.appliedN               % metabolites
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concMat(nCnt,mCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
% metabolite combinations
combCnt = 0;            % combination counter
% as combination flags on Fit Details page are independent and, for instance, 
% non-consecutive combinations can be selected (e.g. 1 and 3, but not 2)
if flag.lcmComb1
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concMat(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
if flag.lcmComb2
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concMat(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
if flag.lcmComb3
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concMat(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
    
%--- write concentration CRLB traces to file ---
fprintf(unit,'\nConcentration CRLB traces:\n');
% individual metabolites
for mCnt = 1:lcm.fit.appliedN               % metabolites
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concCrlbMat(nCnt,mCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
%             fprintf(unit,'] %%\n');
            fprintf(unit,'] a.u.\n');
        end
    end
end
% metabolite combinations
combCnt = 0;            % combination counter
% as combination flags on Fit Details page are independent and, for instance, 
% non-consecutive combinations can be selected (e.g. 1 and 3, but not 2)
if flag.lcmComb1
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
if flag.lcmComb2
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
if flag.lcmComb3
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end

%--- write concentration SD traces to file ---
fprintf(unit,'\nConcentration SD traces:\n');
% individual metabolites
for mCnt = 1:lcm.fit.appliedN               % metabolites
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concSdTrace(nCnt,mCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
% metabolite combinations
combCnt = 0;            % combination counter
% as combination flags on Fit Details page are independent and, for instance, 
% non-consecutive combinations can be selected (e.g. 1 and 3, but not 2)
if flag.lcmComb1
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concSdTrace(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
if flag.lcmComb2
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concSdTrace(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end
if flag.lcmComb3
    combCnt = combCnt + 1;
    fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.concSdTrace(nCnt,lcm.fit.appliedN+combCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] a.u.\n');
        end
    end
end


%--- write LB traces to file ---
if f_lb 
    if flag.lcmLinkLb
        fprintf(unit,'\nglobal loggingfile (linked) Lorentzian line broadening trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            % fprintf(unit,'%f',lcm.mc.lbMat(nCnt));
            fprintf(unit,'%f',lcm.mc.lbVec(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific Lorentzian line broadening traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.lbMat(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
        end
    end
end

%--- write LB CRLB to file ---
if f_lb 
    if flag.lcmLinkLb
        fprintf(unit,'\nglobal loggingfile (linked) Lorentzian line broadening CRLB trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            % fprintf(unit,'%f',lcm.mc.lbCrlbMat(nCnt));
            fprintf(unit,'%f',lcm.mc.lbCrlbVec(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific Lorentzian line broadening CRLB traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.lbCrlbMat(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
        end
    end
end

%--- write LB SD traces to file ---
if f_lb 
    if flag.lcmLinkLb
        fprintf(unit,'\nglobal loggingfile (linked) Lorentzian line broadening SD trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            fprintf(unit,'%f',lcm.mc.lbSdTrace(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific Lorentzian line broadening SD traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.lbSdTrace(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.lbSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
        end
    end
end


%--- write GB traces to file ---
if f_gb 
    if flag.lcmLinkGb
        fprintf(unit,'\nglobal loggingfile (linked) Gaussian line broadening trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            % fprintf(unit,'%f',lcm.mc.gbMat(nCnt));
            fprintf(unit,'%f',lcm.mc.gbVec(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz^2\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific Gaussian line broadening traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.gbMat(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz^2\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
        end
    end
end

%--- write GB CRLB to file ---
if f_gb 
    if flag.lcmLinkGb
        fprintf(unit,'\nglobal loggingfile (linked) Gaussian line broadening CRLB trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            % fprintf(unit,'%f',lcm.mc.gbCrlbMat(nCnt));
            fprintf(unit,'%f',lcm.mc.gbCrlbVec(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz^2\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific Gaussian line broadening CRLB traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.gbCrlbMat(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz^2\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
        end
    end
end

%--- write GB SD traces to file ---
if f_gb 
    if flag.lcmLinkGb
        fprintf(unit,'\nglobal loggingfile (linked) Gaussian line broadening SD trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            fprintf(unit,'%f',lcm.mc.gbSdTrace(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz^2\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific Gaussian line broadening SD traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.gbSdTrace(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz^2\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] %%\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.gbSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz^2\n');
                    end
                end
            end
        end
    end
end


%--- write frequency shift traces to file ---
if f_shift 
    if flag.lcmLinkShift
        fprintf(unit,'\nglobal loggingfile (linked) frequency shift trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            % fprintf(unit,'%f',lcm.mc.shiftMat(nCnt));
            fprintf(unit,'%f',lcm.mc.shiftVec(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific frequency shift traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.shiftMat(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
        end
    end
end

%--- write frequency shift CRLB to file ---
if f_shift 
    if flag.lcmLinkShift
        fprintf(unit,'\nglobal loggingfile (linked) frequency shift CRLB trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            % fprintf(unit,'%f',lcm.mc.shiftCrlbMat(nCnt));
            fprintf(unit,'%f',lcm.mc.shiftCrlbVec(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz\n');
            end
        end
    else
        fprintf(unit,'\nMetabolite-specific frequency shift CRLB traces:\n');
        %--- individual metabolites ---
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.shiftCrlbMat(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz\n');
                end
            end
        end
        
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftCrlbMat(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
        end
    end
end

%--- write shift SD traces to file ---
if f_shift 
    if flag.lcmLinkShift
        fprintf(unit,'\nglobal loggingfile (linked) frequency shift SD trace:\n[');
        for nCnt = 1:lcm.mc.n                   % MC iterations
            fprintf(unit,'%f',lcm.mc.shiftSdTrace(nCnt));
            if nCnt<lcm.mc.n
                fprintf(unit,' ');
            else
                fprintf(unit,'] Hz\n');
            end
        end
    else
        %--- individual metabolites ---
        fprintf(unit,'\nMetabolite-specific frequency shift SD traces:\n');
        for mCnt = 1:lcm.fit.appliedN               % metabolites
            fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.anaMetabs{mCnt}));
            for nCnt = 1:lcm.mc.n                   % MC iterations
                fprintf(unit,'%f',lcm.mc.shiftSdTrace(nCnt,mCnt));
                if nCnt<lcm.mc.n
                    fprintf(unit,' ');
                else
                    fprintf(unit,'] Hz\n');
                end
            end
        end
         
        %--- metabolite combinations ---
        if lcm.combN>0
            combCnt = 0;            % combination counter
            if flag.lcmComb1
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{1}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb2
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{2}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
            if flag.lcmComb3
                combCnt = combCnt + 1;
                fprintf(unit,'%s [',SP2_PrVersionUscore(lcm.combLabels{3}));
                for nCnt = 1:lcm.mc.n                   % MC iterations
                    fprintf(unit,'%f',lcm.mc.shiftSdTrace(nCnt,lcm.fit.appliedN+combCnt));
                    if nCnt<lcm.mc.n
                        fprintf(unit,' ');
                    else
                        fprintf(unit,'] Hz\n');
                    end
                end
            end
        end
    end
end

%--- write PHC0 SD trace to file ---
if f_phc0
    fprintf(unit,'\nglobal loggingfile PHC0 SD trace:\n[');
    for nCnt = 1:lcm.mc.n                   % MC iterations
        fprintf(unit,'%f',lcm.mc.phc0SdTrace(nCnt));
        if nCnt<lcm.mc.n
            fprintf(unit,' ');
        else
            fprintf(unit,'] deg\n');
        end
    end
end
    
%--- computation time ---
if flag.lcmMCarloCont
    fprintf(unit,'\nMonte-Carlo continuation completed (%.0f steps, %.1f min / %.1f h)\n',lcm.mc.n,toc(tStart)/60,toc(tStart)/60/60);
else
    fprintf(unit,'\nMonte-Carlo simulation completed (%.0f steps, %.1f min / %.1f h)\n',lcm.mc.n,toc(tStart)/60,toc(tStart)/60/60);
end

%--- file handling ---
fprintf(unit, '\n');
fclose(unit);


%----------------------------------------------------
%--- figure creation                              ---
%----------------------------------------------------
%--- determine appropriate subplot handling ---
if lcm.combN>0
    % individual metabolites + metabolite combinations
    nTotal = lcm.fit.appliedN + lcm.combN;
else
    % individual metabolites only
    nTotal = lcm.fit.appliedN;
end
lcmSpline = round(nTotal^0.5);
NoResidD  = mod(nTotal,lcmSpline);            % pars.spl = slices per line
NoRowsD  = (nTotal-NoResidD)/lcmSpline;
if NoRowsD*lcmSpline<nTotal                   % in rare cases an additional increase by one is required...
    NoRowsD = NoRowsD + 1;
end

%--- plotting function: amplitude ---
fh_amp = figure;
set(fh_amp,'NumberTitle','off','Position',[10 10 1100 800],'Color',[1 1 1],'Name','Amplitude Convergence','Tag','LCM');
for mCnt = 1:nTotal
    %--- plot data ---
    subplot(NoRowsD,lcmSpline,mCnt);
    hold on
    plot([1 lcm.mc.nPrev+lcm.mc.n],meanConcCrlbMat(mCnt)*[1 1],'r')
    plot([1 lcm.mc.nPrev+lcm.mc.n],(meanConcCrlbMat(mCnt)-stdConcCrlbMat(mCnt))*[1 1],'g')
    plot([1 lcm.mc.nPrev+lcm.mc.n],(meanConcCrlbMat(mCnt)+stdConcCrlbMat(mCnt))*[1 1],'g')
    plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.concCrlbMat(:,mCnt),'Color',[1 0.6 1])
    plot(lcm.mc.concSdTrace(:,mCnt))
    hold off
    axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.concSdTrace(end,mCnt),meanConcCrlbMat(mCnt))])
    if mCnt>lcm.fit.appliedN
        title(sprintf('%s',SP2_PrVersionUscore(lcm.combLabels{mCnt-lcm.fit.appliedN})))
    else
        title(sprintf('%s',SP2_PrVersionUscore(lcm.anaMetabs{mCnt})))
    end
    if mCnt>lcmSpline*(NoRowsD-1)
        xlabel('# iterations')
    end
    if mod(mCnt,lcmSpline)==1
        ylabel('SD(Ampl.) [a.u.]')
    end
end
%--- save figure ---
ampConvFigPath = [resultDir 'SPX_LcmMCarlo_AmpConv.fig'];
saveas(fh_amp,ampConvFigPath,'fig');
    
%--- save as jpeg ---
if flag.lcmSaveJpeg
    ampConvJpgPath = [resultDir 'SPX_LcmMCarlo_AmpConv.jpg'];
    saveas(fh_amp,ampConvJpgPath,'jpg');
    fprintf('Amplitude convergence figure saved to files:\n%s\n%s\n',...
            ampConvFigPath,ampConvJpgPath);
else
    fprintf('Amplitude convergence figure saved to file:\n%s\n',ampConvFigPath);
end

%--- plotting function: LB ---
if f_lb 
    fh_lb = figure;
    if flag.lcmLinkLb
        set(fh_lb,'NumberTitle','off','Position',[20 20 560 550],'Color',[1 1 1],'Name','LB Convergence','Tag','LCM');
        hold on
        plot([1 lcm.mc.nPrev+lcm.mc.n],meanLbCrlbVec*[1 1],'r')
        plot([1 lcm.mc.nPrev+lcm.mc.n],(meanLbCrlbVec-stdLbCrlbVec)*[1 1],'g')
        plot([1 lcm.mc.nPrev+lcm.mc.n],(meanLbCrlbVec+stdLbCrlbVec)*[1 1],'g')
        plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.lbCrlbVec,'Color',[1 0.6 1])
        plot(lcm.mc.lbSdTrace)
        hold off
        axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.lbSdTrace(end),meanLbCrlbVec)])
        xlabel('# iterations')
        ylabel('SD(LB) [Hz]')
    else
        set(fh_lb,'NumberTitle','off','Position',[20 20 1100 800],'Color',[1 1 1],'Name','LB Convergence','Tag','LCM');
        for mCnt = 1:nTotal
            subplot(NoRowsD,lcmSpline,mCnt);
            hold on
            plot([1 lcm.mc.nPrev+lcm.mc.n],meanLbCrlbMat(mCnt)*[1 1],'r')
            plot([1 lcm.mc.nPrev+lcm.mc.n],(meanLbCrlbMat(mCnt)-stdLbCrlbMat(mCnt))*[1 1],'g')
            plot([1 lcm.mc.nPrev+lcm.mc.n],(meanLbCrlbMat(mCnt)+stdLbCrlbMat(mCnt))*[1 1],'g')
            plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.lbCrlbMat(:,mCnt),'Color',[1 0.6 1])
            plot(lcm.mc.lbSdTrace(:,mCnt))
            hold off
            axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.lbSdTrace(end,mCnt),meanLbCrlbMat(mCnt))])
            if mCnt>lcm.fit.appliedN
                title(sprintf('%s',SP2_PrVersionUscore(lcm.combLabels{mCnt-lcm.fit.appliedN})))
            else
                title(sprintf('%s',SP2_PrVersionUscore(lcm.anaMetabs{mCnt})))
            end
            if mCnt>lcmSpline*(NoRowsD-1)
                xlabel('# iterations')
            end
            if mod(mCnt,lcmSpline)==1
                ylabel('SD(LB) [Hz]')
            end

        end
    end
    %--- save figure ---
    lbConvFigPath = [resultDir 'SPX_LcmMCarlo_LbConv.fig'];
    saveas(fh_lb,lbConvFigPath,'fig');
    
    %--- save as jpeg ---
    if flag.lcmSaveJpeg
        lbConvJpgPath = [resultDir 'SPX_LcmMCarlo_LbConv.jpg'];
        saveas(fh_lb,lbConvJpgPath,'jpg');
        fprintf('LB convergence figure saved to files:\n%s\n%s\n',...
                lbConvFigPath,lbConvJpgPath);
    else
        fprintf('LB convergence figure saved to file:\n%s\n',lbConvFigPath);
    end
end

%--- plotting function: GB ---
if f_gb 
    fh_gb = figure;
    if flag.lcmLinkGb
        meanGbCrlbVec = mean(lcm.mc.gbCrlbVec);
        stdGbCrlbVec  = std(lcm.mc.gbCrlbVec);
        set(fh_gb,'NumberTitle','off','Position',[30 30 560 550],'Color',[1 1 1],'Name','GB Convergence','Tag','LCM');
        hold on
        plot([1 lcm.mc.nPrev+lcm.mc.n],meanGbCrlbVec*[1 1],'r')
        plot([1 lcm.mc.nPrev+lcm.mc.n],(meanGbCrlbVec-stdGbCrlbVec)*[1 1],'g')
        plot([1 lcm.mc.nPrev+lcm.mc.n],(meanGbCrlbVec+stdGbCrlbVec)*[1 1],'g')
        plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.gbCrlbVec,'Color',[1 0.6 1])
        plot(lcm.mc.gbSdTrace)
        hold off
        axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.gbSdTrace(end),meanGbCrlbVec)])
        xlabel('# iterations')
        ylabel('SD(GB) [Hz^2]')
    else
        meanGbCrlbMat = mean(lcm.mc.gbCrlbMat);
        stdGbCrlbMat  = std(lcm.mc.gbCrlbMat);
        set(fh_gb,'NumberTitle','off','Position',[30 30 1100 800],'Color',[1 1 1],'Name','GB Convergence','Tag','LCM');
        for mCnt = 1:nTotal
            subplot(NoRowsD,lcmSpline,mCnt);
            hold on
            plot([1 lcm.mc.nPrev+lcm.mc.n],meanGbCrlbMat(mCnt)*[1 1],'r')
            plot([1 lcm.mc.nPrev+lcm.mc.n],(meanGbCrlbMat(mCnt)-stdGbCrlbMat(mCnt))*[1 1],'g')
            plot([1 lcm.mc.nPrev+lcm.mc.n],(meanGbCrlbMat(mCnt)+stdGbCrlbMat(mCnt))*[1 1],'g')
            plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.gbCrlbMat(:,mCnt),'Color',[1 0.6 1])
            plot(lcm.mc.gbSdTrace(:,mCnt))
            hold off
            axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.gbSdTrace(end,mCnt),meanGbCrlbMat(mCnt))])
            if mCnt>lcm.fit.appliedN
                title(sprintf('%s',SP2_PrVersionUscore(lcm.combLabels{mCnt-lcm.fit.appliedN})))
            else
                title(sprintf('%s',SP2_PrVersionUscore(lcm.anaMetabs{mCnt})))
            end
            if mCnt>lcmSpline*(NoRowsD-1)
                xlabel('# iterations')
            end
            if mod(mCnt,lcmSpline)==1
                ylabel('SD(GB) [Hz^2]')
            end
        end
    end
    %--- save figure ---
    gbConvFigPath = [resultDir 'SPX_LcmMCarlo_GbConv.fig'];
    saveas(fh_gb,gbConvFigPath,'fig');
        
    %--- save as jpeg ---
    if flag.lcmSaveJpeg
        gbConvJpgPath = [resultDir 'SPX_LcmMCarlo_GbConv.jpg'];
        saveas(fh_gb,gbConvJpgPath,'jpg');
        fprintf('GB convergence figure saved to files:\n%s\n%s\n',...
                gbConvFigPath,gbConvJpgPath);
    else
        fprintf('GB convergence figure saved to file:\n%s\n',gbConvFigPath);
    end
end

%--- plotting function: Shift ---
if f_shift
    fh_shift = figure;
    if flag.lcmLinkShift
        meanShiftCrlbVec = mean(lcm.mc.shiftCrlbVec);
        stdShiftCrlbVec  = std(lcm.mc.shiftCrlbVec);
        set(fh_shift,'NumberTitle','off','Position',[40 40 560 550],'Color',[1 1 1],'Name','Shift Convergence','Tag','LCM');
        hold on
        plot([1 lcm.mc.nPrev+lcm.mc.n],meanShiftCrlbVec*[1 1],'r')
        plot([1 lcm.mc.nPrev+lcm.mc.n],(meanShiftCrlbVec-stdShiftCrlbVec)*[1 1],'g')
        plot([1 lcm.mc.nPrev+lcm.mc.n],(meanShiftCrlbVec+stdShiftCrlbVec)*[1 1],'g')
        plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.shiftCrlbVec,'Color',[1 0.6 1])
        plot(lcm.mc.shiftSdTrace)
        hold off
        axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.shiftSdTrace(end),meanShiftCrlbVec)])
        xlabel('# iterations')
        ylabel('SD(Shift) [Hz]')
    else
        meanShiftCrlbMat = mean(lcm.mc.shiftCrlbMat);
        stdShiftCrlbMat  = std(lcm.mc.shiftCrlbMat);
        set(fh_shift,'NumberTitle','off','Position',[40 40 1100 800],'Color',[1 1 1],'Name','Shift Convergence','Tag','LCM');
        for mCnt = 1:nTotal
            subplot(NoRowsD,lcmSpline,mCnt);
            hold on
            plot([1 lcm.mc.nPrev+lcm.mc.n],meanShiftCrlbMat(mCnt)*[1 1],'r')
            plot([1 lcm.mc.nPrev+lcm.mc.n],(meanShiftCrlbMat(mCnt)-stdShiftCrlbMat(mCnt))*[1 1],'g')
            plot([1 lcm.mc.nPrev+lcm.mc.n],(meanShiftCrlbMat(mCnt)+stdShiftCrlbMat(mCnt))*[1 1],'g')
            plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.shiftCrlbMat(:,mCnt),'Color',[1 0.6 1])
            plot(lcm.mc.shiftSdTrace(:,mCnt))
            hold off
            axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.shiftSdTrace(end,mCnt),meanShiftCrlbMat(mCnt))])
            if mCnt>lcm.fit.appliedN
                title(sprintf('%s',SP2_PrVersionUscore(lcm.combLabels{mCnt-lcm.fit.appliedN})))
            else
                title(sprintf('%s',SP2_PrVersionUscore(lcm.anaMetabs{mCnt})))
            end
            if mCnt>lcmSpline*(NoRowsD-1)
                xlabel('# iterations')
            end
            if mod(mCnt,lcmSpline)==1
                ylabel('SD(Shift) [Hz]')
            end
        end
    end
    %--- save figure ---
    shiftConvFigPath = [resultDir 'SPX_LcmMCarlo_ShiftConv.fig'];
    saveas(fh_shift,shiftConvFigPath,'fig');
                
    %--- save as jpeg ---
    if flag.lcmSaveJpeg
        shiftConvJpgPath = [resultDir 'SPX_LcmMCarlo_ShiftConv.jpg'];
        saveas(fh_shift,shiftConvJpgPath,'jpg');
        fprintf('Shift convergence figure saved to files:\n%s\n%s\n',...
                shiftConvFigPath,shiftConvJpgPath);
    else
        fprintf('Shift convergence figure saved to file:\n%s\n',shiftConvFigPath);
    end
end

%--- plotting function: PHC0 ---
if f_phc0
    meanPhc0CrlbVec = mean(lcm.mc.phc0CrlbVec);
    stdPhc0CrlbVec  = std(lcm.mc.phc0CrlbVec);
    fh_phc0 = figure;
    set(fh_phc0,'NumberTitle','off','Position',[50 50 560 550],'Color',[1 1 1],'Name','PHC0 Convergence','Tag','LCM');
    hold on
    plot([1 lcm.mc.nPrev+lcm.mc.n],meanPhc0CrlbVec*[1 1],'r')
    plot([1 lcm.mc.nPrev+lcm.mc.n],(meanPhc0CrlbVec-stdPhc0CrlbVec)*[1 1],'g')
    plot([1 lcm.mc.nPrev+lcm.mc.n],(meanPhc0CrlbVec+stdPhc0CrlbVec)*[1 1],'g')
    plot(1:lcm.mc.nPrev+lcm.mc.n,lcm.mc.phc0CrlbVec,'Color',[1 0.6 1])
    plot(lcm.mc.phc0SdTrace)
    hold off
    axis([0.5 lcm.mc.nPrev+lcm.mc.n+0.5 0 1.5*max(lcm.mc.phc0SdTrace(end),meanPhc0CrlbVec)])
    xlabel('# iterations')
    ylabel('SD(PHC0) [deg]')
    
    %--- save figure ---
    phc0ConvFigPath = [resultDir 'SPX_LcmMCarlo_Phc0Conv.fig'];
    saveas(fh_phc0,phc0ConvFigPath,'fig');
                        
    %--- save as jpeg ---
    if flag.lcmSaveJpeg
        phc0ConvJpgPath = [resultDir 'SPX_LcmMCarlo_Phc0Conv.jpg'];
        saveas(fh_phc0,phc0ConvJpgPath,'jpg');
        fprintf('PHC0 convergence figure saved to files:\n%s\n%s\n',...
                phc0ConvFigPath,phc0ConvJpgPath);
    else
        fprintf('PHC0 convergence figure saved to file:\n%s\n',phc0ConvFigPath);
    end
end

%--- info printout ---
if flag.lcmMCarloCont
    fprintf('\nMonte-Carlo continuation completed (%.0f steps, %.1f min / %.1f h)\n',lcm.mc.n,toc(tStart)/60,toc(tStart)/60/60);
else
    fprintf('\nMonte-Carlo simulation completed (%.0f steps, %.1f min / %.1f h)\n',lcm.mc.n,toc(tStart)/60,toc(tStart)/60/60);
end

%--- restore parameter settings ---
if ~flag.lcmMCarloInit                              % no parameter init, i.e. reset before every analysis
    flag.lcmAnaScale = flagLcmAnaScale;             % include amplitude scaling in reset
end
% flag.simNoiseKeep = flagSimNoiseKeep;

%--- reset MC running flag ---
flag.lcmMCarloRunning = 0;

%--- update success flag ---
f_succ = 1;





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%   L O C A L   F U N C T I O N S                                     %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function f_succLoc = SP2_Loc_SaveLcmSummaryAndNoiseFigs(resultDir,figKeyStr)

global loggingfile lcm flag


%--- init success flag ---
f_succLoc = 0;

%--- consistency checks ---
if ~SP2_CheckDirAccessR(resultDir)
    return
end
if ~SP2_Check4StrR(figKeyStr)
    return
end

%-------------------------------------------
%--- save reference LCM analysis to file ---
%-------------------------------------------
% keep SPX settings
flagLcmPpmShow   = flag.lcmPpmShow;
lcmPpmShowMin    = lcm.ppmShowMin;
lcmPpmShowMax    = lcm.ppmShowMax;
flagLcmAnaSNR    = flag.lcmAnaSNR;
flagLcmAnaFWHM   = flag.lcmAnaFWHM;
flagLcmAnaIntegr = flag.lcmAnaIntegr;

%--- set analysis flags ---
flag.lcmAnaSNR    = 1;              % to show the noise limits
flag.lcmAnaFWHM   = 0;
flag.lcmAnaIntegr = 0;       

% reassign plot limits around fitting window
flag.lcmPpmShow = 1;                        % direct assignment
lcm.ppmShowMin  = lcm.anaPpmMin - 0.3;
lcm.ppmShowMax  = lcm.anaPpmMax + 0.3;

%--- check figure existence ---
f_existSummary = 0;                                    % not previously existing
if isfield(lcm,'fhLcmFitSpecSummary')
    if ishandle(lcm.fhLcmFitSpecSummary)
        f_existSummary = 1;                            % figure already open
    end
end

%--- create figure and save to file ---
if ~SP2_LCM_PlotResultSpecSummary(1)
    flag.lcmMCarloRunning = 0;
    return
end
if isfield(lcm,'fhLcmFitSpecSummary')
    if ishandle(lcm.fhLcmFitSpecSummary)
        lcmSummaryFigPath = [resultDir sprintf('SPX_LcmMCarlo_InVivo%sSummary.fig',figKeyStr)];
        saveas(lcm.fhLcmFitSpecSummary,lcmSummaryFigPath,'fig');

        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            lcmSummaryJpgPath = [resultDir sprintf('SPX_LcmMCarlo_InVivo%sSummary.jpg',figKeyStr)];
            saveas(lcm.fhLcmFitSpecSummary,lcmSummaryJpgPath,'jpg');
            fprintf('LCM analysis of reference saved to files:\n%s\n%s\n',...
                    lcmSummaryFigPath,lcmSummaryJpgPath);
        else
            fprintf('LCM analysis of reference saved to file:\n%s\n',lcmSummaryFigPath);
        end
    end
end


%----------------------------------------------------
%--- save noise of reference LCM analysis to file ---
%----------------------------------------------------
% reassign plot limits around fitting window
flag.lcmPpmShow = 1;                        % direct assignment
lcm.ppmShowMin  = lcm.ppmNoiseMin - 0.3;
lcm.ppmShowMax  = lcm.ppmNoiseMax + 0.3;

%--- check figure existence ---
f_existNoise = 0;                                    % not previously existing
if isfield(lcm,'fhLcmSpec')
    if ishandle(lcm.fhLcmSpec)
        f_existNoise = 1;                            % figure already open
    end
end


%--- save baseline-corrected noise to file ---
% note that this is done first, so that the regular one remains in the end
% keep original FID
lcmSpec = lcm.spec;

%--- direct removal of 2nd order polynomial fit from noise area ---
[noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
    SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,lcm.spec);
if ~f_done
    fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME);
    flag.lcmMCarloRunning = 0;
    return
end
coeff = polyfit(1:(noiseMaxI-noiseMinI+1),noiseSpecZoom',2);    % fit
noiseSpecZoomFit = polyval(coeff,1:(noiseMaxI-noiseMinI+1))';   % fitted noise vector
noiseSpecZoom    = noiseSpecZoom - noiseSpecZoomFit;            % fit correction
lcm.spec = 0*lcm.spec;                                          % temporarily reset spectral vector
lcm.spec(noiseMinI:noiseMaxI) = noiseSpecZoom + 1i*noiseSpecZoom;    % only the real part matters here
% as that's the only part used in SP2_LCM_PlotLcmSpec

%--- switch off (additional) baseline correction ---
flag.lcmAnaSNR = 0;              

%--- plot baseline-corrected noise area ---
if ~SP2_LCM_PlotLcmSpec(1)
    flag.lcmMCarloRunning = 0;
    return
end
if isfield(lcm,'fhLcmSpec')
    if ishandle(lcm.fhLcmSpec)
        lcmNoiseCorrFigPath = [resultDir sprintf('SPX_LcmMCarlo_InVivo%sRealNoiseBaseCorr.fig',figKeyStr)];
        saveas(lcm.fhLcmSpec,lcmNoiseCorrFigPath,'fig');

        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            lcmNoiseCorrJpgPath = [resultDir sprintf('SPX_LcmMCarlo_InVivo%sRealNoiseBaseCorr.jpg',figKeyStr)];
            saveas(lcm.fhLcmSpec,lcmNoiseCorrJpgPath,'jpg');
            fprintf('Baseline-correctored noise range of reference saved to files:\n%s\n%s\n',...
                    lcmNoiseCorrFigPath,lcmNoiseCorrJpgPath);
        else
            fprintf('Baseline-corrected noise range of reference saved to file:\n%s\n',lcmNoiseCorrFigPath);
        end
    end
end

%--- restore original spectrum ---
lcm.spec = lcmSpec;


%--- create figure and save original noise to file ---
flag.lcmAnaSNR = 1;
if ~SP2_LCM_PlotLcmSpec(1)
    flag.lcmMCarloRunning = 0;
    return
end
if isfield(lcm,'fhLcmSpec')
    if ishandle(lcm.fhLcmSpec)
        lcmNoiseFigPath = [resultDir sprintf('SPX_LcmMCarlo_InVivo%sRealNoise.fig',figKeyStr)];
        saveas(lcm.fhLcmSpec,lcmNoiseFigPath,'fig');

        %--- save as jpeg ---
        if flag.lcmSaveJpeg
            lcmNoiseJpgPath = [resultDir sprintf('SPX_LcmMCarlo_InVivo%sRealNoise.jpg',figKeyStr)];
            saveas(lcm.fhLcmSpec,lcmNoiseJpgPath,'jpg');
            fprintf('Spectral noise range of reference saved to files:\n%s\n%s\n',...
                    lcmNoiseFigPath,lcmNoiseJpgPath);
        else
            fprintf('Spectral noise range of reference saved to file:\n%s\n',lcmNoiseFigPath);
        end
    end
end

%--- restore original SPX settings ---
flag.lcmPpmShow   = flagLcmPpmShow;
lcm.ppmShowMin    = lcmPpmShowMin;
lcm.ppmShowMax    = lcmPpmShowMax;
flag.lcmAnaSNR    = flagLcmAnaSNR;
flag.lcmAnaFWHM   = flagLcmAnaFWHM;
flag.lcmAnaIntegr = flagLcmAnaIntegr;

%--- delete figure if not existing previously ---
if f_existSummary                           % restore figure
    if ~SP2_LCM_PlotResultSpecSummary(0)
        flag.lcmMCarloRunning = 0;
        return
    end
else                                        % delete figure
    if ishandle(lcm.fhLcmFitSpecSummary)
        delete(lcm.fhLcmFitSpecSummary)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecSummary');
end

%--- delete/restore figure  ---
if f_existNoise                             % restore figure
    if ~SP2_LCM_PlotLcmSpec(0)
        flag.lcmMCarloRunning = 0;
        return
    end
else                                        % delete figure
    if ishandle(lcm.fhLcmSpec)
        delete(lcm.fhLcmSpec)
    end
    lcm = rmfield(lcm,'fhLcmSpec');
end

%--- update success flag ---
f_succLoc = 1;






