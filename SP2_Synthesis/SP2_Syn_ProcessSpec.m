%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Syn_ProcessSpec
%%
%%  Spectral processing of data set
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

    
FCTNAME = 'SP2_Syn_ProcessSpec';

%--- init success flag ---
f_done = 0;

%--- spectral analysis ---
syn.spec = fftshift(fft(syn.fid,[],1),1);

%--- PHC0 & PHC1 phase correction ---
phc0 = flag.synProcPhc0*syn.procPhc0;
phc1 = flag.synProcPhc1*syn.procPhc1;
if phc1~=0
    phaseVec = (0:phc1/(syn.nspecC-1):phc1) + phc0; 
else
    phaseVec = ones(1,syn.nspecC)*phc0;
end
syn.spec = syn.spec .* exp(1i*phaseVec*pi/180)';

% %--- amplitude scaling ---
% if flag.synProcScale
%     syn.spec = syn.procScale * syn.spec;
% end

%--- update success flag ---
f_done = 1;

