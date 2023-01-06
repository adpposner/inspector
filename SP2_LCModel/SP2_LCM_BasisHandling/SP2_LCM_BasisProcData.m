%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_LCM_BasisProcData( nMetab )
%% 
%%  Processing function for individual LCM basis function.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_BasisProcData';


%--- success flag init ---
f_done = 0;

%--- data selection ---
lcm.basis.fid = lcm.basis.data{nMetab}{4};

%--- initial data assignment ---
lcm.basis.nspecC = length(lcm.basis.fid);

%--- apply data modification or not ---
if flag.lcmUpdProcBasis

    %--- exponential line broadening ---
    if flag.lcmSpecLb
        %--- weighting function ---
        lbWeight = exp(-lcm.specLb*lcm.basis.dwell*(0:lcm.basis.nspecC-1)*pi)';

        %--- line broadening ---
        lcm.basis.fid = lcm.basis.fid .* lbWeight;
    end

    %--- Gaussian line broadening ---
    if flag.lcmSpecGb
        %--- weighting function ---
        gbWeight = exp(-lcm.specGb*(lcm.basis.dwell*(0:lcm.basis.nspecC-1)*pi).^2)';
        % gbWeight = exp(-pi^2/(4*log(2)) * lcm.specGb^2 * (lcm.basis.dwell*(0:lcm.basis.nspecC-1)).^2)';
        
        %--- line broadening ---
        lcm.basis.fid = lcm.basis.fid .* gbWeight;
    end

    %--- frequency shift ---
    if flag.lcmSpecShift
        %--- time vector ---
        tVec   = (0:lcm.basis.nspecC-1)' * lcm.basis.dwell;

        %--- frequency shift ---
        lcm.basis.fid = lcm.basis.fid .* exp(1i*tVec*lcm.specShift*2*pi);       % apply phase correction
    end

    %--- FID data cut-off ---
    if flag.lcmSpecCut
        if lcm.specCut<lcm.basis.nspecC
            lcm.basis.fid = lcm.basis.fid(1:lcm.specCut,1);
    %         fprintf('FID cut-off: %i -> %i\n',lcm.basis.nspecC,lcm.fidCut);
            lcm.basis.nspecC = lcm.specCut;
        else
            fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                    FCTNAME,lcm.specCut,lcm.basis.nspecC)
        end
    end

    %--- time-domaine zero-filling ---
    if flag.lcmSpecZf
        if lcm.specZf>lcm.basis.nspecC
            fid1Zf = complex(zeros(lcm.specZf,1));
            fid1Zf(1:lcm.basis.nspecC,1) = lcm.basis.fid;
            lcm.basis.fid = fid1Zf;
    %          fprintf('FID ZF: %i -> %i\n',lcm.basis.nspecC,lcm.fidZf);
            lcm.basis.nspecC = lcm.specZf;
            clear fid1Zf
        else
            fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                    FCTNAME,lcm.specZf,lcm.basis.nspecC)
        end
    end

    %--- spectral baseline offset ---
    if flag.lcmSpecOffset
        lcm.basis.fid(1) = lcm.basis.fid(1)*lcm.specOffset;
    end

    %--- spectral analysis ---
    lcm.basis.spec = fftshift(fft(lcm.basis.fid,[],1),1);

    %--- PHC0 & PHC1 phase correction ---
    %--- PHC0 & PHC1 phase correction ---
    phc0 = flag.lcmSpecPhc0*lcm.specPhc0;
    phc1 = flag.lcmSpecPhc1*lcm.specPhc1;
    if phc1~=0
        phaseVec = (0:phc1/(lcm.basis.nspecC-1):phc1) + phc0; 
    else
        phaseVec = ones(1,lcm.basis.nspecC)*phc0;
    end
    lcm.basis.spec = lcm.basis.spec .* exp(1i*phaseVec*pi/180)';

    %--- amplitude scaling ---
    if flag.lcmSpecScale
        lcm.basis.spec = lcm.specScale * lcm.basis.spec;
    end
else        % basis FFT, no further processing
    %--- spectral analysis ---
    lcm.basis.spec = fftshift(fft(lcm.basis.fid,[],1),1);
end

%--- success flag update ---
f_done = 1;
end
