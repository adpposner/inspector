%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function outdata = SP2_LCM_AnaFitFct(coeff,data)
%%
%%  LCModel fit function.
%%  Note the indexing:
%%  1) bCnt for basis function within selected basis functions
%%  2) lcm.fit.applied(bCnt) for absolute index of specific basis function within data set
%%
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm lcmAna flag


%--- loop over basis functions ---
lcmAna.specSum = 0;                     % init / reset
for bCnt = 1:lcm.fit.appliedN           % loop over selected basis functions
    %--- data assignment and scaling ---
    lcmAna.nspecC = min(lcm.nspecC,lcm.basis.fidLength(lcm.fit.applied(bCnt)));
    lcmAna.fid    = coeff(lcmAna.indScale(bCnt))*lcm.basis.data{lcm.fit.applied(bCnt)}{4};
    lcmAna.fid    = lcmAna.fid(1:lcmAna.nspecC);

    %--- Lorentzian line broadening ---
    %--- generation of weighting function ---
    if flag.lcmLinkLb               % single LB
        if bCnt==1                  % use first one (only)
            if flag.lcmAnaLb
                lcmAna.lbWeight = exp(-coeff(lcmAna.indLb(bCnt))*lcm.dwell*(0:lcmAna.nspecC-1)*pi)';
            else
                lcmAna.lbWeight = exp(-lcm.anaLb(lcm.fit.applied(bCnt))*lcm.dwell*(0:lcmAna.nspecC-1)*pi)';
            end
        end
    else                            % metabolite-specific LB
        if flag.lcmAnaLb
            lcmAna.lbWeight = exp(-coeff(lcmAna.indLb(bCnt))*lcm.dwell*(0:lcmAna.nspecC-1)*pi)';
        else
            lcmAna.lbWeight = exp(-lcm.anaLb(lcm.fit.applied(bCnt))*lcm.dwell*(0:lcmAna.nspecC-1)*pi)';
        end
    end
    
    %--- Lorentzian line broadening ---
    if flag.lcmAnaLb
        lcmAna.fid = lcmAna.fid .* lcmAna.lbWeight;
    end
    
    %--- Gaussian line broadening ---
    %--- generation of weighting function ---
