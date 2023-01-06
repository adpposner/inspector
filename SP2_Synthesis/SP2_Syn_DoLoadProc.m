%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_Syn_DoLoadProc
%%
%%  Load spectrum from Processing page.
%%
%%  11-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag proc fm


FCTNAME = 'SP2_Syn_DoLoadProc';

         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    P R O G R A M     S T A R T                                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- init read flag ---
f_succ = 0;

%--- data assignment ---
if isfield(proc,'expt')
    if isfield(proc.expt,'fid')
        %--- format handling ---
        syn.fidOrig = proc.expt.fid;
        syn.sf      = proc.expt.sf;
        syn.sw_h    = proc.expt.sw_h;
        syn.sw      = proc.expt.sw_h/syn.sf;
        syn.dwell   = 1/syn.sw_h;
        
        %--- window update ---
        set(fm.syn.sf,'String',num2str(syn.sf))
        set(fm.syn.sw_h,'String',num2str(syn.sw_h))
        
        %--- consistency check ---
        if ndims(syn.fidOrig)>1
            fprintf('FID dimension: %s\n',FCTNAME,SP2_Vec2PrintStr(size(syn.fidOrig),0));
        end
    else
        fprintf('%s ->\nNo raw data found. Program aborted.\n\n',FCTNAME);
        return
    end
else
    fprintf('%s ->\nNo data structure found. Program aborted.\n',FCTNAME);
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
flag.synSource = 5;

%--- figure update ---
if ~SP2_Syn_FigureUpdate
    fprintf('%s ->\nFigure updating failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- info printout ---
fprintf('FID loaded from Processing page\n');

%--- update success flag ---
f_succ = 1;

end
