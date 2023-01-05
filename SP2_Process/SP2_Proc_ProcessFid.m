%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [spec, f_succ] = SP2_Proc_ProcessFid(spec)
%%
%%  Spectral processing of FID
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile procSpecFlags

    
FCTNAME = 'SP2_Proc_DoProcessFid1';

%--- init success procSpecFlags ---
f_succ = 0;

%--- initial data assignment ---
spec.fid    = spec.fidOrig;
spec.nspecC = spec.nspecCOrig;

% %--- automatic eddy current, frequency and amplitude correction ---
% if procSpecFlags.procECCorr               % frequ. & amplitude correction
%     if ~SP2_Proc_ECCorr(1)    
%         fprintf('%s ->\neddy current correction failed.\nProgram aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if procSpecFlags.procFreqCorr             % frequency correction
%     if ~SP2_Proc_FreqCorr(1)   
%         fprintf('%s ->\nfrequency correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if procSpecFlags.procAmplCorr             % amplitude correction (only)
%     if ~SP2_Proc_AmplCorr(1) 
%         fprintf('%s ->\namplitude correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end


%--- FID data cut-off ---
if procSpecFlags.procSpecCut
    if spec.cut<spec.nspecC
        spec.fid = spec.fid(1:spec.cut,1);
%         fprintf('FID cut-off: %i -> %i\n',proc.nspecC,proc.fidCut);
        spec.nspecC = spec.cut;
    else
        fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,spec.cut,spec.nspecC)
    end
end

%--- time-domaine zero-filling ---
if procSpecFlags.procSpecZf
    if spec.zf>spec.nspecC
        fid1Zf = complex(zeros(spec.zf,1));
        fid1Zf(1:spec.nspecC,1) = spec.fid;
        spec.fid = fid1Zf;
%          fprintf('FID ZF: %i -> %i\n',proc.nspecC,proc.fidZf);
        spec.nspecC = spec.zf;
        clear fid1Zf
    else
        fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,spec.zf,spec.nspecC)
    end
end

%--- amplitude scaling ---
% 09/2018, moved from SP2_Proc_ProcessSpec2
if procSpecFlags.procSpecScale
    spec.fid = spec.scale * spec.fid;
end

%--- exponential line broadening ---
if procSpecFlags.procSpecLb
    [spec.fid, f_done] = SP2_Proc_ExpLineBroadening(spec);
    if ~f_done
        fprintf('%s ->\nExponential line broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- Gaussian line broadening ---
if procSpecFlags.procSpecGb
    [spec.fid, f_done] = SP2_Proc_GaussianLineBroadening(spec);
    if ~f_done
        fprintf('%s ->\nGaussian line broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- frequency shift ---
if procSpecFlags.procSpecShift
    [spec.fid,f_done] = SP2_Proc_FreqShift(spec);
    if ~f_done
        fprintf('%s ->\nFrequency shift of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- spectral baseline offset ---
if procSpecFlags.procSpecOffset
    spec.fid(1) = spec.fid(1)*spec.offset;
end

%--- zero-order phase (testing, not applied!) ---
% spec.fid = spec.fid*exp(-1i*pi/2);
% tVec = 0:spec.dwell:(spec.nspecC-1)*spec.dwell;
% spec.fid = spec.fid .* exp(-1i*2*pi*1500*tVec).';


%--- update success procSpecFlags ---
f_succ = 1;

