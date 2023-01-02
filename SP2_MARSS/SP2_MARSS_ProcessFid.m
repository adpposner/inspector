%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_ProcessFid
%%
%%  Spectral processing of FID
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile marss flag

    
FCTNAME = 'SP2_MARSS_ProcessFid';

%--- init success flag ---
f_succ = 0;

%--- initial data assignment ---
marss.basis.fid    = marss.basis.fidOrig;
marss.basis.nspecC = marss.basis.nspecCOrig;

%--- amplitude scaling ---
if flag.marssProcScale
    marss.basis.fid = marss.procScale * marss.basis.fid;
end

%--- exponential line broadening ---
if flag.marssProcLb
    %--- weighting function ---
    lbWeight    = exp(-marss.procLb*marss.basis.dwell*(0:marss.basis.nspecC-1)*pi)';
    lbWeightMat = repmat(lbWeight,[1 marss.basis.n]);

    %--- consistency check ---
    if any(size(marss.basis.fid)~=size(lbWeightMat))
        fprintf('%s ->\nInconsistent data dimensions detected (LB).\nEnsure simulations and display parameters are consistent.\n\n',FCTNAME);
        return
    end    
    
    %--- Lorentzian line broadening ---
    marss.basis.fid = marss.basis.fid .* lbWeightMat;
end

%--- Gaussian line broadening ---
if flag.marssProcGb
    %--- weighting function ---
    gbWeight = exp(-marss.procGb*(marss.basis.dwell*(0:marss.basis.nspecC-1)*pi).^2)';
    % gbWeight = exp(-pi^2/(4*log(2)) * marss.procGb^2 * (marss.basis.dwell*(0:marss.basis.nspecC-1)).^2)';
    gbWeightMat = repmat(gbWeight,[1 marss.basis.n]);

    %--- consistency check ---
    if any(size(marss.basis.fid)~=size(gbWeightMat))
        fprintf('%s ->\nInconsistent data dimensions detected (GB).\nEnsure simulations and display parameters are consistent.\n\n',FCTNAME);
        return
    end    

    %--- Gaussian line broadening ---
    marss.basis.fid = marss.basis.fid .* gbWeightMat;
end

%--- frequency shift ---
if flag.marssProcShift
    %--- time vector ---
    tVec    = (0:marss.basis.nspecC-1)' * marss.basis.dwell;
    tVecMat = repmat(tVec,[1 marss.basis.n]);
        
    %--- consistency check ---
    if any(size(marss.basis.fid)~=size(tVecMat))
        fprintf('%s ->\nInconsistent data dimensions detected (Shift).\nEnsure simulations and display parameters are consistent.\n\n',FCTNAME);
        return
    end    
    
    %--- frequency shift ---
    marss.basis.fid = marss.basis.fid .* exp(1i*tVecMat*marss.procShift*2*pi);       % apply phase correction
end

%--- FID data cut-off ---
if flag.marssProcCut
    if marss.procCut<marss.basis.nspecC
        marss.basis.fid = marss.basis.fid(1:marss.procCut,:);
%         fprintf('FID cut-off: %i -> %i\n',marss.nspecC,marss.fidCut);
        marss.basis.nspecC = marss.procCut;
    else
        fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,marss.procCut,marss.basis.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.marssProcZf
    if marss.procZf>marss.basis.nspecC
        fid1Zf = complex(zeros(marss.procZf,marss.basis.n));
        fid1Zf(1:marss.basis.nspecC,:) = marss.basis.fid;
        marss.basis.fid = fid1Zf;
%          fprintf('FID ZF: %i -> %i\n',marss.nspecC,marss.fidZf);
        marss.basis.nspecC = marss.procZf;
        clear fid1Zf
    else
        fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,marss.procZf,marss.basis.nspecC)
    end
end

%--- spectral baseline offset ---
if flag.marssProcOffset
    marss.basis.fid(1,:) = marss.basis.fid(1,:)*marss.procOffset;
end

%--- update success flag ---
f_succ = 1;

