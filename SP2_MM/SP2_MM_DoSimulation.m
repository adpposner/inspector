%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function  f_succ = SP2_MM_DoSimulation( specKey )
%%
%%  Simulate saturation-recovery data sets.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag


FCTNAME = 'SP2_MM_DoSimulation';

%--- init read flag ---
f_succ = 0;
                   
%--- basic init ---
if ~isfield(mm,'spec')
    if ~SP2_MM_DataLoad
        return
    end
end
                                                                     
%--- FID simulation ---
switch specKey
    case 1              % singlets
        simN    = 3;                    % # of peaks
        simTOne = [0.1 0.5 2]           % T1 [s]
        simTTwo = [0.02 0.02 0.02]      % T2 [s]
        simFreq = [-300 -600 -900]      % offset frequency [Hz]
        simAmp  = [100 100 100]         % amplitude [a.u.]
        fidSim  = complex(zeros(mm.satRecN,mm.nspecC));
        tVec    = (0:(mm.nspecC-1))*mm.dwell;
        for srCnt = 1:mm.satRecN        % individual saturation-recovery experiments
            for simCnt = 1:simN         % multiple signals of single spectrum
                fidSim(srCnt,:) = fidSim(srCnt,:) + ...
                                  simAmp(simCnt) * ...                                  % amplitude
                                  exp(-2*pi*1i*simFreq(simCnt)*tVec) .* ...             % frequency
                                  exp(-tVec/simTTwo(simCnt)) .* ...                     % T2
                                  (1-exp(-mm.satRecDelays(srCnt)/simTOne(simCnt)));     % T1
            end
            if flag.mmSimNoise
                fidSim(srCnt,:) = fidSim(srCnt,:) + randn(1,mm.nspecC).*exp((1i*randn(1,mm.nspecC)));   % noise
            end
        end
        fprintf('Simple singlet spectrum simulated for %.0f saturation-recovery delays.\n',mm.satRecN);
    case 2              % singlets + broad humps
        simN    = 6;                                    % # of peaks
        simTOne = [0.20 0.25 0.3 0.9 1.6 2]            % T1 [s]
        simTTwo = [0.002 0.003 0.004 0.03 0.03 0.03]          % T2 [s]
        simFreq = [-100 -400 -750 -300 -500 -700]            %  offset frequency [Hz]
        simAmp  = [800 300 200 100 100 100]                 % amplitude [a.u.]
        fidSim  = complex(zeros(mm.satRecN,mm.nspecC));
        tVec    = (0:(mm.nspecC-1))*mm.dwell;
        for srCnt = 1:mm.satRecN        % individual saturation-recovery experiments
            for simCnt = 1:simN         % multiple signals of single spectrum
                fidSim(srCnt,:) = fidSim(srCnt,:) + ...
                                  simAmp(simCnt) * ...                                  % amplitude
                                  exp(-2*pi*1i*simFreq(simCnt)*tVec) .* ...             % frequency
                                  exp(-tVec/simTTwo(simCnt)) .* ...                     % T2
                                  (1-exp(-mm.satRecDelays(srCnt)/simTOne(simCnt)));     % T1
            end
            if flag.mmSimNoise
                fidSim(srCnt,:) = fidSim(srCnt,:) + randn(1,mm.nspecC).*exp((1i*randn(1,mm.nspecC)));   % noise
            end
        end
        fprintf('Realistic spectrum simulated for %.0f saturation-recovery delays.\n',mm.satRecN);
end
    

%--- spectrum reconstruction ---
mm.fid  = fidSim';
mm.spec = complex(zeros(mm.nspecC,mm.satRecN));
for srCnt = 1:mm.satRecN
    mm.spec(:,srCnt) = fftshift(fft(mm.fid(:,srCnt),mm.zf));
end

%--- update read flag ---
f_succ = 1;