% obsolete, used until 06/2020
%     if flag.lcmLinkGb               % single GB
%         if bCnt==1                  % use first one (only)
%             if flag.lcmAnaGb
%                 lcmAna.gbWeight = exp(-coeff(lcmAna.indGb(bCnt))*(lcm.dwell*(0:lcmAna.nspecC-1)*pi).^2)';
%             else
%                 lcmAna.gbWeight = exp(-lcm.anaGb(lcm.fit.applied(bCnt))*(lcm.dwell*(0:lcmAna.nspecC-1)*pi).^2)';
%             end
%         end
%     else                            % metabolite-specific GB
%         if flag.lcmAnaGb
%             lcmAna.gbWeight = exp(-coeff(lcmAna.indGb(bCnt))*(lcm.dwell*(0:lcmAna.nspecC-1)*pi).^2)';
%         else
%             lcmAna.gbWeight = exp(-lcm.anaGb(lcm.fit.applied(bCnt))*(lcm.dwell*(0:lcmAna.nspecC-1)*pi).^2)';
%         end
%     end
    if flag.lcmLinkGb               % single GB
        if bCnt==1                  % use first one (only)
            if flag.lcmAnaGb
                lcmAna.gbWeight = exp(-pi^2 * coeff(lcmAna.indGb(bCnt)) * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
                % lcmAna.gbWeight = exp(-pi^2/(4*log(2)) * coeff(lcmAna.indGb(bCnt))^2 * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
            else
                lcmAna.gbWeight = exp(-pi^2 * lcm.anaGb(lcm.fit.applied(bCnt)) * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
                % lcmAna.gbWeight = exp(-pi^2/(4*log(2)) * lcm.anaGb(lcm.fit.applied(bCnt))^2 * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
            end
        end
    else                            % metabolite-specific GB
        if flag.lcmAnaGb
            lcmAna.gbWeight = exp(-pi^2 * coeff(lcmAna.indGb(bCnt)) * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
            % lcmAna.gbWeight = exp(-pi^2/(4*log(2)) * coeff(lcmAna.indGb(bCnt))^2 * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
        else
            lcmAna.gbWeight = exp(-pi^2 * lcm.anaGb(lcm.fit.applied(bCnt)) * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
            % lcmAna.gbWeight = exp(-pi^2/(4*log(2)) * lcm.anaGb(lcm.fit.applied(bCnt))^2 * (lcm.dwell*(0:lcmAna.nspecC-1)).^2)';
        end
    end
            
    %--- Gaussian line broadening ---
    if flag.lcmAnaGb
        lcmAna.fid = lcmAna.fid .* lcmAna.gbWeight;
    end

    %--- frequency shift ---
    if flag.lcmLinkShift            % single frequency shift
        if bCnt==1                  % use first one (only)
            if flag.lcmAnaShift
                lcmAna.fid = lcmAna.fid .* exp(1i*2*pi*(0:lcmAna.nspecC-1)' * lcm.dwell * (coeff(lcmAna.indShift(bCnt))+lcm.calibRelHz));   % corr phase per point
            else
                lcmAna.fid = lcmAna.fid .* exp(1i*2*pi*(0:lcmAna.nspecC-1)' * lcm.dwell * (lcm.anaShift(lcm.fit.applied(bCnt))+lcm.calibRelHz));        % corr phase per point
            end
        end
    else                            % metabolite-specific shift
        if flag.lcmAnaShift
            lcmAna.fid = lcmAna.fid .* exp(1i*2*pi*(0:lcmAna.nspecC-1)' * lcm.dwell * (coeff(lcmAna.indShift(bCnt))+lcm.calibRelHz));   % corr phase per point
        else
            lcmAna.fid = lcmAna.fid .* exp(1i*2*pi*(0:lcmAna.nspecC-1)' * lcm.dwell * (lcm.anaShift(lcm.fit.applied(bCnt))+lcm.calibRelHz));        % corr phase per point
        end
    end
    
    
    %--- FID data cut-off ---
    % case 1: basis FID is longer than target FID
    if lcm.nspecC<lcm.basis.ptsMin
        lcmAna.fid    = lcmAna.fid(1:lcm.nspecC,1);
        lcmAna.nspecC = lcm.nspecC;
    end
    % case 2: intended cut
    if flag.lcmSpecCut
        if lcm.specCut<lcmAna.nspecC
            lcmAna.fid    = lcmAna.fid(1:lcm.specCut,1);
            lcmAna.nspecC = lcm.specCut;
        end
    end
    
    %--- time-domaine zero-filling ---
    % case 1: intended ZF
    if flag.lcmSpecZf
        if lcm.specZf>lcmAna.nspecC
            lcmAna.fidZf  = complex(zeros(lcm.specZf,1));
            lcmAna.fidZf(1:lcmAna.nspecC,1) = lcmAna.fid;
            lcmAna.fid    = lcmAna.fidZf;
            lcmAna.nspecC = lcm.specZf;
        end
    end
    % case 2: basis FID shorter than target FID
    if lcm.nspecC>length(lcmAna.fid)                            % effective data length, irrespective of ZF flag
        lcmAnaFidZf = complex(zeros(lcm.nspecC,1));             % local only
        lcmAnaFidZf(1:length(lcmAna.fid),1) = lcmAna.fid;
        lcmAna.fid    = lcmAnaFidZf;
        lcmAna.nspecC = lcm.nspecC;
    end
    % case 3: basis FID longer than target FID (still necessary?!)
    if lcm.anaNspecC<lcmAna.nspecC                           
        lcmAna.fid    = lcmAna.fid(1:lcm.anaNspecC);
        lcmAna.nspecC = lcm.anaNspecC;
    end
    
    %--- spectral FFT ---
    lcmAna.spec = fftshift(fft(lcmAna.fid,[],1),1);

    %--- spectrum summation ---
    if bCnt==1
        lcmAna.specSum = lcmAna.spec;
    else
        lcmAna.specSum = lcmAna.specSum + lcmAna.spec;
    end    
end

%--- PHC0 & PHC1 phase correction ---
if flag.lcmAnaPhc0 && flag.lcmAnaPhc1
    if coeff(lcmAna.indPhc1)==0         % ensure vector format
        lcmAna.phaseVec = coeff(lcmAna.indPhc0) * ones(lcmAna.nspecC,1);
    else
        lcmAna.phaseVec = (0:coeff(lcmAna.indPhc1)/(lcmAna.nspecC-1):coeff(lcmAna.indPhc1))' + coeff(lcmAna.indPhc0);
    end
elseif flag.lcmAnaPhc1
    if coeff(lcmAna.indPhc1)==0         % ensure vector format
        lcmAna.phaseVec = zeros(lcmAna.nspecC,1);
    else
        lcmAna.phaseVec = (0:coeff(lcmAna.indPhc1)/(lcmAna.nspecC-1):coeff(lcmAna.indPhc1))';
    end
elseif flag.lcmAnaPhc0
    lcmAna.phaseVec = ones(lcmAna.nspecC,1)*coeff(lcmAna.indPhc0);
end
if flag.lcmAnaPhc0 || flag.lcmAnaPhc1
    lcmAna.specSum = lcmAna.specSum .* exp(-1i*lcmAna.phaseVec*pi/180);
end

%--- extraction of spectral range ---
if flag.lcmRealComplex          % real part only
    outdata = real(lcmAna.specSum(lcm.anaAllInd));
else                            % complex signal
    outdata = [real(lcmAna.specSum(lcm.anaAllInd)); imag(lcmAna.specSum(lcm.anaAllInd))];
end

%--- polynomial baseline ---
if flag.lcmAnaPoly
    if flag.lcmRealComplex                  % real part only
        switch lcm.anaPolyOrder
            case 0
                outdata = outdata + coeff(lcmAna.indPoly);
            case 1
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+1);
            case 2
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+2);
            case 3
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+3);
            case 4
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+4);
            case 5
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+5);
            case 6
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+6);
            case 7
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+7);
            case 8
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+7)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+8);
            case 9
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm9 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+7)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+8)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+9);
            case 10
                outdata = outdata + ...
                          coeff(lcmAna.indPoly)*lcm.anaAllIndPpm10 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm9 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+7)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+8)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+9)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+10);
        end
    else                                    % complex FID and fit
        switch lcm.anaPolyOrder
            case 0
                outdata = outdata + [coeff(lcmAna.indPoly)*lcm.anaAllIndOnes; coeff(lcmAna.indPolyImag)*lcm.anaAllIndOnes];
            case 1
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+1); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+1)];
            case 2
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+2); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+2)];
            case 3
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+3); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+3)];
            case 4
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+4); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+3)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+4)];
            case 5
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+5); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+3)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+4)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+5)];
            case 6
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+6); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPolyImag+3)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+4)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+5)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+6)];
            case 7
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+7); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPolyImag+3)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPolyImag+4)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+5)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+6)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+7)];
            case 8
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+7)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+8); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPolyImag+3)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPolyImag+4)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPolyImag+5)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+6)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+7)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+8)];
            case 9
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm9 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+7)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+8)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+9); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm9 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPolyImag+3)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPolyImag+4)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPolyImag+5)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPolyImag+6)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+7)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+8)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+9)];
            case 10
                outdata = outdata + ...
                          [coeff(lcmAna.indPoly)*lcm.anaAllIndPpm10 + ...
                          coeff(lcmAna.indPoly+1)*lcm.anaAllIndPpm9 + ...
                          coeff(lcmAna.indPoly+2)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPoly+3)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPoly+4)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPoly+5)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPoly+6)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPoly+7)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPoly+8)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPoly+9)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPoly+10); ...
                          coeff(lcmAna.indPolyImag)*lcm.anaAllIndPpm10 + ...
                          coeff(lcmAna.indPolyImag+1)*lcm.anaAllIndPpm9 + ...
                          coeff(lcmAna.indPolyImag+2)*lcm.anaAllIndPpm8 + ...
                          coeff(lcmAna.indPolyImag+3)*lcm.anaAllIndPpm7 + ...
                          coeff(lcmAna.indPolyImag+4)*lcm.anaAllIndPpm6 + ...
                          coeff(lcmAna.indPolyImag+5)*lcm.anaAllIndPpm5 + ...
                          coeff(lcmAna.indPolyImag+6)*lcm.anaAllIndPpm4 + ...
                          coeff(lcmAna.indPolyImag+7)*lcm.anaAllIndPpm3 + ...
                          coeff(lcmAna.indPolyImag+8)*lcm.anaAllIndPpm2 + ...
                          coeff(lcmAna.indPolyImag+9)*lcm.anaAllIndPpm + ...
                          coeff(lcmAna.indPolyImag+10)];
        end
    end
