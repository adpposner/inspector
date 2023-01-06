%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_AnaDoAnalysis( f_plot )
%%
%%  Perform linear combination modeling (LCM) analysis
%%
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag lcmAna

FCTNAME = 'SP2_LCM_AnaDoAnalysis';


%--- init success flag ---
f_succ = 0;

%--- reprocess before analysis ---
% in case no figure is open and parameter changes have not yet been applied
if isfield(lcm,'fid')
    if ~flag.lcmMCarloRunning           % do not update during Monte-Carlo simulation series
        if ~SP2_LCM_ProcLcmData
            fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
            return
        end
    end
else
    fprintf('%s ->\nTarget spectrum not found. Program aborted.\n',FCTNAME);
    return
end

%--- check basis set existence and consistency ---
if ~isfield(lcm,'basis')
    fprintf('%s ->\nNo basis found. Load/create first.\n',FCTNAME);
    return
end
if ~isfield(lcm.basis,'data')
    fprintf('%s ->\nNo LCM basis set found. Load/create first.\n',FCTNAME);
    return
elseif ~iscell(lcm.basis.data)
    if lcm.basis.data==0
        fprintf('%s ->\nNo LCM basis set found. Load/create first.\n',FCTNAME);
        return
    end
end
for bCnt = 1:lcm.fit.appliedN           % loop over selected basis functions
    if ~any(real(lcm.basis.data{lcm.fit.applied(bCnt)}{4})~=0) || ~any(imag(lcm.basis.data{lcm.fit.applied(bCnt)}{4})~=0)
        fprintf('%s ->\nEmpty FID found for metabolite: <%s>. Program aborted\n',FCTNAME,lcm.basis.data{lcm.fit.applied(bCnt)}{1});
        return
    end
end     
% note that above check does not consider apodization


%--- CRLB considering metabolite combinations ---
% note that these checks are repeated inside the
% SP2_LCM_AnaDoCalcCRLB_Combined function as it might also be called
% directly.
if flag.lcmComb1 || flag.lcmComb2 || flag.lcmComb3
    % multifold assignment
    if flag.lcmComb1 && flag.lcmComb2
       if any(intersect(lcm.comb1Ind,lcm.comb2Ind))
           fprintf('%s ->\nMultifold assignment of summation metabolites detected between combinations 1 & 2.\nAnalysis aborted.\n',FCTNAME);
           return
       end
    end
    if flag.lcmComb1 && flag.lcmComb3
       if any(intersect(lcm.comb1Ind,lcm.comb3Ind))
           fprintf('%s ->\nMultifold assignment of summation metabolites detected between combinations 1 & 3.\nAnalysis aborted.\n',FCTNAME);
           return
       end
    end
    if flag.lcmComb2 && flag.lcmComb3
       if any(intersect(lcm.comb2Ind,lcm.comb3Ind))
           fprintf('%s ->\nMultifold assignment of summation metabolites detected between combinations 2 & 3.\nAnalysis aborted.\n',FCTNAME);
           return
       end
    end
    % selection of channels that are not supported or not active 
    if flag.lcmComb1
       if any(~ismember(lcm.comb1Ind,lcm.fit.applied))
           fprintf('%s ->\nAt least one basis of combination 1 is not supported or activated.\nProgram aborted.\n',FCTNAME);
           fprintf('Note that the combination indexing refers to the general basis numbers (in parenthesis),\nnot the set of basis functions selected to be employed\n');
           return
       end
    end
    if flag.lcmComb2
       if any(~ismember(lcm.comb2Ind,lcm.fit.applied))
           fprintf('%s ->\nAt least one basis of combination 2 is not supported or activated.\nProgram aborted.\n',FCTNAME);
           fprintf('Note that the combination indexing refers to the general basis numbers (in parenthesis),\nnot the set of basis functions selected to be employed\n');
           return
       end
    end
    if flag.lcmComb3
       if any(~ismember(lcm.comb3Ind,lcm.fit.applied))
           fprintf('%s ->\nAt least one basis of combination 3 is not supported or activated.\nProgram aborted.\n',FCTNAME);
           fprintf('Note that the combination indexing refers to the general basis numbers (in parenthesis),\nnot the set of basis functions selected to be employed\n');
           return
       end
    end
end


%--- check selection of at least one metabolite ---
if lcm.fit.appliedN==0
    fprintf('%s ->\nAt least one metabolite has to be selected. Program aborted.\n',FCTNAME);
    return
end

%--- SW (and dwell time) ---
if SP2_RoundToNthDigit(lcm.sw,1)~=SP2_RoundToNthDigit(lcm.basis.sw,1)
    fprintf('%s -> SW mismatch detected (%.2f ppm ~= %.2f ppm)\nProgram aborted.\n',FCTNAME,...
            lcm.sw,lcm.basis.sw)
    return
end

%--- create/init log file ---
if flag.lcmSaveLog
    if ~SP2_LCM_AnaSaveLogInit
        return
    end
end

%--- number of points ---
% note that lcm.nspecC here is the length of the target FID/spectrum
if lcm.nspecC==lcm.basis.ptsMin
    lcm.anaNspecC = lcm.nspecC;
else
    fprintf('\nWARNING: Spectral size mismatch of some/all FIDs:\n%.0f pts (target) ~= %.0f pts (basis)\n',...
            lcm.nspecC,lcm.basis.ptsMin)
    if flag.lcmSaveLog
        fprintf(lcm.log,'\nWARNING: Spectral size mismatch of some/all FIDs:\n%.0f pts (target) ~= %.0f pts (basis)\n',...
                lcm.nspecC,lcm.basis.ptsMin);
    end
    
    %--- (local) determination of effective FID length ---    
    % the real one is included in the fitting function
    % scenario 1: intended apodization
    lcm.anaNspecC = lcm.nspecC;
    if flag.lcmSpecCut
        if lcm.specCut<lcm.anaNspecC
            lcm.anaNspecC = lcm.specCut;
        end
    end
    % scenario 2: intended ZF
    if flag.lcmSpecZf
        if lcm.specZf>lcm.anaNspecC
            lcm.anaNspecC = lcm.specZf;
        end
    end
    % scenario 3: basis FID shorter than target FID
    if lcm.anaNspecC>lcm.basis.ptsMin
        fprintf('-> ZF to %.0f pts applied to basis functions where necessary\n',lcm.anaNspecC);
        if flag.lcmSaveLog
            fprintf(lcm.log,'-> ZF to %.0f pts applied to basis functions where necessary\n',lcm.anaNspecC);
        end
    end
    % scenario 4: basis FID longer than target FID
    if lcm.anaNspecC<lcm.basis.ptsMax
        fprintf('-> (Some) basis functions truncated to %.0f pts\n',lcm.anaNspecC);
        if flag.lcmSaveLog
            fprintf(lcm.log,'-> (Some) basis functions truncated to %.0f pts\n',lcm.anaNspecC);
        end
    end
end

%--- target spectrum: spectral extraction ---
anaAllBin = zeros(1,lcm.anaNspecC);         % init global index vector for ppm ranges to be used (binary format)
anaMinI   = zeros(1,lcm.anaPpmN);           % init minimum ppm index vector
anaMaxI   = zeros(1,lcm.anaPpmN);           % init maximum ppm index vector
fprintf('\nSpectral range for LCM analysis:\n');
if flag.lcmSaveLog
    fprintf(lcm.log,'\nSpectral range for LCM analysis:\n');
