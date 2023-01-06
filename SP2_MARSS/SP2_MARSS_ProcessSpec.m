%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_ProcessSpec
%%
%%  Spectral processing of data set
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss flag

    
FCTNAME = 'SP2_MARSS_ProcessSpec';

%--- init success flag ---
f_succ = 0;

%--- spectral analysis ---
marss.basis.spec = fftshift(fft(marss.basis.fid,[],1),1);

%--- PHC0 & PHC1 phase correction ---
phc0 = flag.marssProcPhc0*marss.procPhc0;
phc1 = flag.marssProcPhc1*marss.procPhc1;
if phc1~=0
    phaseVec = (0:phc1/(marss.basis.nspecC-1):phc1) + phc0; 
else
    phaseVec = ones(1,marss.basis.nspecC)*phc0;
end
phaseMat = permute(repmat(phaseVec,[marss.basis.n 1]),[2 1]);

%--- consistency check ---
if any(size(marss.basis.spec)~=size(phaseMat))
    fprintf('%s ->\nInconsistent data dimensions detected.\nEnsure simulations and display parameters are consistent.\n\n',FCTNAME);
    return
end

%--- apply phase correction ---
marss.basis.spec = marss.basis.spec .* exp(1i*phaseMat*pi/180);

% %--- amplitude scaling ---
% if flag.marssProcScale
%     marss.spec = marss.procScale * marss.spec;
% end

%--- update success flag ---
f_succ = 1;


end
