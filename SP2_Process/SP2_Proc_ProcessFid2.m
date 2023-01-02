%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_ProcessFid2
%%
%%  Spectral processing of FID 2
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

    
FCTNAME = 'SP2_Proc_DoProcessFid2';

%--- init success flag ---
f_succ = 0;

%--- initial data assignment ---
proc.spec2.fid    = proc.spec2.fidOrig;
proc.spec2.nspecC = proc.spec2.nspecCOrig;

% %--- automatic eddy current, frequency and amplitude correction ---
% if flag.procECCorr               % frequ. & amplitude correction
%     if ~SP2_Proc_ECCorr(2)    
%         fprintf('%s ->\neddy current correction failed.\nProgram aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if flag.procFreqCorr             % frequency correction
%     if ~SP2_Proc_FreqCorr(2)   
%         fprintf('%s ->\nfrequency correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end
% if flag.procAmplCorr             % amplitude correction (only)
%     if ~SP2_Proc_AmplCorr(2) 
%         fprintf('%s ->\namplitude correction failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end


%--- FID data cut-off ---
if flag.procSpec2Cut
    if proc.spec2.cut<proc.spec2.nspecC
        proc.spec2.fid = proc.spec2.fid(1:proc.spec2.cut,1);
%         fprintf('FID cut-off: %i -> %i\n',proc.nspecC,proc.fidCut);
        proc.spec2.nspecC = proc.spec2.cut;
    else
        fprintf('%s ->\nCut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,proc.spec2.cut,proc.spec2.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.procSpec2Zf
    if proc.spec2.zf>proc.spec2.nspecC
        fid2Zf = complex(zeros(proc.spec2.zf,1));
        fid2Zf(1:proc.spec2.nspecC,1) = proc.spec2.fid;
        proc.spec2.fid = fid2Zf;
%         fprintf('FID ZF: %i -> %i\n',proc.nspecC,proc.fidZf);
        proc.spec2.nspecC = proc.spec2.zf;
        clear fid2Zf
    else
        fprintf('%s ->\nZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,proc.spec2.zf,proc.spec2.nspecC)
    end
end

%--- amplitude scaling ---
% 09/2018, moved from SP2_Proc_ProcessSpec2
if flag.procSpec2Scale
    proc.spec2.fid = proc.spec2.scale * proc.spec2.fid;
end

%--- exponential line broadening ---
if flag.procSpec2Lb
    [proc.spec2.fid, f_done] = SP2_Proc_ExpLineBroadening(proc.spec2);
    if ~f_done
        fprintf('%s ->\nExponential line broadening of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- Gaussian line broadening ---
if flag.procSpec2Gb
    [proc.spec2.fid, f_done] = SP2_Proc_GaussianLineBroadening(proc.spec2);
    if ~f_done
        fprintf('%s ->\nGaussian line broadening of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- frequency shift ---
if flag.procSpec2Shift
    [proc.spec2.fid,f_done] = SP2_Proc_FreqShift(proc.spec2);
    if ~f_done
        fprintf('%s ->\nFrequency shift of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- spectral baseline offset ---
if flag.procSpec2Offset
    proc.spec2.fid(1) = proc.spec2.fid(1)*proc.spec2.offset;
end

%--- update success flag ---
f_succ = 1;