end
for winCnt = 1:lcm.anaPpmN
    %--- extraction of spectral range ---
    [anaMinI(winCnt),anaMaxI(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_LCM_ExtractPpmRange(lcm.anaPpmMin(winCnt),lcm.anaPpmMax(winCnt),...
                                lcm.ppmCalib,lcm.sw,lcm.spec);
    if ~f_done
        fprintf('\n%s ->\nFrequency window extraction failed for section #2 (%.2f-%.2f ppm). Program aborted.\n',...
                winCnt,lcm.anaPpmMin(winCnt),lcm.anaPpmMax(winCnt))
        return
    end
    anaAllBin(anaMinI(winCnt):anaMaxI(winCnt)) = 1;
    
    %--- info printout ---
    fprintf('%.0f: %.3f..%.3f ppm (%.0f pts)\n',winCnt,lcm.anaPpmMin(winCnt),lcm.anaPpmMax(winCnt),anaMaxI(winCnt)-anaMinI(winCnt)+1)    
    if flag.lcmSaveLog    
        fprintf(lcm.log,'%.0f: %.3f..%.3f ppm (%.0f pts)\n',winCnt,lcm.anaPpmMin(winCnt),lcm.anaPpmMax(winCnt),anaMaxI(winCnt)-anaMinI(winCnt)+1);
    end
end
lcm.anaAllInd     = find(anaAllBin);                    % global index vector including all ppm ranges
lcm.anaAllIndN    = length(lcm.anaAllInd);              % number of points to be fitted
lcm.anaAllIndOnes = ones(lcm.anaAllIndN,1);             % ones vector (for improved performence of polynomial offset fit)
fprintf('Total: %.0f pts\n',lcm.anaAllIndN) 
if flag.lcmSaveLog    
    fprintf(lcm.log,'Total: %.0f pts\n',lcm.anaAllIndN);
end

%--- extract spectral range(s) in ppm for polynomial fit ---
if flag.lcmAnaPoly
    lcm.ppmVec = (-lcm.sw/2:lcm.sw/(lcm.anaNspecC-1):lcm.sw/2)' + lcm.ppmCalib;
    lcm.anaAllIndPpm = lcm.ppmVec(lcm.anaAllInd);
    if lcm.anaPolyOrder>1
        lcm.anaAllIndPpm2 = lcm.anaAllIndPpm.^2;
    end
    if lcm.anaPolyOrder>2
        lcm.anaAllIndPpm3 = lcm.anaAllIndPpm.^3;
    end
    if lcm.anaPolyOrder>3
        lcm.anaAllIndPpm4 = lcm.anaAllIndPpm.^4;
    end
    if lcm.anaPolyOrder>4
        lcm.anaAllIndPpm5 = lcm.anaAllIndPpm.^5;
    end
    if lcm.anaPolyOrder>5
        lcm.anaAllIndPpm6 = lcm.anaAllIndPpm.^6;
    end
    if lcm.anaPolyOrder>6
        lcm.anaAllIndPpm7 = lcm.anaAllIndPpm.^7;
    end
    if lcm.anaPolyOrder>7
        lcm.anaAllIndPpm8 = lcm.anaAllIndPpm.^8;
    end
    if lcm.anaPolyOrder>8
        lcm.anaAllIndPpm9 = lcm.anaAllIndPpm.^9;
    end
    if lcm.anaPolyOrder>9
        lcm.anaAllIndPpm10 = lcm.anaAllIndPpm.^10;
    end
end

%--- extract spectral range ---
if flag.lcmRealComplex          % real part only
    specZoom = real(lcm.spec(lcm.anaAllInd));
    fprintf('LCM analysis of REAL part applied\n');
    if flag.lcmSaveLog    
        fprintf(lcm.log,'LCM analysis of REAL part applied\n');
    end
else                            % complex signal
    specZoom = [real(lcm.spec(lcm.anaAllInd)); imag(lcm.spec(lcm.anaAllInd))];
    fprintf('LCM analysis of REAL & IMAGINARY parts applied\n');
    if flag.lcmSaveLog    
        fprintf(lcm.log,'LCM analysis of REAL & IMAGINARY parts applied\n');
    end
end

%--- keep LCM metabolite selection for result display ---
lcm.fit.appliedFit  = lcm.fit.applied;
lcm.fit.appliedFitN = lcm.fit.appliedN;

%--- info printout (command window) ---
fprintf('\nLCM starting values (%.0f metabolites):\n',lcm.fit.appliedN);
fprintf('Scaling:   %s\n',SP2_Vec2PrintStrSign(lcm.anaScale(lcm.fit.applied),3));
if flag.lcmAnaLb
    if flag.lcmLinkLb
        fprintf('LB (L):    %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLb(lcm.fit.applied),3));
    else
        fprintf('LB:        %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLb(lcm.fit.applied),3));
    end
end
if flag.lcmAnaGb
    if flag.lcmLinkGb
        fprintf('GB (L):    %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGb(lcm.fit.applied),3));
    else
        fprintf('GB:        %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGb(lcm.fit.applied),3));
    end
end
if flag.lcmAnaPhc0
    fprintf('PHC0:       %.2f deg\n',lcm.anaPhc0);
end
if flag.lcmAnaPhc1
    fprintf('PHC1:       %.2f deg\n',lcm.anaPhc1);
end
if flag.lcmAnaShift
    if flag.lcmLinkShift
        fprintf('Shift (L): %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShift(lcm.fit.applied),3));
    else
        fprintf('Shift:     %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShift(lcm.fit.applied),3));
    end
end
if flag.lcmAnaPoly
    if flag.lcmRealComplex          % real part only
        if lcm.anaPolyOrder==0
            fprintf('Poly (0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
        elseif lcm.anaPolyOrder==1
            fprintf('Poly (1st..0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
        elseif lcm.anaPolyOrder==2
            fprintf('Poly (2nd..0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
        elseif lcm.anaPolyOrder==3
            fprintf('Poly (3rd..0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
        else
            fprintf('Poly (%.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
        end
        if flag.verbose
            fprintf('Poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
        end
    else                            % complex FID and fit
        if lcm.anaPolyOrder==0
            fprintf('Real poly (0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            fprintf('Imag. poly (0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
        elseif lcm.anaPolyOrder==1
            fprintf('Real poly (1st..0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            fprintf('Imag. poly (1st..0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
        elseif lcm.anaPolyOrder==2
            fprintf('Real poly (2nd..0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            fprintf('Imag. poly (2nd..0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
        elseif lcm.anaPolyOrder==3
            fprintf('Real poly (3rd..0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            fprintf('Imag. poly (3rd..0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
        else
            fprintf('Real poly (%.0fth..0 order):  %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            fprintf('Imag. poly (%.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
        end
        if flag.verbose
            fprintf('Real poly (complete):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
            fprintf('Imag. poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag,5));
        end
    end
end
if flag.lcmAnaSpline
    if ~flag.lcmAnaPoly
        lcm.ppmVec = (-lcm.sw/2:lcm.sw/(lcm.anaNspecC-1):lcm.sw/2)' + lcm.ppmCalib;
        lcm.anaAllIndPpm = lcm.ppmVec(lcm.anaAllInd);
    end
    deltaPpm            = lcm.ppmVec(2)-lcm.ppmVec(1);                  % ppm spacing between spectral points
    pointStep           = round(1/(lcm.anaSplPtsPerPpm*deltaPpm));      % integer sparsity step size between points
    lcm.anaSplIndPpmN   = length(lcm.anaAllIndPpm(1:pointStep:end));    % number of spline points
    lcm.anaSplIndPpm    = lcm.anaAllIndPpm(1):(lcm.anaAllIndPpm(end)-lcm.anaAllIndPpm(1))/(lcm.anaSplIndPpmN-1):lcm.anaAllIndPpm(end);
    if flag.lcmRealComplex          % real part only
        lcm.anaSplAmpReal = zeros(1,lcm.anaSplIndPpmN);                 % (init) amplitude vector corresponding to vector of ppm positions
    else                            % complex FID and fit
        lcm.anaSplAmpReal = zeros(1,lcm.anaSplIndPpmN);                 % (init) amplitude vector corresponding to vector of ppm positions
        lcm.anaSplAmpImag = zeros(1,lcm.anaSplIndPpmN);                 % (init) amplitude vector corresponding to vector of ppm positions
    end
end

%--- info printout (log file) ---
if flag.lcmSaveLog    
    fprintf(lcm.log,'\nLCM starting values (%.0f metabolites):\n',lcm.fit.appliedN);
    fprintf(lcm.log,'Scaling:   %s\n',SP2_Vec2PrintStrSign(lcm.anaScale(lcm.fit.applied),3));
    if flag.lcmAnaLb
        if flag.lcmLinkLb
            fprintf(lcm.log,'LB (L):    %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLb(lcm.fit.applied),3));
        else
            fprintf(lcm.log,'LB:        %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLb(lcm.fit.applied),3));
        end
    end
    if flag.lcmAnaGb
        if flag.lcmLinkGb
            fprintf(lcm.log,'GB (L):    %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGb(lcm.fit.applied),3));
        else
            fprintf(lcm.log,'GB:        %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGb(lcm.fit.applied),3));
        end
    end
    if flag.lcmAnaPhc0
        fprintf(lcm.log,'PHC0:       %.2f deg\n',lcm.anaPhc0);
    end
    if flag.lcmAnaPhc1
        fprintf(lcm.log,'PHC1:       %.2f deg\n',lcm.anaPhc1);
    end
    if flag.lcmAnaShift
        if flag.lcmLinkShift
            fprintf(lcm.log,'Shift (L): %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShift(lcm.fit.applied),3));
        else
            fprintf(lcm.log,'Shift:     %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShift(lcm.fit.applied),3));
        end
    end
    if flag.lcmAnaPoly
        if flag.lcmRealComplex          % real part only
            if lcm.anaPolyOrder==0
                fprintf(lcm.log,'Poly (0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            elseif lcm.anaPolyOrder==1
                fprintf(lcm.log,'Poly (1st..0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            elseif lcm.anaPolyOrder==2
                fprintf(lcm.log,'Poly (2nd..0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            elseif lcm.anaPolyOrder==3
                fprintf(lcm.log,'Poly (3rd..0 order): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            else
                fprintf(lcm.log,'Poly (%.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
            end
            if flag.verbose
                fprintf(lcm.log,'Poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
            end
        else                            % complex FID and fit
            if lcm.anaPolyOrder==0
                fprintf(lcm.log,'Real poly (0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
                fprintf(lcm.log,'Imag. poly (0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
            elseif lcm.anaPolyOrder==1
                fprintf(lcm.log,'Real poly (1st..0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
                fprintf(lcm.log,'Imag. poly (1st..0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
            elseif lcm.anaPolyOrder==2
                fprintf(lcm.log,'Real poly (2nd..0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
                fprintf(lcm.log,'Imag. poly (2nd..0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
            elseif lcm.anaPolyOrder==3
                fprintf(lcm.log,'Real poly (3rd..0 order):   %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
                fprintf(lcm.log,'Imag. poly (3rd..0 order):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
            else
                fprintf(lcm.log,'Real poly (%.0fth..0 order):  %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end),5));
                fprintf(lcm.log,'Imag. poly (%.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end),5));
            end
            if flag.verbose
                fprintf(lcm.log,'Real poly (complete):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
                fprintf(lcm.log,'Imag. poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag,5));
            end
        end
    end
end         % of log file

%--- close log file before fit start ---
if flag.lcmSaveLog
    fclose(lcm.log);
end

%--- relative calibration frequency ---
lcm.calibRelHz = lcm.sf*(lcm.basis.ppmCalib-lcm.ppmCalib);          % relative ppmCalib shift

%--- index handling for fitting parameters and parameter init ---
% note that the order here corresponds to the order in which the various data
% manipulations are applied during processing, i.e. in the fitting function


%--- fit parameter setup ---
% index handling
indCnt = 0;                             % init fitting parameter counter
for bCnt = 1:lcm.fit.appliedN           % loop over selected basis functions
    %--- scaling ---
    indCnt = indCnt + 1;
    lcmAna.indScale(bCnt) = indCnt;
    if bCnt==1                          % init with first basis function
        lb         = 0;
        coeffStart = lcm.anaScale(lcm.fit.applied(bCnt));
        ub         = 1e5;
    else
        lb         = [lb 0];
        coeffStart = [coeffStart lcm.anaScale(lcm.fit.applied(bCnt))];
        ub         = [ub 1e5];
    end

    %--- Lorentzian line broadening ---
    if flag.lcmAnaLb
        if flag.lcmLinkLb               % single LB
            if bCnt==1                  % use first one (only)
                % index handling
                indCnt = indCnt + 1;
                lcmAna.indLb(bCnt) = indCnt;

                % parameter handling
                lb         = [lb lcm.fit.lbMin(lcm.fit.applied(bCnt))];
                coeffStart = [coeffStart lcm.anaLb(lcm.fit.applied(bCnt))];
                ub         = [ub lcm.fit.lbMax(lcm.fit.applied(bCnt))];
            end
        else                            % metabolite-specific LB
            % index handling
            indCnt = indCnt + 1;
            lcmAna.indLb(bCnt) = indCnt;

            % parameter handling
            lb         = [lb lcm.fit.lbMin(lcm.fit.applied(bCnt))];
            coeffStart = [coeffStart lcm.anaLb(lcm.fit.applied(bCnt))];
            ub         = [ub lcm.fit.lbMax(lcm.fit.applied(bCnt))];
        end
    end
    
    %--- Gaussian line broadening ---
    if flag.lcmAnaGb
        if flag.lcmLinkGb               % single Gb
            if bCnt==1                  % use first one (only)
                % index handling
                indCnt = indCnt + 1;
                lcmAna.indGb(bCnt) = indCnt;

                % parameter handling
                lb         = [lb lcm.fit.gbMin(lcm.fit.applied(bCnt))];
                coeffStart = [coeffStart lcm.anaGb(lcm.fit.applied(bCnt))];
                ub         = [ub lcm.fit.gbMax(lcm.fit.applied(bCnt))];
            end
        else                            % metabolite-specific GB
            % index handling
            indCnt = indCnt + 1;
            lcmAna.indGb(bCnt) = indCnt;

            % parameter handling
            lb         = [lb lcm.fit.gbMin(lcm.fit.applied(bCnt))];
            coeffStart = [coeffStart lcm.anaGb(lcm.fit.applied(bCnt))];
            ub         = [ub lcm.fit.gbMax(lcm.fit.applied(bCnt))];
        end
    end
    
    %--- frequency shift ---
    if flag.lcmAnaShift
        if flag.lcmLinkShift            % single frequency shift
            if bCnt==1                  % use first one (only)
                % index handling
                indCnt = indCnt + 1;
                lcmAna.indShift(bCnt) = indCnt;

                % parameter handling
                lb         = [lb lcm.fit.shiftMin(lcm.fit.applied(bCnt))];
                coeffStart = [coeffStart lcm.anaShift(lcm.fit.applied(bCnt))];
                ub         = [ub lcm.fit.shiftMax(lcm.fit.applied(bCnt))];
            end
        else                            % metabolite-specific shift
            % index handling
            indCnt = indCnt + 1;
            lcmAna.indShift(bCnt) = indCnt;

            % parameter handling
            lb         = [lb lcm.fit.shiftMin(lcm.fit.applied(bCnt))];
            coeffStart = [coeffStart lcm.anaShift(lcm.fit.applied(bCnt))];
            ub         = [ub lcm.fit.shiftMax(lcm.fit.applied(bCnt))];
        end
    end
end             % basis functions (bCnt)

%--- zero order phase ---
if flag.lcmAnaPhc0
    % index handling
    indCnt = indCnt + 1;
    lcmAna.indPhc0 = indCnt;

    % parameter handling
    lb         = [lb -359.99];
    coeffStart = [coeffStart lcm.anaPhc0];
    ub         = [ub 360];
end

%--- first order phase ---
if flag.lcmAnaPhc1
    % index handling
    indCnt = indCnt + 1;
    lcmAna.indPhc1 = indCnt;

    % parameter handling
    lb         = [lb -1e5];
    coeffStart = [coeffStart lcm.anaPhc1];
    ub         = [ub 1e5];
end

%--- polynomial baseline ---
%--- real or complex FID and fit ---
if flag.lcmAnaPoly
    % index handling
    indCnt = indCnt + 1;
    lcmAna.indPoly = indCnt;                    % 1st index of polynomial coefficients
    
    % parameter handling: 
    lb         = [lb -1e10*ones(1,lcm.anaPolyOrder+1)];
    coeffStart = [coeffStart lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end)];     % (reversed) nth..0 order + offset
    ub         = [ub 1e10*ones(1,lcm.anaPolyOrder+1)];
end
%--- complex FID and analysis ---
if flag.lcmAnaPoly && ~flag.lcmRealComplex
    % index handling
    indCnt = indCnt + lcm.anaPolyOrder+1;       % index step according to number of real polynomial elements
    lcmAna.indPolyImag = indCnt;                % 1st index of polynomial coefficients
    
    % parameter handling
    lb         = [lb -1e10*ones(1,lcm.anaPolyOrder+1)];
    coeffStart = [coeffStart lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end)];     % (reversed) nth..0 order + offset
    ub         = [ub 1e10*ones(1,lcm.anaPolyOrder+1)];
end

%--- spline baseline ---
%--- real or complex FID and fit ---
if flag.lcmAnaSpline
    % index handling
    if flag.lcmAnaPoly
        indCnt = indCnt + lcm.anaPolyOrder+1;
    else
        indCnt = indCnt + 1;
    end
    lcmAna.indSplReal = indCnt;                         % 1st index of real spline amplitude vector
    
    % parameter handling: 
    lb         = [lb -1e10*ones(1,lcm.anaSplIndPpmN)];
    coeffStart = [coeffStart lcm.anaSplAmpReal];        
    ub         = [ub 1e10*ones(1,lcm.anaSplIndPpmN)];
end
%--- complex FID and analysis ---
if flag.lcmAnaSpline && ~flag.lcmRealComplex
    % index handling
    indCnt = indCnt + lcm.anaSplIndPpmN;                % index step according to number of real amplitudes
    lcmAna.indSplImag = indCnt;                         % 1st index of complex spline amplitude vector
    
    % parameter handling
    lb         = [lb -1e10*ones(1,lcm.anaSplIndPpmN)];
    coeffStart = [coeffStart lcm.anaSplAmpImag];        
    ub         = [ub 1e10*ones(1,lcm.anaSplIndPpmN)];
end

%--- least-squares fit ---
% default of MaxFunEvals = 5400, note that there might be multiple function evaluations per iteration
if flag.verbose
    opt = optimset('Display','iter','TolFun',lcm.fit.tolFun,'MaxIter',lcm.fit.maxIter,'MaxFunEvals',2e6);
else
    opt = optimset('Display','off','TolFun',lcm.fit.tolFun,'MaxIter',lcm.fit.maxIter,'MaxFunEvals',2e6);
end
% note that input/output can be real or complex based on the selection of flag.lcmRealComplex
[coeffFit,res2norm,residual,exitflag,output,lambda,jacobian] = ...
    lsqcurvefit('SP2_LCM_AnaFitFct',coeffStart,[],specZoom,lb,ub,opt);


%--- write fit opt to log file ---
if flag.lcmSaveLog
    lcm.log = fopen(lcm.logPath,'a');               % reopen for result log
end

%--- fit diagnostics ---
if flag.verbose
    SP2_Loc_FitDiagnostics(exitflag,output)
end

%--- error analysis ---
[coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian,specZoom);

%--- parameter assignment ---
for bCnt = 1:lcm.fit.appliedN
    lcm.anaScale(lcm.fit.applied(bCnt))    = coeffFit(lcmAna.indScale(bCnt));
    lcm.anaScaleErr(lcm.fit.applied(bCnt)) = coeffErr(lcmAna.indScale(bCnt));
    if flag.lcmAnaLb
        if flag.lcmLinkLb               % single LB
            if bCnt==1                  % use first one (only)
                lcm.anaLb(lcm.fit.applied(bCnt))    = coeffFit(lcmAna.indLb(bCnt));                 % retrieve single LB coefficient
                lcm.anaLb(lcm.fit.applied)          = lcm.anaLb(lcm.fit.applied(bCnt));             % copy to all applied
                lcm.anaLbErr(lcm.fit.applied(bCnt)) = coeffErr(lcmAna.indLb(bCnt));                 % retrieve single LB coefficient
                lcm.anaLbErr(lcm.fit.applied)       = lcm.anaLbErr(lcm.fit.applied(bCnt));          % copy to all applied
            end
        else                            % metabolite-specific LB
            lcm.anaLb(lcm.fit.applied(bCnt))    = coeffFit(lcmAna.indLb(bCnt));                     % transfer metabolite-specific LB
            lcm.anaLbErr(lcm.fit.applied(bCnt)) = coeffErr(lcmAna.indLb(bCnt));                     % transfer metabolite-specific LB
        end
    end
    if flag.lcmAnaGb
        if flag.lcmLinkGb               % single GB
            if bCnt==1                  % use first one (only)
                lcm.anaGb(lcm.fit.applied(bCnt))    = coeffFit(lcmAna.indGb(bCnt));                 % retrieve single LB coefficient
                lcm.anaGb(lcm.fit.applied)          = lcm.anaGb(lcm.fit.applied(bCnt));             % copy to all applied
                lcm.anaGbErr(lcm.fit.applied(bCnt)) = coeffErr(lcmAna.indGb(bCnt));                 % retrieve single LB coefficient
                lcm.anaGbErr(lcm.fit.applied)       = lcm.anaGbErr(lcm.fit.applied(bCnt));          % copy to all applied
            end
        else                            % metabolite-specific GB
            lcm.anaGb(lcm.fit.applied(bCnt))    = coeffFit(lcmAna.indGb(bCnt));                     % transfer metabolite-specific LB
            lcm.anaGbErr(lcm.fit.applied(bCnt)) = coeffErr(lcmAna.indGb(bCnt));                     % transfer metabolite-specific LB
        end
    end
    if flag.lcmAnaShift
        if flag.lcmLinkShift            % single shift
            if bCnt==1                  % use first one (only)
                lcm.anaShift(lcm.fit.applied(bCnt))    = coeffFit(lcmAna.indShift(bCnt));           % retrieve single shift coefficient
                lcm.anaShift(lcm.fit.applied)          = lcm.anaShift(lcm.fit.applied(bCnt));       % copy to all applied
                lcm.anaShiftErr(lcm.fit.applied(bCnt)) = coeffErr(lcmAna.indShift(bCnt));           % retrieve single shift coefficient
                lcm.anaShiftErr(lcm.fit.applied)       = lcm.anaShiftErr(lcm.fit.applied(bCnt));    % copy to all applied
            end
        else                            % metabolite-specific shift
            lcm.anaShift(lcm.fit.applied(bCnt))    = coeffFit(lcmAna.indShift(bCnt));               % transfer metabolite-specific shift
            lcm.anaShiftErr(lcm.fit.applied(bCnt)) = coeffErr(lcmAna.indShift(bCnt));               % transfer metabolite-specific shift
        end
    end
end
if flag.lcmAnaPhc0
    lcm.anaPhc0    = coeffFit(lcmAna.indPhc0);
    lcm.anaPhc0Err = coeffErr(lcmAna.indPhc0);
end
if flag.lcmAnaPhc1
    lcm.anaPhc1    = coeffFit(lcmAna.indPhc1);
    lcm.anaPhc1Err = coeffErr(lcmAna.indPhc1);
end
if flag.lcmAnaPoly                                      % real or complex (i.e. both real & imaginary)
    lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end)    = coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder);
    lcm.anaPolyCoeffErr(end-lcm.anaPolyOrder:end) = coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder);
else
    lcm.anaPolyCoeff(end-lcm.anaPolyOrder:end)    = 0;
    lcm.anaPolyCoeffErr(end-lcm.anaPolyOrder:end) = 0;
end
if flag.lcmAnaPoly && ~flag.lcmRealComplex              % complex FID and fit
    lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end)    = coeffFit(lcmAna.indPolyImag:lcmAna.indPolyImag+lcm.anaPolyOrder);
    lcm.anaPolyCoeffImagErr(end-lcm.anaPolyOrder:end) = coeffErr(lcmAna.indPolyImag:lcmAna.indPolyImag+lcm.anaPolyOrder);
else
    lcm.anaPolyCoeffImag(end-lcm.anaPolyOrder:end)    = 0;
    lcm.anaPolyCoeffImagErr(end-lcm.anaPolyOrder:end) = 0;
end
if flag.lcmAnaSpline
    lcm.anaAllSplineReal = fnval(lcm.sp1, lcm.anaAllIndPpm);
    if ~flag.lcmRealComplex                                    % complex FID and fit
        lcm.anaAllSplineImag = fnval(lcm.sp2, lcm.anaAllIndPpm);
    end
    
%     lcm.anaAllSplineReal = spline(lcm.anaSplIndPpm,coeffFit(lcmAna.indSplReal:lcmAna.indSplReal+lcm.anaSplIndPpmN-1),lcm.anaAllIndPpm);
%     if ~flag.lcmRealComplex                                    % complex FID and fit
%         lcm.anaAllSplineImag = spline(lcm.anaSplIndPpm,coeffFit(lcmAna.indSplImag:lcmAna.indSplImag+lcm.anaSplIndPpmN-1),lcm.anaAllIndPpm);
%     end
end

%--- info printout ---
fprintf('\nLCM result:\n');
fprintf('Scaling:   %s\n',SP2_Vec2PrintStrSign(lcm.anaScale(lcm.fit.applied),3));
if flag.lcmAnaLb
    fprintf('LB:        %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLb(lcm.fit.applied),3));
end
if flag.lcmAnaGb
    fprintf('GB:        %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGb(lcm.fit.applied),3));
end
if flag.lcmAnaPhc0
    fprintf('PHC0:       %.2f deg\n',lcm.anaPhc0);
end
if flag.lcmAnaPhc1
    fprintf('PHC1:       %.2f deg\n',lcm.anaPhc1);
end
if flag.lcmAnaShift
    fprintf('Shift:     %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShift(lcm.fit.applied),3));
end
if flag.lcmAnaPoly
    if flag.lcmRealComplex          % real part only
        if lcm.anaPolyOrder==0
            fprintf('Poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
        elseif lcm.anaPolyOrder==1
            fprintf('Poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
        elseif lcm.anaPolyOrder==2
            fprintf('Poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
        elseif lcm.anaPolyOrder==3
            fprintf('Poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
        else
            fprintf('Poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
        end
        if flag.verbose
            fprintf('Poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
        end
    else                            % real FID and fit
        if lcm.anaPolyOrder==0
            fprintf('Real poly (fit, 0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
        elseif lcm.anaPolyOrder==1
            fprintf('Real poly (fit, 1st..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
        elseif lcm.anaPolyOrder==2
            fprintf('Real poly (fit, 2nd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
        elseif lcm.anaPolyOrder==3
            fprintf('Real poly (fit, 3rd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
        else
            fprintf('Real poly (fit, %.0fth..0 order):  %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
        end
        if flag.verbose
            fprintf('Real poly (complete):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
            fprintf('Imag. poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag,5));
        end
    end
end

%--- info printout (log file ---
if flag.lcmSaveLog
    fprintf(lcm.log,'\nLCM result:\n');
    fprintf(lcm.log,'Scaling:   %s\n',SP2_Vec2PrintStrSign(lcm.anaScale(lcm.fit.applied),3));
    if flag.lcmAnaLb
        fprintf(lcm.log,'LB:        %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLb(lcm.fit.applied),3));
    end
    if flag.lcmAnaGb
        fprintf(lcm.log,'GB:        %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGb(lcm.fit.applied),3));
    end
    if flag.lcmAnaPhc0
        fprintf(lcm.log,'PHC0:       %.2f deg\n',lcm.anaPhc0);
    end
    if flag.lcmAnaPhc1
        fprintf(lcm.log,'PHC1:       %.2f deg\n',lcm.anaPhc1);
    end
    if flag.lcmAnaShift
        fprintf(lcm.log,'Shift:     %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShift(lcm.fit.applied),3));
    end
    if flag.lcmAnaPoly
        if flag.lcmRealComplex          % real part only
            if lcm.anaPolyOrder==0
                fprintf(lcm.log,'Poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
            elseif lcm.anaPolyOrder==1
                fprintf(lcm.log,'Poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
            elseif lcm.anaPolyOrder==2
                fprintf(lcm.log,'Poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
            elseif lcm.anaPolyOrder==3
                fprintf(lcm.log,'Poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
            else
                fprintf(lcm.log,'Poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:end),5));
            end
            if flag.verbose
                fprintf(lcm.log,'Poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
            end
        else                            % real FID and fit
            if lcm.anaPolyOrder==0
                fprintf(lcm.log,'Real poly (fit, 0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
            elseif lcm.anaPolyOrder==1
                fprintf(lcm.log,'Real poly (fit, 1st..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
            elseif lcm.anaPolyOrder==2
                fprintf(lcm.log,'Real poly (fit, 2nd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
            elseif lcm.anaPolyOrder==3
                fprintf(lcm.log,'Real poly (fit, 3rd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
            else
                fprintf(lcm.log,'Real poly (fit, %.0fth..0 order):  %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffFit(lcmAna.indPolyImag:end),5));
            end
            if flag.verbose
                fprintf(lcm.log,'Real poly (complete):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeff,5));
                fprintf(lcm.log,'Imag. poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImag,5));
            end
        end
    end
end             % of log file


%--- info printout: Hessian error analysis ---
fprintf('\nHessian error analysis:\n');
fprintf('Scaling:   %s\n',SP2_Vec2PrintStrSign(lcm.anaScaleErr(lcm.fit.applied),3));
if flag.lcmAnaLb
    fprintf('LB:        %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLbErr(lcm.fit.applied),3));
end
if flag.lcmAnaGb
    fprintf('GB:        %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGbErr(lcm.fit.applied),3));
end
if flag.lcmAnaPhc0
    fprintf('PHC0:       %.2f deg\n',lcm.anaPhc0Err);
end
if flag.lcmAnaPhc1
    fprintf('PHC1:       %.2f deg\n',lcm.anaPhc1Err);
end
if flag.lcmAnaShift
    fprintf('Shift:     %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShiftErr(lcm.fit.applied),3));
end
if flag.lcmAnaPoly
    if flag.lcmRealComplex          % real part only
        if lcm.anaPolyOrder==0
            fprintf('Poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
        elseif lcm.anaPolyOrder==1
            fprintf('Poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
        elseif lcm.anaPolyOrder==2
            fprintf('Poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
        elseif lcm.anaPolyOrder==3
            fprintf('Poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
        else
            fprintf('Poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
        end
        fprintf('Poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffErr,5));
    else                            % real FID and fit
        if lcm.anaPolyOrder==0
            fprintf('Real poly (fit, 0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
        elseif lcm.anaPolyOrder==1
            fprintf('Real poly (fit, 1st..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
        elseif lcm.anaPolyOrder==2
            fprintf('Real poly (fit, 2nd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
        elseif lcm.anaPolyOrder==3
            fprintf('Real poly (fit, 3rd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
        else
            fprintf('Real poly (fit, %.0fth..0 order):  %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
            fprintf('Imag. poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
        end
        fprintf('Real poly (complete):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffErr,5));
        fprintf('Imag. poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImagErr,5));
    end
end


%--- info printout: Hessian error analysis (log file) ---
if flag.lcmSaveLog
    fprintf(lcm.log,'\nHessian error analysis:\n');
    fprintf(lcm.log,'Scaling:   %s\n',SP2_Vec2PrintStrSign(lcm.anaScaleErr(lcm.fit.applied),3));
    if flag.lcmAnaLb
        fprintf(lcm.log,'LB:        %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaLbErr(lcm.fit.applied),3));
    end
    if flag.lcmAnaGb
        fprintf(lcm.log,'GB:        %s Hz^2\n',SP2_Vec2PrintStrSign(lcm.anaGbErr(lcm.fit.applied),3));
    end
    if flag.lcmAnaPhc0
        fprintf(lcm.log,'PHC0:       %.2f deg\n',lcm.anaPhc0Err);
    end
    if flag.lcmAnaPhc1
        fprintf(lcm.log,'PHC1:       %.2f deg\n',lcm.anaPhc1Err);
    end
    if flag.lcmAnaShift
        fprintf(lcm.log,'Shift:     %s Hz\n',SP2_Vec2PrintStrSign(lcm.anaShiftErr(lcm.fit.applied),3));
    end
    if flag.lcmAnaPoly
        if flag.lcmRealComplex          % real part only
            if lcm.anaPolyOrder==0
                fprintf(lcm.log,'Poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
            elseif lcm.anaPolyOrder==1
                fprintf(lcm.log,'Poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
            elseif lcm.anaPolyOrder==2
                fprintf(lcm.log,'Poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
            elseif lcm.anaPolyOrder==3
                fprintf(lcm.log,'Poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
            else
                fprintf(lcm.log,'Poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:end),5));
            end
            fprintf(lcm.log,'Poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffErr,5));
        else                            % real FID and fit
            if lcm.anaPolyOrder==0
                fprintf(lcm.log,'Real poly (fit, 0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
            elseif lcm.anaPolyOrder==1
                fprintf(lcm.log,'Real poly (fit, 1st..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 1st..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
            elseif lcm.anaPolyOrder==2
                fprintf(lcm.log,'Real poly (fit, 2nd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 2nd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
            elseif lcm.anaPolyOrder==3
                fprintf(lcm.log,'Real poly (fit, 3rd..0 order):  %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, 3rd..0 order): %s\n',SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
            else
                fprintf(lcm.log,'Real poly (fit, %.0fth..0 order):  %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPoly:lcmAna.indPoly+lcm.anaPolyOrder),5));
                fprintf(lcm.log,'Imag. poly (fit, %.0fth..0 order): %s\n',lcm.anaPolyOrder,SP2_Vec2PrintStrSign(coeffErr(lcmAna.indPolyImag:end),5));
            end
            fprintf(lcm.log,'Real poly (complete):  %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffErr,5));
            fprintf(lcm.log,'Imag. poly (complete): %s\n',SP2_Vec2PrintStrSign(lcm.anaPolyCoeffImagErr,5));
        end
    end
end             % of log file

%--- find NaN in Hessian error analysis and replace for summary display ---
% note that the original 'NaN' are shown as part of display of the detailed
% / original fit outcome
if any(isnan(coeffErr))
    fprintf('\nWarning: %.0f ''NaN'' found in Hessian error analysis.\n\n',sum(isnan(coeffErr)));
    
    %--- assign value exceedin the respective display limit ---
    if any(isnan(lcm.anaScaleErr))
        lcm.anaScaleErr(isnan(lcm.anaScaleErr)) = max(666,lcm.fit.errLimAmpMax);
    end
    if any(isnan(lcm.anaLbErr))
        lcm.anaLbErr(isnan(lcm.anaLbErr))       = max(666,lcm.fit.errLimLbMax);
    end
    if any(isnan(lcm.anaGbErr))
        lcm.anaGbErr(isnan(lcm.anaGbErr))       = max(666,lcm.fit.errLimGbMax);
    end
    if any(isnan(lcm.anaShiftErr))
        lcm.anaShiftErr(isnan(lcm.anaShiftErr)) = max(666,lcm.fit.errLimShiftMax);
    end
    if any(isnan(lcm.anaPhc0Err))
        lcm.anaPhc0Err(isnan(lcm.anaPhc0Err))   = 666;
    end
    if any(isnan(lcm.anaPhc1Err))
        lcm.anaPhc1Err(isnan(lcm.anaPhc1Err))   = 666;
    end
end


%--- default processing (without polynomial) ---
if ~SP2_LCM_ProcResultData
    fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- result visualization ---
if f_plot
    if ~SP2_LCM_PlotResultSpecSummary(1)
        return
    end
end

%--- analysis update ---
SP2_LCM_FitFigureUpdate

%--- update fitting window ---
SP2_LCM_FitDetailsWinUpdate

%--- extract names of the applied metabolites ---
lcm.anaMetabs = {};
for mCnt = 1:lcm.fit.appliedN
    lcm.anaMetabs{mCnt} = lcm.basis.data{lcm.fit.applied(mCnt)}{1};    % retrieve metabolite names
end

%--- CRLB analysis ---
if ~SP2_LCM_AnaDoCalcCRLB(0)
    return
end

%--- info printout ---
fprintf('\nLCM ANALYSIS SUMMARY:\n');
if flag.verbose
    fprintf('(errors as CRLB / Hessian of LSQ)\n');
else
    fprintf('(errors as CRLB)\n');
end
if flag.lcmSaveLog
    fprintf(lcm.log,'\nLCM ANALYSIS SUMMARY:\n');
    if flag.verbose
        fprintf(lcm.log,'(errors as CRLB / Hessian of LSQ)\n');
    else
        fprintf(lcm.log,'(errors as CRLB)\n');
    end
end

% extract the NAA concentration
naaConc = -1;       % init with unrealistic number
for mCnt = 1:lcm.fit.appliedN
    if strcmp(lcm.anaMetabs{mCnt},'NAA')
        naaConc = lcm.anaScale(lcm.fit.applied(mCnt));
    end
end
% determine longest metabolite name
mStrMax = 0;
for mCnt = 1:lcm.fit.appliedN
    if length(lcm.anaMetabs{mCnt})>mStrMax
        mStrMax = length(lcm.anaMetabs{mCnt});
    end
end

% printout: individual metabolites to command window
for mCnt = 1:lcm.fit.appliedN
    if naaConc<0        % no NAA found
        if flag.verbose
            if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                fprintf('%s:%s%.3f a.u. (%.0f+/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax)
            elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                fprintf('%s:%s%.3f a.u. (<%.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin)
            else
%                 fprintf('%s:%s%.3f a.u. (%.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
%                         lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.crlbAmp(mCnt))
                fprintf('%s:%s%.3f a.u. (%.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        lcm.anaScale(lcm.fit.applied(mCnt)),100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)))
            end
            if 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))>lcm.fit.errLimAmpMax
                fprintf('%.0f+%%)',lcm.fit.errLimAmpMax);
            elseif 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                fprintf('<%.1f%%)',lcm.fit.errLimAmpMin);
            else
                fprintf('%.1f%%)',100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt)));
            end
        else
            if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                fprintf('%s:%s%.3f a.u. (%.0f+%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax)
            elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                fprintf('%s:%s%.3f a.u. (<%.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin)
            else
%                 fprintf('%s:%s%.3f a.u. (%.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
%                         lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.crlbAmp(mCnt))
                fprintf('%s:%s%.3f a.u. (%.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        lcm.anaScale(lcm.fit.applied(mCnt)),100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)))
            end
        end
    else                % assuming 10mM NAA
        if flag.verbose
            if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                fprintf('%s:%s%.2f mM (%.3f, %.0f+/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax)   
            elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                fprintf('%s:%s%.2f mM (%.3f, <%.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin)   
            else
%                 fprintf('%s:%s%.2f mM (%.3f, %.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
%                         10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.crlbAmp(mCnt))   
                fprintf('%s:%s%.2f mM (%.3f, %.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),...
                        100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)))   
            end
            if 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))>lcm.fit.errLimAmpMax
                fprintf('%.0f+%%)',lcm.fit.errLimAmpMax)   
            elseif 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                fprintf('<%.1f%%)',lcm.fit.errLimAmpMin)   
            else
                fprintf('%.1f%%)',100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt)))   
            end
        else
            if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                fprintf('%s:%s%.2f mM (%.3f, %.0f+%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax)   
            elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                fprintf('%s:%s%.2f mM (%.3f, <%.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin)   
            else
%                 fprintf('%s:%s%.2f mM (%.3f, %.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
%                         10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.crlbAmp(mCnt))   
                fprintf('%s:%s%.2f mM (%.3f, %.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                        10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),...
                        100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)))   
            end
        end
    end
    if flag.lcmAnaLb && ~flag.lcmLinkLb
        if flag.verbose
            if lcm.fit.crlbLb(mCnt)>lcm.fit.errLimLbMax
                fprintf(' / LB %.1f Hz (%.0f+/',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMax)   
            elseif lcm.fit.crlbLb(mCnt)<lcm.fit.errLimLbMin
                fprintf(' / LB %.1f Hz (<%.1f/',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMin)   
            else
                fprintf(' / LB %.1f Hz (%.1f/',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.crlbLb(mCnt))   
            end
            if lcm.anaLbErr(lcm.fit.applied(mCnt))>lcm.fit.errLimLbMax
                fprintf('%.0f+ Hz)',lcm.fit.errLimLbMax)   
            elseif lcm.anaLbErr(lcm.fit.applied(mCnt))<lcm.fit.errLimLbMin
                fprintf('<%.1f Hz)',lcm.fit.errLimLbMin)   
            else
                fprintf('%.1f Hz)',lcm.anaLbErr(lcm.fit.applied(mCnt)))   
            end
        else
            if lcm.fit.crlbLb(mCnt)>lcm.fit.errLimLbMax
                fprintf(' / LB %.1f Hz (%.0f+ Hz)',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMax)   
            elseif lcm.fit.crlbLb(mCnt)<lcm.fit.errLimLbMin
                fprintf(' / LB %.1f Hz (<%.1f Hz)',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMin)   
            else
                fprintf(' / LB %.1f Hz (%.1f Hz)',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.crlbLb(mCnt))   
            end
        end
    end
    if flag.lcmAnaGb && ~flag.lcmLinkGb
        if flag.verbose
            if lcm.fit.crlbGb(mCnt)>lcm.fit.errLimGbMax
                fprintf(' / GB %.1f Hz^2 (%.0f+/',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMax)   
            elseif lcm.fit.crlbGb(mCnt)<lcm.fit.errLimGbMin
                fprintf(' / GB %.1f Hz^2 (<%.1f/',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMin)   
            else
                fprintf(' / GB %.1f Hz^2 (%.1f/',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.crlbGb(mCnt));
            end
            if lcm.anaGbErr(lcm.fit.applied(mCnt))>lcm.fit.errLimGbMax
                fprintf('%.0f+ Hz^2)',lcm.fit.errLimGbMax)   
            elseif lcm.anaGbErr(lcm.fit.applied(mCnt))<lcm.fit.errLimGbMin
                fprintf('<%.1f Hz^2)',lcm.fit.errLimGbMin)   
            else
                fprintf('%.1f Hz^2)',lcm.anaGbErr(lcm.fit.applied(mCnt)));
            end
        else
            if lcm.fit.crlbGb(mCnt)>lcm.fit.errLimGbMax
                fprintf(' / GB %.1f Hz^2 (%.0f+ Hz^2)',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMax)   
            elseif lcm.fit.crlbGb(mCnt)<lcm.fit.errLimGbMin
                fprintf(' / GB %.1f Hz^2 (<%.1f Hz^2)',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMin)   
            else
                fprintf(' / GB %.1f Hz^2 (%.1f Hz^2)',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.crlbGb(mCnt));
            end
        end
    end
    if flag.lcmAnaShift && ~flag.lcmLinkShift
        if flag.verbose
            if lcm.fit.crlbShift(mCnt)>lcm.fit.errLimShiftMax
                fprintf(' / Shift %.2f Hz (%.0f+/',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMax)   
            elseif lcm.fit.crlbShift(mCnt)<lcm.fit.errLimShiftMin
                fprintf(' / Shift %.2f Hz (<%.1f/',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMin)   
            else
                fprintf(' / Shift %.2f Hz (%.1f/',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.crlbShift(mCnt));
            end
            if lcm.anaShiftErr(lcm.fit.applied(mCnt))>lcm.fit.errLimShiftMax
                fprintf('%.0f+ Hz)',lcm.fit.errLimShiftMax)   
            elseif lcm.anaShiftErr(lcm.fit.applied(mCnt))<lcm.fit.errLimShiftMin
                fprintf('<%.1f Hz)',lcm.fit.errLimShiftMin)   
            else
                fprintf('%.1f Hz)',lcm.anaShiftErr(lcm.fit.applied(mCnt)));
            end
        else
            if lcm.fit.crlbShift(mCnt)>lcm.fit.errLimShiftMax
                fprintf(' / Shift %.2f Hz (%.0f+ Hz)',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMax)   
            elseif lcm.fit.crlbShift(mCnt)<lcm.fit.errLimShiftMin
                fprintf(' / Shift %.2f Hz (<%.1f Hz)',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMin)   
            else
                fprintf(' / Shift %.2f Hz (%.1f Hz)',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.crlbShift(mCnt));
            end
        end
    end
    fprintf('\n');
end

% printout: individual metabolites to log file
if flag.lcmSaveLog
    for mCnt = 1:lcm.fit.appliedN
        if naaConc<0        % no NAA found
            if flag.verbose
                if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                    fprintf(lcm.log,'%s:%s%.3f a.u. (%.0f+/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax);
                elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                    fprintf(lcm.log,'%s:%s%.3f a.u. (<%.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin);
                else
                    fprintf(lcm.log,'%s:%s%.3f a.u. (%.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            lcm.anaScale(lcm.fit.applied(mCnt)),100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)));
                end
                if 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))>lcm.fit.errLimAmpMax
                    fprintf(lcm.log,'%.0f+%%)',lcm.fit.errLimAmpMax);
                elseif 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                    fprintf(lcm.log,'<%.1f%%)',lcm.fit.errLimAmpMin);
                else
                    fprintf(lcm.log,'%.1f%%)',100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt)));
                end
            else
                if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                    fprintf(lcm.log,'%s:%s%.3f a.u. (%.0f+%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax);
                elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                    fprintf(lcm.log,'%s:%s%.3f a.u. (<%.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin);
                else
                    fprintf(lcm.log,'%s:%s%.3f a.u. (%.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            lcm.anaScale(lcm.fit.applied(mCnt)),100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)));
                end
            end
        else                % assuming 10mM NAA
            if flag.verbose
                if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                    fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.0f+/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax);  
                elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                    fprintf(lcm.log,'%s:%s%.2f mM (%.3f, <%.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin);
                else
                    fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.1f/',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),...
                            100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)));
                end
                if 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))>lcm.fit.errLimAmpMax
                    fprintf(lcm.log,'%.0f+%%)',lcm.fit.errLimAmpMax);  
                elseif 100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                    fprintf(lcm.log,'<%.1f%%)',lcm.fit.errLimAmpMin);
                else
                    fprintf(lcm.log,'%.1f%%)',100*lcm.anaScaleErr(lcm.fit.applied(mCnt))/lcm.anaScale(lcm.fit.applied(mCnt)));
                end
            else
                if 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))>=lcm.fit.errLimAmpMax
                    fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.0f+%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMax);  
                elseif 100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt))<lcm.fit.errLimAmpMin
                    fprintf(lcm.log,'%s:%s%.2f mM (%.3f, <%.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),lcm.fit.errLimAmpMin);
                else
                    fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.1f%%)',lcm.anaMetabs{mCnt},SP2_NSpaces(mStrMax-length(lcm.anaMetabs{mCnt})+2),...
                            10*lcm.anaScale(lcm.fit.applied(mCnt))/naaConc,lcm.anaScale(lcm.fit.applied(mCnt)),...
                            100*lcm.fit.crlbAmp(mCnt)/lcm.anaScale(lcm.fit.applied(mCnt)));
                end
            end
        end
        if flag.lcmAnaLb && ~flag.lcmLinkLb
            if flag.verbose
                if lcm.fit.crlbLb(mCnt)>lcm.fit.errLimLbMax
                    fprintf(lcm.log,' / LB %.1f Hz (%.0f+/',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMax); 
                elseif lcm.fit.crlbLb(mCnt)<lcm.fit.errLimLbMin
                    fprintf(lcm.log,' / LB %.1f Hz (<%.1f/',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMin);
                else
                    fprintf(lcm.log,' / LB %.1f Hz (%.1f/',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.crlbLb(mCnt));
                end
                if lcm.anaLbErr(lcm.fit.applied(mCnt))>lcm.fit.errLimLbMax
                    fprintf(lcm.log,'%.0f+ Hz)',lcm.fit.errLimLbMax); 
                elseif lcm.anaLbErr(lcm.fit.applied(mCnt))<lcm.fit.errLimLbMin
                    fprintf(lcm.log,'<%.1f Hz)',lcm.fit.errLimLbMin);
                else
                    fprintf(lcm.log,'%.1f Hz)',lcm.anaLbErr(lcm.fit.applied(mCnt)));
                end
            else
                if lcm.fit.crlbLb(mCnt)>lcm.fit.errLimLbMax
                    fprintf(lcm.log,' / LB %.1f Hz (%.0f+ Hz)',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMax); 
                elseif lcm.fit.crlbLb(mCnt)<lcm.fit.errLimLbMin
                    fprintf(lcm.log,' / LB %.1f Hz (<%.1f Hz)',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.errLimLbMin);
                else
                    fprintf(lcm.log,' / LB %.1f Hz (%.1f Hz)',lcm.anaLb(lcm.fit.applied(mCnt)),lcm.fit.crlbLb(mCnt));
                end
            end
        end
        if flag.lcmAnaGb && ~flag.lcmLinkGb
            if flag.verbose
                if lcm.fit.crlbGb(mCnt)>lcm.fit.errLimGbMax
                    fprintf(lcm.log,' / GB %.1f Hz^2 (%.0f+/',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMax); 
                elseif lcm.fit.crlbGb(mCnt)<lcm.fit.errLimGbMin
                    fprintf(lcm.log,' / GB %.1f Hz^2 (<%.1f/',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMin);
                else
                    fprintf(lcm.log,' / GB %.1f Hz^2 (%.1f/',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.crlbGb(mCnt));
                end
                if lcm.anaGbErr(lcm.fit.applied(mCnt))>lcm.fit.errLimGbMax
                    fprintf(lcm.log,'%.0f+ Hz^2)',lcm.fit.errLimGbMax); 
                elseif lcm.anaGbErr(lcm.fit.applied(mCnt))<lcm.fit.errLimGbMin
                    fprintf(lcm.log,'<%.1f Hz^2)',lcm.fit.errLimGbMin);
                else
                    fprintf(lcm.log,'%.1f Hz^2)',lcm.anaGbErr(lcm.fit.applied(mCnt)));
                end
            else
                if lcm.fit.crlbGb(mCnt)>lcm.fit.errLimGbMax
                    fprintf(lcm.log,' / GB %.1f Hz^2 (%.0f+ Hz^2)',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMax); 
                elseif lcm.fit.crlbGb(mCnt)<lcm.fit.errLimGbMin
                    fprintf(lcm.log,' / GB %.1f Hz^2 (<%.1f Hz^2)',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.errLimGbMin);
                else
                    fprintf(lcm.log,' / GB %.1f Hz^2 (%.1f Hz^2)',lcm.anaGb(lcm.fit.applied(mCnt)),lcm.fit.crlbGb(mCnt));
                end
            end
        end
        if flag.lcmAnaShift && ~flag.lcmLinkShift
            if flag.verbose
                if lcm.fit.crlbShift(mCnt)>lcm.fit.errLimShiftMax
                    fprintf(lcm.log,' / Shift %.2f Hz (%.0f+/',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMax); 
                elseif lcm.fit.crlbShift(mCnt)<lcm.fit.errLimShiftMin
                    fprintf(lcm.log,' / Shift %.2f Hz (<%.1f/',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMin);
                else
                    fprintf(lcm.log,' / Shift %.2f Hz (%.1f/',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.crlbShift(mCnt));
                end
                if lcm.anaShiftErr(lcm.fit.applied(mCnt))>lcm.fit.errLimShiftMax
                    fprintf(lcm.log,'%.0f+ Hz)',lcm.fit.errLimShiftMax); 
                elseif lcm.anaShiftErr(lcm.fit.applied(mCnt))<lcm.fit.errLimShiftMin
                    fprintf(lcm.log,'<%.1f Hz)',lcm.fit.errLimShiftMin);
                else
                    fprintf(lcm.log,'%.1f Hz)',lcm.anaShiftErr(lcm.fit.applied(mCnt)));
                end
            else
                if lcm.fit.crlbShift(mCnt)>lcm.fit.errLimShiftMax
                    fprintf(lcm.log,' / Shift %.2f Hz (%.0f+ Hz)',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMax); 
                elseif lcm.fit.crlbShift(mCnt)<lcm.fit.errLimShiftMin
                    fprintf(lcm.log,' / Shift %.2f Hz (<%.1f Hz)',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.errLimShiftMin);
                else
                    fprintf(lcm.log,' / Shift %.2f Hz (%.1f Hz)',lcm.anaShift(lcm.fit.applied(mCnt)),lcm.fit.crlbShift(mCnt));
                end
            end
        end
        fprintf(lcm.log,'\n');
    end
end         % of log file


% printout: metabolite combinations to command window ---
if flag.lcmComb1 || flag.lcmComb2 || flag.lcmComb3
    %--- display information ---
    for mCnt = 1:lcm.combN
        if mStrMax-length(lcm.combLabels{mCnt})>0
            gapStr = SP2_NSpaces(mStrMax-length(lcm.combLabels{mCnt})+2);
        else
            gapStr = ' ';
        end 
        if naaConc<0        % no NAA found
            if flag.verbose
                if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                    fprintf('%s:%s%.3f a.u. (%.0f+)',lcm.combLabels{mCnt},gapStr,...
                            lcm.combScale(mCnt),lcm.fit.errLimAmpMax)
                elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                    fprintf('%s:%s%.3f a.u. (<%.1f)',lcm.combLabels{mCnt},gapStr,...
                            lcm.combScale(mCnt),lcm.fit.errLimAmpMin)
                else
                    fprintf('%s:%s%.3f a.u. (%.1f)',lcm.combLabels{mCnt},gapStr,...
                            lcm.combScale(mCnt),100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt))
                end
            else
                if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                    fprintf('%s:%s%.3f a.u. (%.0f+%%)',lcm.combLabels{mCnt},gapStr,...
                            lcm.combScale(mCnt),lcm.fit.errLimAmpMax)
                elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                    fprintf('%s:%s%.3f a.u. (<%.1f%%)',lcm.combLabels{mCnt},gapStr,...
                            lcm.combScale(mCnt),lcm.fit.errLimAmpMin)
                else
                    fprintf('%s:%s%.3f a.u. (%.1f%%)',lcm.combLabels{mCnt},gapStr,...
                            lcm.combScale(mCnt),100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt))
                end
            end
        else                % assuming 10mM NAA
            if flag.verbose
                if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                    fprintf('%s:%s%.2f mM (%.3f, %.0f+)',lcm.combLabels{mCnt},gapStr,...
                            10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMax)   
                elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                    fprintf('%s:%s%.2f mM (%.3f, <%.1f)',lcm.combLabels{mCnt},gapStr,...
                            10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMin)   
                else
                    fprintf('%s:%s%.2f mM (%.3f, %.1f)',lcm.combLabels{mCnt},gapStr,...
                            10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),...
                            100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt))   
                end
            else
                if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                    fprintf('%s:%s%.2f mM (%.3f, %.0f+%%)',lcm.combLabels{mCnt},gapStr,...
                            10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMax)   
                elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                    fprintf('%s:%s%.2f mM (%.3f, <%.1f%%)',lcm.combLabels{mCnt},gapStr,...
                            10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMin)   
                else
                    fprintf('%s:%s%.2f mM (%.3f, %.1f%%)',lcm.combLabels{mCnt},gapStr,...
                            10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),...
                            100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt))   
                end
            end
        end
        if flag.lcmAnaLb && ~flag.lcmLinkLb
            if lcm.fit.combCrlbLb(lcm.combCrlbPos(mCnt))>lcm.fit.errLimLbMax
                fprintf(' / LB (%.0f+ Hz)',lcm.fit.errLimLbMax)   
            elseif lcm.fit.combCrlbLb(lcm.combCrlbPos(mCnt))<lcm.fit.errLimLbMin
                fprintf(' / LB (<%.1f Hz)',lcm.fit.errLimLbMin)   
            else
                fprintf(' / LB (%.1f Hz)',lcm.fit.combCrlbLb(lcm.combCrlbPos(mCnt)))   
            end
        end
        if flag.lcmAnaGb && ~flag.lcmLinkGb
            if lcm.fit.combCrlbGb(lcm.combCrlbPos(mCnt))>lcm.fit.errLimGbMax
                fprintf(' / GB (%.0f+ Hz^2)',lcm.fit.errLimGbMax)   
            elseif lcm.fit.combCrlbGb(lcm.combCrlbPos(mCnt))<lcm.fit.errLimGbMin
                fprintf(' / GB (<%.1f Hz^2)',lcm.fit.errLimGbMin)   
            else
                fprintf(' / GB (%.1f Hz^2)',lcm.fit.combCrlbGb(lcm.combCrlbPos(mCnt)));
            end
        end
        if flag.lcmAnaShift && ~flag.lcmLinkShift
            if lcm.fit.combCrlbShift(lcm.combCrlbPos(mCnt))>lcm.fit.errLimShiftMax
                fprintf(' / Shift (%.0f+ Hz)',lcm.fit.errLimShiftMax)   
            elseif lcm.fit.combCrlbShift(lcm.combCrlbPos(mCnt))<lcm.fit.errLimShiftMin
                fprintf(' / Shift (<%.1f Hz)',lcm.fit.errLimShiftMin)   
            else
                fprintf(' / Shift (%.1f Hz)',lcm.fit.combCrlbShift(lcm.combCrlbPos(mCnt)));
            end
        end
        fprintf('\n');
    end
    
    %--- save to log file ---
    if flag.lcmSaveLog
        for mCnt = 1:lcm.combN
            if naaConc<0        % no NAA found
                if flag.verbose
                    if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                        fprintf(lcm.log,'%s:%s%.3f a.u. (%.0f+)',lcm.combLabels{mCnt},gapStr,...
                                lcm.combScale(mCnt),lcm.fit.errLimAmpMax);
                    elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                        fprintf(lcm.log,'%s:%s%.3f a.u. (<%.1f)',lcm.combLabels{mCnt},gapStr,...
                                lcm.combScale(mCnt),lcm.fit.errLimAmpMin);
                    else
                        fprintf(lcm.log,'%s:%s%.3f a.u. (%.1f)',lcm.combLabels{mCnt},gapStr,...
                                lcm.combScale(mCnt),100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt));
                    end
                else
                    if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                        fprintf(lcm.log,'%s:%s%.3f a.u. (%.0f+%%)',lcm.combLabels{mCnt},gapStr,...
                                lcm.combScale(mCnt),lcm.fit.errLimAmpMax);
                    elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                        fprintf(lcm.log,'%s:%s%.3f a.u. (<%.1f%%)',lcm.combLabels{mCnt},gapStr,...
                                lcm.combScale(mCnt),lcm.fit.errLimAmpMin);
                    else
                        fprintf(lcm.log,'%s:%s%.3f a.u. (%.1f%%)',lcm.combLabels{mCnt},gapStr,...
                                lcm.combScale(mCnt),100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt));
                    end
                end
            else                % assuming 10mM NAA
                if flag.verbose
                    if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                        fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.0f+)',lcm.combLabels{mCnt},gapStr,...
                                10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMax);  
                    elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                        fprintf(lcm.log,'%s:%s%.2f mM (%.3f, <%.1f)',lcm.combLabels{mCnt},gapStr,...
                                10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMin);
                    else
                        fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.1f)',lcm.combLabels{mCnt},gapStr,...
                                10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),...
                                100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt));
                    end
                else
                    if 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)>=lcm.fit.errLimAmpMax
                        fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.0f+%%)',lcm.combLabels{mCnt},gapStr,...
                                10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMax);  
                    elseif 100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt)<lcm.fit.errLimAmpMin
                        fprintf(lcm.log,'%s:%s%.2f mM (%.3f, <%.1f%%)',lcm.combLabels{mCnt},gapStr,...
                                10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),lcm.fit.errLimAmpMin);
                    else
                        fprintf(lcm.log,'%s:%s%.2f mM (%.3f, %.1f%%)',lcm.combLabels{mCnt},gapStr,...
                                10*lcm.combScale(mCnt)/naaConc,lcm.combScale(mCnt),...
                                100*lcm.fit.combCrlbAmp(lcm.combCrlbPos(mCnt))/lcm.combScale(mCnt));
                    end
                end
            end
            if flag.lcmAnaLb && ~flag.lcmLinkLb
                if lcm.fit.combCrlbLb(lcm.combCrlbPos(mCnt))>lcm.fit.errLimLbMax
                    fprintf(lcm.log,' / LB (%.0f+ Hz)',lcm.fit.errLimLbMax); 
                elseif lcm.fit.combCrlbLb(lcm.combCrlbPos(mCnt))<lcm.fit.errLimLbMin
                    fprintf(lcm.log,' / LB (<%.1f Hz)',lcm.fit.errLimLbMin);
                else
                    fprintf(lcm.log,' / LB (%.1f Hz)',lcm.fit.combCrlbLb(lcm.combCrlbPos(mCnt)));
                end
            end
            if flag.lcmAnaGb && ~flag.lcmLinkGb
                if lcm.fit.combCrlbGb(lcm.combCrlbPos(mCnt))>lcm.fit.errLimGbMax
                    fprintf(lcm.log,' / GB (%.0f+ Hz^2)',lcm.fit.errLimGbMax); 
                elseif lcm.fit.combCrlbGb(lcm.combCrlbPos(mCnt))<lcm.fit.errLimGbMin
                    fprintf(lcm.log,' / GB (<%.1f Hz^2)',lcm.fit.errLimGbMin);
                else
                    fprintf(lcm.log,' / GB (%.1f Hz^2)',lcm.fit.combCrlbGb(lcm.combCrlbPos(mCnt)));
                end
            end
            if flag.lcmAnaShift && ~flag.lcmLinkShift
                if lcm.fit.combCrlbShift(lcm.combCrlbPos(mCnt))>lcm.fit.errLimShiftMax
                    fprintf(lcm.log,' / Shift (%.0f+ Hz)',lcm.fit.errLimShiftMax); 
                elseif lcm.fit.combCrlbShift(lcm.combCrlbPos(mCnt))<lcm.fit.errLimShiftMin
                    fprintf(lcm.log,' / Shift (<%.1f Hz)',lcm.fit.errLimShiftMin);
                else
                    fprintf(lcm.log,' / Shift (%.1f Hz)',lcm.fit.combCrlbShift(lcm.combCrlbPos(mCnt)));
                end
            end
            fprintf(lcm.log,'\n');
        end
    end         % end of log file
end             % end of combined metabs



%--- info printout: global pars ---
% in original order
if flag.lcmAnaLb && flag.lcmLinkLb
    if flag.verbose
        if lcm.fit.crlbLb>50
            fprintf('LB:%s%.1f Hz (%.0f+/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMax);
        elseif lcm.fit.crlbLb<0.1
            fprintf('LB:%s%.1f Hz (<%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMin);
        else
            fprintf('LB:%s%.1f Hz (%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.crlbLb);
        end
        if lcm.anaLbErr(lcm.fit.applied(1))>lcm.fit.errLimLbMax
            fprintf('%.0f+ Hz)\n',lcm.fit.errLimLbMax);
        elseif lcm.anaLbErr(lcm.fit.applied(1))<lcm.fit.errLimLbMin
            fprintf('<%.1f Hz)\n',lcm.fit.errLimLbMin);
        else
            fprintf('%.1f Hz)\n',lcm.anaLbErr(lcm.fit.applied(1)));
        end
    else
        if lcm.fit.crlbLb>lcm.fit.errLimLbMax
            fprintf('LB:%s%.1f Hz (%.0f+ Hz)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMax);
        elseif lcm.fit.crlbLb<lcm.fit.errLimLbMin
            fprintf('LB:%s%.1f Hz (<%.1f Hz)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMin);
        else
            fprintf('LB:%s%.1f Hz (%.1f Hz)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.crlbLb);
        end
    end
end
if flag.lcmAnaGb && flag.lcmLinkGb
    if flag.verbose
        if lcm.fit.crlbGb>lcm.fit.errLimGbMax
            fprintf('GB:%s%.1f Hz^2 (%.0f+/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMax);
        elseif lcm.fit.crlbGb<lcm.fit.errLimGbMin
            fprintf('GB:%s%.1f Hz^2 (<%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMin);
        else
            fprintf('GB:%s%.1f Hz^2 (%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.crlbGb);
        end
        if lcm.anaGbErr(lcm.fit.applied(1))>lcm.fit.errLimGbMax
            fprintf('%.0f+ Hz^2)\n',lcm.fit.errLimGbMax);
        elseif lcm.anaGbErr(lcm.fit.applied(1))<lcm.fit.errLimGbMin
            fprintf('<%.1f Hz^2)\n',lcm.fit.errLimGbMin);
        else
            fprintf('%.1f Hz^2)\n',lcm.anaGbErr(lcm.fit.applied(1)));
        end
    else
        if lcm.fit.crlbGb>lcm.fit.errLimGbMax
            fprintf('GB:%s%.1f Hz^2 (%.0f+ Hz^2)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMax);
        elseif lcm.fit.crlbGb<lcm.fit.errLimGbMin
            fprintf('GB:%s%.1f Hz^2 (<%.1f Hz^2)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMin);
        else
            fprintf('GB:%s%.1f Hz^2 (%.1f Hz^2)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.crlbGb);
        end
    end
end
if flag.lcmAnaShift && flag.lcmLinkShift
    if flag.verbose
        if lcm.fit.crlbShift>lcm.fit.errLimShiftMax
            fprintf('Shift:%s%.2f Hz (%.0f+/',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMax);
        elseif lcm.fit.crlbShift<lcm.fit.errLimShiftMin
            fprintf('Shift:%s%.2f Hz (<%.1f/',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMin);
        else
            fprintf('Shift:%s%.2f Hz (%.1f/',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.crlbShift);
        end
        if lcm.anaShiftErr(lcm.fit.applied(1))>lcm.fit.errLimShiftMax
            fprintf('%.0f+ Hz)\n',lcm.fit.errLimShiftMax);
        elseif lcm.anaShiftErr(lcm.fit.applied(1))<lcm.fit.errLimShiftMin
            fprintf('<%.1f Hz)\n',lcm.fit.errLimShiftMin);
        else
            fprintf('%.1f Hz)\n',lcm.anaShiftErr(lcm.fit.applied(1)));
        end
    else
        if lcm.fit.crlbShift>lcm.fit.errLimShiftMax
            fprintf('Shift:%s%.2f Hz (%.0f+ Hz)\n',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMax);
        elseif lcm.fit.crlbShift<lcm.fit.errLimShiftMin
            fprintf('Shift:%s%.2f Hz (<%.1f Hz)\n',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMin);
        else
            fprintf('Shift:%s%.2f Hz (%.1f Hz)\n',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.crlbShift);
        end
    end
end
if flag.lcmAnaPhc0
    if flag.verbose
        if lcm.fit.crlbPhc0<lcm.fit.errLimPhc0Min
            fprintf('PHC0:%s%.1f deg (<%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.errLimPhc0Min);
        else
            fprintf('PHC0:%s%.1f deg (%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.crlbPhc0);
        end
        if lcm.anaPhc0Err<lcm.fit.errLimPhc0Min
            fprintf('/<%.1f deg)\n',lcm.fit.errLimPhc0Min);
        else
            fprintf('/%.1f deg)\n',lcm.anaPhc0Err);
        end
    else
        if lcm.fit.crlbPhc0<lcm.fit.errLimPhc0Min
            fprintf('PHC0:%s%.1f deg (<%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.errLimPhc0Min);
        else
            fprintf('PHC0:%s%.1f deg (%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.crlbPhc0);
        end
    end
end
if flag.lcmAnaPhc1
    if flag.verbose
        if lcm.fit.crlbPhc1<lcm.fit.errLimPhc1Min
            fprintf('PHC1:%s%.1f deg/Hz (<%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.errLimPhc1Min);
        else
            fprintf('PHC1:%s%.1f deg/Hz (%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.crlbPhc1);
        end
        if lcm.anaPhc1Err<lcm.fit.errLimPhc1Min
            fprintf('/<%.1f deg)\n',lcm.fit.errLimPhc1Min);
        else
            fprintf('/%.1f deg)\n',lcm.anaPhc1Err);
        end
    else
        if lcm.fit.crlbPhc1<lcm.fit.errLimPhc1Min
            fprintf('PHC1:%s%.1f deg/Hz (<%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.errLimPhc1Min);
        else
            fprintf('PHC1:%s%.1f deg/Hz (%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.crlbPhc1);
        end
    end
end
fprintf('\n');


%--- info printout: global pars (log file) ---
if flag.lcmSaveLog
    % in original order
    if flag.lcmAnaLb && flag.lcmLinkLb
        if flag.verbose
            if lcm.fit.crlbLb>lcm.fit.errLimLbMax
                fprintf(lcm.log,'LB:%s%.1f Hz (%.0f+/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMax);
            elseif lcm.fit.crlbLb<lcm.fit.errLimLbMin
                fprintf(lcm.log,'LB:%s%.1f Hz (<%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMin);
            else
                fprintf(lcm.log,'LB:%s%.1f Hz (%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.crlbLb);
            end
            if lcm.anaLbErr(lcm.fit.applied(1))>lcm.fit.errLimLbMax
                fprintf(lcm.log,'%.0f+ Hz)\n',lcm.fit.errLimLbMax);
            elseif lcm.anaLbErr(lcm.fit.applied(1))<lcm.fit.errLimLbMin
                fprintf(lcm.log,'<%.1f Hz)\n',lcm.fit.errLimLbMin);
            else
                fprintf(lcm.log,'%.1f Hz)\n',lcm.anaLbErr(lcm.fit.applied(1)));
            end
        else
            if lcm.fit.crlbLb>lcm.fit.errLimLbMax
                fprintf(lcm.log,'LB:%s%.1f Hz (%.0f+ Hz)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMax);
            elseif lcm.fit.crlbLb<lcm.fit.errLimLbMin
                fprintf(lcm.log,'LB:%s%.1f Hz (<%.1f Hz)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.errLimLbMin);
            else
                fprintf(lcm.log,'LB:%s%.1f Hz (%.1f Hz)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaLb(lcm.fit.applied(1)),lcm.fit.crlbLb);
            end
        end
    end
    if flag.lcmAnaGb && flag.lcmLinkGb
        if flag.verbose
            if lcm.fit.crlbGb>lcm.fit.errLimGbMax
                fprintf(lcm.log,'GB:%s%.1f Hz^2 (%.0f+/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMax);
            elseif lcm.fit.crlbGb<lcm.fit.errLimGbMin
                fprintf(lcm.log,'GB:%s%.1f Hz^2 (<%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMin);
            else
                fprintf(lcm.log,'GB:%s%.1f Hz^2 (%.1f/',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.crlbGb);
            end
            if lcm.anaGbErr(lcm.fit.applied(1))>lcm.fit.errLimGbMax
                fprintf(lcm.log,'%.0f+ Hz^2)\n',lcm.fit.errLimGbMax);
            elseif lcm.anaGbErr(lcm.fit.applied(1))<lcm.fit.errLimGbMin
                fprintf(lcm.log,'<0.1 Hz^2)\n');
            else
                fprintf(lcm.log,'%.1f Hz^2)\n',lcm.anaGbErr(lcm.fit.applied(1)));
            end
        else
            if lcm.fit.crlbGb>lcm.fit.errLimGbMax
                fprintf(lcm.log,'GB:%s%.1f Hz^2 (%.0f+ Hz^2)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMax);
            elseif lcm.fit.crlbGb<lcm.fit.errLimGbMin
                fprintf(lcm.log,'GB:%s%.1f Hz^2 (<%.1f Hz^2)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.errLimGbMin);
            else
                fprintf(lcm.log,'GB:%s%.1f Hz^2 (%.1f Hz^2)\n',SP2_NSpaces(max(mStrMax-2+2,1)),lcm.anaGb(lcm.fit.applied(1)),lcm.fit.crlbGb);
            end
        end
    end
    if flag.lcmAnaShift && flag.lcmLinkShift
        if flag.verbose
            if lcm.fit.crlbShift>lcm.fit.errLimShiftMax
                fprintf(lcm.log,'Shift:%s%.2f Hz (%.0f+/',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMax);
            elseif lcm.fit.crlbShift<lcm.fit.errLimShiftMin
                fprintf(lcm.log,'Shift:%s%.2f Hz (<%.1f/',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMin);
            else
                fprintf(lcm.log,'Shift:%s%.2f Hz (%.1f/',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.crlbShift);
            end
            if lcm.anaShiftErr(lcm.fit.applied(1))>lcm.fit.errLimShiftMax
                fprintf(lcm.log,'%.0f+ Hz)\n',lcm.fit.errLimShiftMax);
            elseif lcm.anaShiftErr(lcm.fit.applied(1))<lcm.fit.errLimShiftMin
                fprintf(lcm.log,'<%.1f Hz)\n',lcm.fit.errLimShiftMin);
            else
                fprintf(lcm.log,'%.1f Hz)\n',lcm.anaShiftErr(lcm.fit.applied(1)));
            end
        else
            if lcm.fit.crlbShift>lcm.fit.errLimShiftMax
                fprintf(lcm.log,'Shift:%s%.2f Hz (%.0f+ Hz)\n',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMax);
            elseif lcm.fit.crlbShift<lcm.fit.errLimShiftMin
                fprintf(lcm.log,'Shift:%s%.2f Hz (<%.1f Hz)\n',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.errLimShiftMin);
            else
                fprintf(lcm.log,'Shift:%s%.2f Hz (%.1f Hz)\n',SP2_NSpaces(max(mStrMax-5+2,1)),lcm.anaShift(lcm.fit.applied(1)),lcm.fit.crlbShift);
            end
        end
    end
    if flag.lcmAnaPhc0
        if flag.verbose
            if lcm.fit.crlbPhc0<lcm.fit.errLimPhc0Min
                fprintf(lcm.log,'PHC0:%s%.1f deg (<%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.errLimPhc0Min);
            else
                fprintf(lcm.log,'PHC0:%s%.1f deg (%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.crlbPhc0);
            end
            if lcm.anaPhc0Err<lcm.fit.errLimPhc0Min
                fprintf(lcm.log,'/<%.1f deg)\n',lcm.fit.errLimPhc0Min);
            else
                fprintf(lcm.log,'/%.1f deg)\n',lcm.anaPhc0Err);
            end
        else
            if lcm.fit.crlbPhc0<lcm.fit.errLimPhc0Min
                fprintf(lcm.log,'PHC0:%s%.1f deg (<%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.errLimPhc0Min);
            else
                fprintf(lcm.log,'PHC0:%s%.1f deg (%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc0,lcm.fit.crlbPhc0);
            end
        end
    end
    if flag.lcmAnaPhc1
        if flag.verbose
            if lcm.fit.crlbPhc1<lcm.fit.errLimPhc1Min
                fprintf(lcm.log,'PHC1:%s%.1f deg/Hz (<%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.errLimPhc1Min);
            else
                fprintf(lcm.log,'PHC1:%s%.1f deg/Hz (%.1f',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.crlbPhc1);
            end
            if lcm.anaPhc1Err<lcm.fit.errLimPhc1Min
                fprintf(lcm.log,'/<%.1f deg)\n',lcm.fit.errLimPhc1Min);
            else
                fprintf(lcm.log,'/%.1f deg)\n',lcm.anaPhc1Err);
            end
        else
            if lcm.fit.crlbPhc1<lcm.fit.errLimPhc1Min
                fprintf(lcm.log,'PHC1:%s%.1f deg/Hz (<%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.errLimPhc1Min);
            else
                fprintf(lcm.log,'PHC1:%s%.1f deg/Hz (%.1f deg)\n',SP2_NSpaces(max(mStrMax-4+2,1)),lcm.anaPhc1,lcm.fit.crlbPhc1);
            end
        end
    end
    fprintf(lcm.log,'\n');

    %--- close log file ---
    fclose(lcm.log);
end

%--- update success flag ---
f_succ = 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    L O C A L    F U N C T I O N S                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%-----------------------
%--- fit diagnostics ---
%-----------------------
function SP2_Loc_FitDiagnostics(exitflag,output)

    global flag lcm

    %--- fit quality assessment ---
    fprintf('\nFit diagnostics:\n');
    switch exitflag
        case 1
            fprintf('lsqcurvefit converged to a solution.\n');
        case 2 
            fprintf('Change in X too small.\n');
        case 3  
            fprintf('Change in RESNORM too small.\n');
        case 4  
            fprintf('Computed search direction too small.\n');
        case 0
            fprintf('Too many function evaluations or iterations.\n');
        case -1  
            fprintf('Stopped by output/plot function.');
        case -2  
            fprintf('Bounds are inconsistent.');
    end
    
    %--- fit quality assessment (log file) ---
    if flag.lcmSaveLog
        fprintf(lcm.log,'\nFit diagnostics:\n');
        switch exitflag
            case 1
                fprintf(lcm.log,'lsqcurvefit converged to a solution.\n');
            case 2 
                fprintf(lcm.log,'Change in X too small.\n');
            case 3  
                fprintf(lcm.log,'Change in RESNORM too small.\n');
            case 4  
                fprintf(lcm.log,'Computed search direction too small.\n');
            case 0
                fprintf(lcm.log,'Too many function evaluations or iterations.\n');
            case -1  
                fprintf(lcm.log,'Stopped by output/plot function.');
            case -2  
                fprintf(lcm.log,'Bounds are inconsistent.');
        end
    end

    %--- info printout ---
    fprintf('firstorderopt: %.4f\n',output.firstorderopt);
    fprintf('iterations:    %.0f\n',output.iterations);
    fprintf('funcCount:     %.0f\n',output.funcCount);
    fprintf('cgiterations:  %.0f\n',output.iterations);
    fprintf('algorithm:     %s\n\n',output.algorithm);

    %--- info printout (log file) ---
    if flag.lcmSaveLog
        fprintf(lcm.log,'firstorderopt: %.4f\n',output.firstorderopt);
        fprintf(lcm.log,'iterations:    %.0f\n',output.iterations);
        fprintf(lcm.log,'funcCount:     %.0f\n',output.funcCount);
        fprintf(lcm.log,'cgiterations:  %.0f\n',output.iterations);
        fprintf(lcm.log,'algorithm:     %s\n\n',output.algorithm);
    end
    
    
end
    
%----------------------       
%--- error analysis ---
%----------------------
function [coeffErr, sdErr] = SP2_Loc_ErrorAnalysis(res2norm,residual,jacobian,specZoom)

    global flag lcm
    
    % ERROR 1: STANDARD DEVIATION OF THE OBSERVATIONS AROUND THE REGRESSION CURVE
    % by Peter Perkins, The MathWorks, Inc. 
    % I think you probably mean the standard deviation of the observations around
    % the regression curve (or surface), is that right? The usual estimate is
    % norm(residuals)/sqrt(n-p), where n is the number of observations, and p is the
    % number of estimated parameters. The squared norm of the residuals is the
    % second output from LSQCURVEFIT, so take the square root of that.
    sdErr = sqrt(res2norm);
    if flag.verbose
        fprintf('SD around fit: norm(residuals)/sqrt(#observations - #fitpars)\n');
        fprintf('SD(resid)             = %.2f\n',sdErr);
        fprintf('SD(resid) / max(spec) = %.2f\n',sdErr/max(specZoom));
        fprintf('SD(resid) / SD(spec)  = %.2f\n',sdErr/std(specZoom));

        %--- log file ---
        if flag.lcmSaveLog
            fprintf(lcm.log,'SD around fit: norm(residuals)/sqrt(#observations - #fitpars)\n');
            fprintf(lcm.log,'SD(resid)             = %.2f\n',sdErr);
            fprintf(lcm.log,'SD(resid) / max(spec) = %.2f\n',sdErr/max(specZoom));
            fprintf(lcm.log,'SD(resid) / SD(spec)  = %.2f\n',sdErr/std(specZoom));
        end
    end
    
    % ERROR 2: STANDARD ERRORS OF INDIVIDUAL FITTING PARAMETERS
    % http://comp.soft-sys.matlab.narkive.com/Jq6b64k7/errors-of-parameters-deduced-using-lsqcurvefit
    % Post by john
    % I have just used lsqcurvefit to obtain 4 parameters to my equation, i
    % was wondering if anyone could help on how to find the errors for the
    % individual parameters.
    % Hi John -
    % 
    % I assume you mean "standard errors". The most common thing to do is to
    % approximate the Hessian using the Jacobian, and use the inverse of that
    % as an approximation to the covariance matrix:
    % 
    % [Q,R] = qr(J,0);
    % mse = sum(abs(r).^2)/(size(J,1)-size(J,2));
    % Rinv = inv(R);
    % Sigma = Rinv*Rinv'*mse;
    % se = sqrt(diag(Sigma));
    % 
    % where r is the residual vector and J is the Jacobian, both outputs of
    % LSQCURVEFIT. The usual assumptions about independent errors and large
    % sample size and so forth apply.
    % 
    % If you have the Statistics Toolbox, you can also get confidence
    % intervals using NLPARCI, and prediction/confidence intervals for the
    % fitted curve using NLPREDCI.
    % 
    % Hope this helps.
    % 
    % - Peter Perkins
    % The MathWorks, Inc.
    [Q,R]    = qr(jacobian,0);
    mse      = sum(abs(residual).^2)/(size(jacobian,1)-size(jacobian,2));
    Rinv     = inv(R);
    Sigma    = Rinv*Rinv'*mse;
    coeffErr = full(sqrt(diag(Sigma)))';






end




    
    
    



