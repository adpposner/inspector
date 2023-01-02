%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Syn_DoSimNoise
%%
%%  Simulate noise spectrum of known power.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile syn flag

FCTNAME = 'SP2_Syn_DoSimNoise';


%--- parameter settings ---
% syn.nspecCOrig = syn.nspecC;
syn.sw         = syn.sw_h/syn.sf;
syn.dwell      = 1/syn.sw_h;

         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- init read flag ---
f_succ = 0;

%--- FID creation ---
syn.fidOrig = complex(zeros(syn.nspecCBasic,1));
% fprintf('Spectrum with Gaussian (white) noise created\n');

%--- offset correction ---
syn.fidOrig(1) = syn.fidOrig(1)/2;

%--- data assignment ---
syn.fid        = syn.fidOrig;
syn.nspecC     = syn.nspecCBasic;
syn.nspecCOrig = syn.nspecC;

%--- noise handling ---
if flag.synNoise
    % syn.fidOrig = syn.fidOrig + syn.noiseAmp * randn(1,syn.nspecC)'.*exp((1i*randn(1,syn.nspecC)'));   % noise
    %--- create noise ---
    if ~isfield(syn,'noiseNspecC')
        syn.noiseNspecC = 1;                % fake assignment
    end
    if ~flag.synNoiseKeep || ~isfield(syn,'noise') || syn.nspecC~=syn.noiseNspecC       
        syn.noise = (syn.noiseAmp*sqrt(syn.sw_h)) * randn(1,syn.nspecC)' + ...
                    1i*(syn.noiseAmp*sqrt(syn.sw_h)) * randn(1,syn.nspecC)';
        syn.noiseNspecC = syn.nspecC;
    end
    
    %--- add noise to FID ---
    syn.fid = syn.fid + syn.noise;
%     fprintf('Gaussian (white) noise added\n');
end

%--- spectral processing ---
if ~SP2_Syn_ProcData
    return
end

%--- polynomial baseline ----
if flag.synPoly
    %--- x-axis with [ppm]-based scale ---
    % note that this convention makes it independent of the number of spectral points per ppm, i.e. nspecC
    fprintf('Points per ppm: %.0f\n',(syn.nspecC-1)/syn.sw)               % points per ppm
    synPpmVec = (-syn.sw/2:syn.sw/(syn.nspecC-1):syn.sw/2)' + (syn.ppmCalib-syn.polyCenterPpm);
    syn.spec = syn.spec + ...
               syn.polyAmpVec(6) * synPpmVec.^5 + ...
               syn.polyAmpVec(5) * synPpmVec.^4 + ...
               syn.polyAmpVec(4) * synPpmVec.^3 + ...
               syn.polyAmpVec(3) * synPpmVec.^2 + ...
               syn.polyAmpVec(2) * synPpmVec + ...
               syn.polyAmpVec(1);
end

%--- FID creation ---
syn.fid = ifft(ifftshift(syn.spec,1),[],1);

%--- signal source ---
flag.synSource = 1;

%--- figure update ---
if ~SP2_Syn_FigureUpdate
    fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- info printout ---
fprintf('Pure noise spectrum created\n');

%--- update success flag ---
f_succ = 1;




