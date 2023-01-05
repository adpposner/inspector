%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_ProcResultData
%% 
%%  Processing function of LCM fitting result.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag lcmAna

FCTNAME = 'SP2_LCM_ProcResultData';


%--- success flag init ---
f_done = 0;

%--- parameter assignment ---
lcm.fit.dwell  = lcm.basis.dwell;
lcm.fit.sw     = lcm.sw;

%--- loop over selected basis functions ---
for bCnt = 1:lcm.fit.appliedN           % loop over selected basis functions
    %--- data assignment and scaling ---
    lcm.fit.fidSingle = lcm.anaScale(lcm.fit.applied(bCnt))*lcm.basis.data{lcm.fit.applied(bCnt)}{4};
    if flag.lcmSpecCut && lcm.specCut<length(lcm.fit.fidSingle)         % target FID shorter than basis FID(s)
        lcm.fit.fidSingle = lcm.fit.fidSingle(1:lcm.specCut);
    end
    lcm.fit.nspecC = length(lcm.fit.fidSingle);

    %--- exponential line broadening ---
    if flag.lcmAnaLb
        %--- weighting function ---
        lbWeight = exp(-lcm.anaLb(lcm.fit.applied(bCnt))*lcm.fit.dwell*(0:lcm.fit.nspecC-1)*pi)';

        %--- line broadening ---
        lcm.fit.fidSingle = lcm.fit.fidSingle .* lbWeight;
    end
    
    %--- Gaussian line broadening ---
    if flag.lcmAnaGb
        %--- weighting function ---
        gbWeight = exp(-lcm.anaGb(lcm.fit.applied(bCnt))*(lcm.fit.dwell*(0:lcm.fit.nspecC-1)*pi).^2)';
        % gbWeight = exp(-pi^2/(4*log(2)) * lcm.anaGb(lcm.fit.applied(bCnt))^2 * (lcm.fit.dwell*(0:lcm.fit.nspecC-1)).^2)';
        
        %--- line broadening ---
        lcm.fit.fidSingle = lcm.fit.fidSingle .* gbWeight;
    end

    %--- frequency shift ---
    if flag.lcmAnaShift
        %--- time vector ---
        tVec   = (0:lcm.fit.nspecC-1)' * lcm.fit.dwell;

        %--- frequency shift ---
        lcm.fit.fidSingle = lcm.fit.fidSingle .* exp(1i*tVec*(lcm.anaShift(lcm.fit.applied(bCnt))+lcm.calibRelHz)*2*pi);       % apply phase correction
    end

%     %--- FID data cut-off ---
%     if lcm.specCut<lcm.fit.nspecC
%         lcm.fit.fidSingle = lcm.fit.fidSingle(1:lcm.specCut,1);
%         lcm.fit.nspecC = lcm.specCut;
%     else
%         fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
%                 FCTNAME,lcm.specCut,lcm.fit.nspecC)
%     end

    %--- time-domaine zero-filling ---
    % case 1: intended ZF
    if flag.lcmSpecZf || lcm.fit.nspecC<lcm.nspecC          % apply ZF if 1) intended or 2) if basis FIDs shorter than target FID
        if max(lcm.specZf,lcm.nspecC)>lcm.fit.nspecC
            fid1Zf = complex(zeros(max(flag.lcmSpecZf*lcm.specZf,lcm.nspecC),1));
            fid1Zf(1:lcm.fit.nspecC,1) = lcm.fit.fidSingle;
            lcm.fit.fidSingle = fid1Zf;
            lcm.fit.nspecC    = length(lcm.fit.fidSingle);
            clear fid1Zf
        else
            fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                    FCTNAME,lcm.specZf,lcm.fit.nspecC)
        end
    end
    % case 2: basis FID shorter than target FID
%     if lcm.nspecC>length(lcmAna.fid)                            % effective data length, irrespective of ZF flag
%         lcmAnaFidZf = complex(zeros(lcm.nspecC,1));             % local only
%         lcmAnaFidZf(1:length(lcmAna.fid),1) = lcmAna.fid;
%         lcmAna.fid    = lcmAnaFidZf;
%         lcmAna.nspecC = lcm.nspecC;
%     end
    % case 3: basis FID longer than target FID
    if lcm.anaNspecC<lcm.fit.nspecC                         
        lcm.fit.fidSingle = lcm.fit.fidSingle(1:lcm.anaNspecC);
        lcm.fit.nspecC    = lcm.anaNspecC;
    end
    
    %--- spectral analysis ---
    lcm.fit.specSingle = fftshift(fft(lcm.fit.fidSingle,[],1),1);

    %--- PHC0 & PHC1 phase correction ---
    if flag.lcmAnaPhc0 && flag.lcmAnaPhc1
        if lcm.anaPhc1==0       % ensure vector format
            phaseVec = lcm.anaPhc0 * ones(lcm.fit.nspecC,1);
        else
            phaseVec = (0:lcm.anaPhc1/(lcm.fit.nspecC-1):lcm.anaPhc1)' + lcm.anaPhc0;
        end
    elseif flag.lcmAnaPhc1
        if lcm.anaPhc1==0       % ensure vector format
            phaseVec = zeros(lcm.fit.nspecC,1); 
        else
            phaseVec = (0:lcm.anaPhc1/(lcm.fit.nspecC-1):lcm.anaPhc1)'; 
        end
    elseif flag.lcmAnaPhc0
        phaseVec = ones(lcm.fit.nspecC,1)*lcm.anaPhc0;
    end
    if flag.lcmAnaPhc0 || flag.lcmAnaPhc1
        lcm.fit.specSingle = lcm.fit.specSingle .* exp(-1i*phaseVec*pi/180);
    end
        
    %--- parameter init ---
    if bCnt==1          % first basis function 
        lcm.fit.spec = complex(zeros(lcm.fit.nspecC,lcm.fit.appliedN));
    end
    
    %--- assignment of individual FID / spectra ---
    lcm.fit.spec(:,bCnt) = lcm.fit.specSingle;

    %--- FID / spectrum summation ---
    if bCnt==1
        lcm.fit.sumSpec = lcm.fit.specSingle;
    else
        lcm.fit.sumSpec = lcm.fit.sumSpec + lcm.fit.specSingle;
    end
