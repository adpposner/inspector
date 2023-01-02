%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ProcessFid
%%
%%  Spectral processing of FID
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm flag

    
FCTNAME = 'SP2_LCM_ProcessFid';

%--- init success flag ---
f_succ = 0;

%--- initial data assignment ---
lcm.fid    = lcm.fidOrig;
lcm.nspecC = lcm.nspecCOrig;

%--- apply to target ---
if flag.lcmUpdProcTarget
    %--- amplitude scaling ---
    if flag.lcmSpecScale
        lcm.fid = lcm.specScale * lcm.fid;
    end
    
    %--- exponential line broadening ---
    if flag.lcmSpecLb
        %--- weighting function ---
        lbWeight = exp(-lcm.specLb*lcm.dwell*(0:lcm.nspecC-1)*pi)';

        %--- line broadening ---
        lcm.fid = lcm.fid .* lbWeight;
    end

    %--- Gaussian line broadening ---
    if flag.lcmSpecGb
        %--- weighting function ---
        gbWeight = exp(-lcm.specGb*(lcm.dwell*(0:lcm.nspecC-1)*pi).^2)';
        % gbWeight = exp(-pi^2/(4*log(2)) * lcm.specGb^2 * (lcm.dwell*(0:lcm.nspecC-1)).^2)';
        
        %--- line broadening ---
        lcm.fid = lcm.fid .* gbWeight;
    end

    %--- frequency shift ---
    if flag.lcmSpecShift
        %--- time vector ---
        tVec   = (0:lcm.nspecC-1)' * lcm.dwell;

        %--- frequency shift ---
        lcm.fid = lcm.fid .* exp(1i*tVec*lcm.specShift*2*pi);       % apply phase correction
    end

    %--- FID data cut-off ---
    if flag.lcmSpecCut
        if lcm.specCut<lcm.nspecC
            lcm.fid = lcm.fid(1:lcm.specCut,1);
    %         fprintf('FID cut-off: %i -> %i\n',lcm.nspecC,lcm.fidCut);
            lcm.nspecC = lcm.specCut;
        else
            if flag.verbose
                fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                        FCTNAME,lcm.specCut,lcm.nspecC)
            end
        end
    end

    %--- time-domaine zero-filling ---
    if flag.lcmSpecZf
        if lcm.specZf>lcm.nspecC
            fid1Zf = complex(zeros(lcm.specZf,1));
            fid1Zf(1:lcm.nspecC,1) = lcm.fid;
            lcm.fid = fid1Zf;
    %          fprintf('FID ZF: %i -> %i\n',lcm.nspecC,lcm.fidZf);
            lcm.nspecC = lcm.specZf;
            clear fid1Zf
        else
            if flag.verbose
                fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                        FCTNAME,lcm.specZf,lcm.nspecC)
            end
        end
    end

    %--- spectral baseline offset ---
    if flag.lcmSpecOffset
        lcm.fid(1) = lcm.fid(1)*lcm.specOffset;
    end
end

%--- update success flag ---
f_succ = 1;

