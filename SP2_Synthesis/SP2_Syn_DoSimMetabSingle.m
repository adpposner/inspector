%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Syn_DoSimMetabSingle
%%
%%  Simulate spectrum of single metabolite.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag fm


FCTNAME = 'SP2_Syn_DoSimMetabSingle';

         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- init read flag ---
f_succ = 0;

%--- load parameter file ---
fprintf('\n');
% if ~SP2_Syn_LoadParFile(syn.fidPathPar)
%     return
% end
if ~SP2_CheckFileExistenceR(syn.fidPath)
    return
end

%--- load metabolite FID from file ---
if strcmp(syn.fidPath(end-3:end),'.par')
    if ~SP2_Syn_LoadParFile(syn.fidPath)                                    % parameter file
       return
    end
    [syn.fidOrig,f_done] = SP2_RagLoadFid(syn.fidPath(1:end-4));            % FID data
    if ~f_done
        return
    end
elseif strcmp(syn.fidPath(end-3:end),'.mat')
    [syn.fidOrig,nspecC,sf,sw_h,f_done] = SP2_Syn_LoadMatFile(syn.fidPath);
    if ~f_done
        return
    end
elseif strcmp(syn.fidPath(end-3:end),'.raw')
    [syn.fidOrig,f_done] = SP2_Syn_LoadRawFile(syn.fidPath);
    if ~f_done
        return
    end
elseif strcmp(syn.fidPath(end-3:end),'.RAW')
    [syn.fidOrig,f_done] = SP2_Syn_LoadRawFile(syn.fidPath);
    if ~f_done
        return
    end
else
    fprintf('\n%s ->\nInvalid file format detected. Metabolite file assignment failed.\n',FCTNAME);
    return
end

%--- data assignment ---
if length(syn.fidOrig)>=syn.nspecCBasic
    syn.fid = syn.fidOrig(1:syn.nspecCBasic,1);
else
    fprintf('Basis data length exceeds length of selected metabolite FID (%.0f pts).\nBasis data length reduced accordingly.\n',length(syn.fidOrig));
    syn.nspecCBasic = length(syn.fidOrig);
    set(fm.syn.nspecCBasic,'String',num2str(syn.nspecCBasic))
    syn.fid         = syn.fidOrig;
end
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
flag.synSource = 3;

%--- figure update ---
if ~SP2_Syn_FigureUpdate
    fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- window update ---
SP2_Syn_SynthesisWinUpdate

%--- info printout ---
fprintf('Single metabolite spectrum loaded\n');

%--- update success flag ---
f_succ = 1;