end

%--- add polynomial ---
if flag.lcmAnaPoly
    switch lcm.anaPolyOrder
        case 0
            lcm.fit.polySpec = lcm.anaPolyCoeff(end)*ones(1,lcm.nspecC)';
        case 1
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 2
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 3
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 4
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-4)*lcm.ppmVec.^4 + ...
                               lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 5
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-5)*lcm.ppmVec.^5 + ...
                               lcm.anaPolyCoeff(end-4)*lcm.ppmVec.^4 + ...
                               lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 6
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-6)*lcm.ppmVec.^6 + ...
                               lcm.anaPolyCoeff(end-5)*lcm.ppmVec.^5 + ...
                               lcm.anaPolyCoeff(end-4)*lcm.ppmVec.^4 + ...
                               lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 7
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-7)*lcm.ppmVec.^7 + ...
                               lcm.anaPolyCoeff(end-6)*lcm.ppmVec.^6 + ...
                               lcm.anaPolyCoeff(end-5)*lcm.ppmVec.^5 + ...
                               lcm.anaPolyCoeff(end-4)*lcm.ppmVec.^4 + ...
                               lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 8
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-8)*lcm.ppmVec.^8 + ...
                               lcm.anaPolyCoeff(end-7)*lcm.ppmVec.^7 + ...
                               lcm.anaPolyCoeff(end-6)*lcm.ppmVec.^6 + ...
                               lcm.anaPolyCoeff(end-5)*lcm.ppmVec.^5 + ...
                               lcm.anaPolyCoeff(end-4)*lcm.ppmVec.^4 + ...
                               lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 9
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-9)*lcm.ppmVec.^9 + ...
                               lcm.anaPolyCoeff(end-8)*lcm.ppmVec.^8 + ...
                               lcm.anaPolyCoeff(end-7)*lcm.ppmVec.^7 + ...
                               lcm.anaPolyCoeff(end-6)*lcm.ppmVec.^6 + ...
                               lcm.anaPolyCoeff(end-5)*lcm.ppmVec.^5 + ...
                               lcm.anaPolyCoeff(end-4)*lcm.ppmVec.^4 + ...
                               lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
        case 10
            lcm.fit.polySpec = lcm.anaPolyCoeff(end-10)*lcm.ppmVec.^10 + ...
                               lcm.anaPolyCoeff(end-9)*lcm.ppmVec.^9 + ...
                               lcm.anaPolyCoeff(end-8)*lcm.ppmVec.^8 + ...
                               lcm.anaPolyCoeff(end-7)*lcm.ppmVec.^7 + ...
                               lcm.anaPolyCoeff(end-6)*lcm.ppmVec.^6 + ...
                               lcm.anaPolyCoeff(end-5)*lcm.ppmVec.^5 + ...
                               lcm.anaPolyCoeff(end-4)*lcm.ppmVec.^4 + ...
                               lcm.anaPolyCoeff(end-3)*lcm.ppmVec.^3 + ...
                               lcm.anaPolyCoeff(end-2)*lcm.ppmVec.^2 + ...
                               lcm.anaPolyCoeff(end-1)*lcm.ppmVec + ...
                               lcm.anaPolyCoeff(end);
    end
    
    %--- data modification ---
    lcm.fit.sumSpec  = lcm.fit.sumSpec + lcm.fit.polySpec;
end

%--- spline baselinen ---
% to be integrated better...
if flag.lcmAnaSpline
    if ~flag.lcmAnaPoly
        lcm.fit.polySpec = 0 * lcm.fit.sumSpec;
    end
    lcm.fit.polySpec(lcm.anaAllInd) = lcm.fit.polySpec(lcm.anaAllInd) + lcm.anaAllSplineReal;
    lcm.fit.sumSpec(lcm.anaAllInd)  = lcm.fit.sumSpec(lcm.anaAllInd)  + lcm.anaAllSplineReal;
end

%--- consistency check ---
if length(lcm.spec)~=length(lcm.fit.sumSpec)
    fprintf('%s ->\nDimension mismatch detected: target (%.0fpts) ~= fit (%.0fpts)\n.Program aborted.\n',...
            FCTNAME,length(lcm.spec),length(lcm.fit.sumSpec))
    return
end

%--- calculate residual ---
lcm.fit.resid = lcm.spec - lcm.fit.sumSpec;

%--- success flag update ---
f_done = 1;