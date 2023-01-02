%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ProcessFid1
%%
%%  Spectral processing of FID 1
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

    
FCTNAME = 'SP2_Proc_DoProcessFid1';

%--- init success flag ---
f_succ = 0;

%--- initial data assignment ---
proc.spec1.fid    = proc.spec1.fidOrig;
proc.spec1.nspecC = proc.spec1.nspecCOrig;

% %--- automatic eddy current, frequency and amplitude correction ---
% if flag.procECCorr               % frequ. & amplitude correction
%     if ~SP2_Proc_ECCorr(1)    
%         fprintf('%s ->\neddy current correction failed.\nProgram aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if flag.procFreqCorr             % frequency correction
%     if ~SP2_Proc_FreqCorr(1)   
%         fprintf('%s ->\nfrequency correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if flag.procAmplCorr             % amplitude correction (only)
%     if ~SP2_Proc_AmplCorr(1) 
%         fprintf('%s ->\namplitude correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end


%--- FID data cut-off ---
if flag.procSpec1Cut
    if proc.spec1.cut<proc.spec1.nspecC
        proc.spec1.fid = proc.spec1.fid(1:proc.spec1.cut,1);
%         fprintf('FID cut-off: %i -> %i\n',proc.nspecC,proc.fidCut);
        proc.spec1.nspecC = proc.spec1.cut;
    else
        fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,proc.spec1.cut,proc.spec1.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.procSpec1Zf
    if proc.spec1.zf>proc.spec1.nspecC
        fid1Zf = complex(zeros(proc.spec1.zf,1));
        fid1Zf(1:proc.spec1.nspecC,1) = proc.spec1.fid;
        proc.spec1.fid = fid1Zf;
%          fprintf('FID ZF: %i -> %i\n',proc.nspecC,proc.fidZf);
        proc.spec1.nspecC = proc.spec1.zf;
        clear fid1Zf
    else
        fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,proc.spec1.zf,proc.spec1.nspecC)
    end
end

%--- amplitude scaling ---
% 09/2018, moved from SP2_Proc_ProcessSpec2
if flag.procSpec1Scale
    proc.spec1.fid = proc.spec1.scale * proc.spec1.fid;
end

%--- exponential line broadening ---
if flag.procSpec1Lb
    [proc.spec1.fid, f_done] = SP2_Proc_ExpLineBroadening(proc.spec1);
    if ~f_done
        fprintf('%s ->\nExponential line broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- Gaussian line broadening ---
if flag.procSpec1Gb
    [proc.spec1.fid, f_done] = SP2_Proc_GaussianLineBroadening(proc.spec1);
    if ~f_done
        fprintf('%s ->\nGaussian line broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- frequency shift ---
if flag.procSpec1Shift
    [proc.spec1.fid,f_done] = SP2_Proc_FreqShift(proc.spec1);
    if ~f_done
        fprintf('%s ->\nFrequency shift of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- spectral baseline offset ---
if flag.procSpec1Offset
    proc.spec1.fid(1) = proc.spec1.fid(1)*proc.spec1.offset;
end

%--- zero-order phase (testing, not applied!) ---
% proc.spec1.fid = proc.spec1.fid*exp(-1i*pi/2);
% tVec = 0:proc.spec1.dwell:(proc.spec1.nspecC-1)*proc.spec1.dwell;
% proc.spec1.fid = proc.spec1.fid .* exp(-1i*2*pi*1500*tVec).';


%--- update success flag ---
f_succ = 1;

