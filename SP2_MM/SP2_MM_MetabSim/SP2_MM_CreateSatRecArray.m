%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_CreateSatRecArray
%%
%%  Creation of saturation-recovery array for preloaded FID based on
%%  predefined parameter settings.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag

FCTNAME = 'SP2_MM_CreateSatRecArray';


%--- init read flag ---
f_succ = 0;

%--- simulation of saturation-recovery FID array ---
mm.fid  = complex(zeros(mm.nspecC,mm.satRecN));
tVec    = (0:(mm.nspecC-1))'*mm.dwell;
for srCnt = 1:mm.satRecN        % individual saturation-recovery experiments
    mm.fid(:,srCnt) = mm.sim.fid .* ...                                 % base FID
                      exp(-tVec/mm.sim.t2) * ...                        % T2
                      (1-exp(-mm.satRecDelays(srCnt)/mm.sim.t1));       % T1
    if flag.mmSimNoise
        mm.fid(:,srCnt) = mm.fid(:,srCnt) + randn(1,mm.nspecC)'/5.*exp((1i*randn(1,mm.nspecC))).';   % noise
    end
end
fprintf('Simple singlet spectrum simulated for %.0f saturation-recovery delays.\n',mm.satRecN);

%--- spectrum reconstruction ---
mm.spec = complex(zeros(mm.nspecC,mm.satRecN));
for srCnt = 1:mm.satRecN
    %--- basic reco (no apod/ZF) ---
    % mm.spec(:,srCnt) = fftshift(fft(mm.fid(:,srCnt),mm.zf));

    %--- full processing options ---
    if mm.nspecC<mm.cut        % no apodization
        lbWeight = exp(-mm.lb*mm.dwell*(0:mm.nspecC-1)*pi)';
        mm.spec(:,srCnt) = fftshift(fft(mm.fid(:,srCnt).*lbWeight,mm.zf));
    else                                    % apodization
        lbWeight = exp(-mm.lb*mm.dwell*(0:mm.cut-1)*pi)';
        mm.spec(:,srCnt) = fftshift(fft(mm.fid(1:mm.cut,srCnt).*lbWeight,mm.zf));
        if srCnt==1
            fprintf('%s ->\nApodization of FID to %.0f points applied.\n',...
                    FCTNAME,mm.cut)
        end
    end
    mm.spec(:,srCnt) = mm.spec(:,srCnt) .* exp(1i*mm.phaseZero*pi/180)';
end

%--- update read flag ---
f_succ = 1;