end

%--- spline baseline ---
% if flag.lcmAnaSpline
%     if flag.lcmRealComplex                  % real part only
%         outdata = outdata + ...
%                   spline(lcm.anaSplIndPpm,coeff(lcmAna.indSplReal:lcmAna.indSplReal+lcm.anaSplIndPpmN-1),lcm.anaAllIndPpm);
%     else                                    % complex FID and fit
%         outdata = outdata + ...
%                   [spline(lcm.anaSplIndPpm,coeff(lcmAna.indSplReal:lcmAna.indSplReal+lcm.anaSplIndPpmN-1),lcm.anaAllIndPpm); ...
%                    spline(lcm.anaSplIndPpm,coeff(lcmAna.indSplImag:lcmAna.indSplImag+lcm.anaSplIndPpmN-1),lcm.anaAllIndPpm)];
%     end
% end

if flag.lcmAnaSpline
    if flag.lcmRealComplex                  % real part only
        lcm.sp1 = spmak(lcm.anaSplIndPpm, coeff(lcmAna.indSplReal:lcmAna.indSplReal));
        splinebaseline_real = fnval(lcm.sp1, lcm.anaAllIndPpm);
        outdata = outdata + splinebaseline_real;
    else                                    % complex FID and fit
        lcm.sp1 = spmak(knotpoints, coeff(lcmAna.indSplReal:lcmAna.indSplReal));
        splinebaseline_real = fnval(lcm.sp1, lcm.anaAllIndPpm);   
        lcm.sp2 = spmak(knotpoints, coeff(lcmAna.indSplImag:lcmAna.indSplImag));
        splinebaseline_imag = fnval(lcm.sp2, lcm.anaAllIndPpm);
        outdata = outdata + [splinebaseline_real; splinebaseline_imag];
    end
end






end
