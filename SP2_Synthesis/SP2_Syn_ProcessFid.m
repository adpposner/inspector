%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Syn_ProcessFid
%%
%%  Spectral processing of FID
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

    
FCTNAME = 'SP2_Syn_ProcessFid';

%--- init success flag ---
f_done = 0;

%--- initial data assignment ---
% syn.fid    = syn.fidOrig;
% syn.nspecC = syn.nspecCOrig;


%--- amplitude scaling ---
if flag.synProcScale
    syn.fid = syn.procScale * syn.fid;
end

%--- exponential line broadening ---
if flag.synProcLb
    %--- weighting function ---
    lbWeight = exp(-syn.procLb*syn.dwell*(0:syn.nspecC-1)*pi)';

    %--- line broadening ---
    syn.fid = syn.fid .* lbWeight;
end

%--- Gaussian line broadening ---
if flag.synProcGb
    %--- weighting function ---
    gbWeight = exp(-syn.procGb*(syn.dwell*(0:syn.nspecC-1)*pi).^2)';
    % gbWeight = exp(-pi^2/(4*log(2)) * sign(syn.procGb)*syn.procGb^2 * (syn.dwell*(0:syn.nspecC-1)).^2)';
    
    %--- line broadening ---
    syn.fid = syn.fid .* gbWeight;
end

%--- frequency shift ---
if flag.synProcShift
    %--- time vector ---
    tVec   = (0:syn.nspecC-1)' * syn.dwell;
    
    %--- frequency shift ---
    syn.fid = syn.fid .* exp(1i*tVec*syn.procShift*2*pi);       % apply phase correction
end

%--- FID data cut-off ---
if flag.synProcCut
    if syn.procCut<syn.nspecC
        syn.fid = syn.fid(1:syn.procCut,1);
%         fprintf('FID cut-off: %i -> %i\n',syn.nspecC,syn.fidCut)
        syn.nspecC = syn.procCut;
    else
        fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,syn.procCut,syn.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.synProcZf
    if syn.procZf>syn.nspecC
        fid1Zf = complex(zeros(syn.procZf,1));
        fid1Zf(1:syn.nspecC,1) = syn.fid;
        syn.fid = fid1Zf;
%          fprintf('FID ZF: %i -> %i\n',syn.nspecC,syn.fidZf)
        syn.nspecC = syn.procZf;
        clear fid1Zf
    else
        fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,syn.procZf,syn.nspecC)
    end
end

%--- spectral baseline offset ---
if flag.synProcOffset
    syn.fid(1) = syn.fid(1)*syn.procOffset;
end

%--- update success flag ---
f_done = 1;

