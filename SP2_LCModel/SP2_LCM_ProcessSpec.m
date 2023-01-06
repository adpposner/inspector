%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_ProcessSpec
%%
%%  Spectral processing of data set
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

    
FCTNAME = 'SP2_LCM_ProcessSpec';

%--- init success flag ---
f_succ = 0;

%--- spectral analysis ---
lcm.spec = fftshift(fft(lcm.fid,[],1),1);

%--- apply to target ---
if flag.lcmUpdProcTarget
    %--- PHC0 & PHC1 phase correction ---
    phc0 = flag.lcmSpecPhc0*lcm.specPhc0;
    phc1 = flag.lcmSpecPhc1*lcm.specPhc1;
    if phc1~=0
        phaseVec = (0:phc1/(lcm.nspecC-1):phc1) + phc0; 
    else
        phaseVec = ones(1,lcm.nspecC)*phc0;
    end
    lcm.spec = lcm.spec .* exp(1i*phaseVec*pi/180)';

%     %--- amplitude scaling ---
%     if flag.lcmSpecScale
%         lcm.spec = lcm.specScale * lcm.spec;
%     end
end

%--- update success flag ---
f_succ = 1;


end
