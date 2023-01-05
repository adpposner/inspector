%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_DoProcessing
%%
%%  Spectral processing of time domain data
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

    
FCTNAME = 'SP2_Proc_DoProcessing';

%--- init success flag ---
f_done = 0;

%--- initial data assignment ---
proc.spec1.fid = proc.spec1.fidOrig;
proc.spec2.fid = proc.spec2.fidOrig;

%--- automatic eddy current, frequency and amplitude correction ---
if flag.procECCorr               % frequ. & amplitude correction
    if ~SP2_Proc_ECCorr    
        fprintf('%s ->\neddy current correction failed.\nProgram aborted.\n\n',FCTNAME);
        return
    end
end
if flag.procFreqCorr             % frequency correction
    if ~SP2_Proc_FreqCorr    
        fprintf('%s ->\nfrequency correction failed. Program aborted.\n\n',FCTNAME);
        return
    end
end
if flag.procAmplCorr             % amplitude correction (only)
    if ~SP2_Proc_AmplCorr    
        fprintf('%s ->\namplitude correction failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- data summation ---
proc.spec1.fid = sum(proc.spec1.fid);
proc.spec2.fid = sum(proc.spec2.fid);

%--- exponential linebroadening ---
[proc.spec1.fid, f_done] = SP2_Proc_ExpLineBroadening(proc.spec1.fid,...
                                                      flag.procSpec1Lb*proc.spec1.lb);
if ~f_done
    fprintf('%s ->\nline broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end
[proc.spec2.fid, f_done] = SP2_Proc_ExpLineBroadening(proc.spec2.fid,...
                                                      flag.procSpec2Lb*proc.spec2.lb);
if ~f_done
    fprintf('%s ->\nline broadening of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- frequency shift ---
if flag.procSpec1Shift
    [proc.spec1.fid,f_done] = SP2_Proc_FreqShift(proc.spec1.fid,proc.spec1.shift);
    if ~f_done
        fprintf('%s -> frequency shift of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end
if flag.procSpec2Shift
    [proc.spec2.fid,f_done] = SP2_Proc_FreqShift(proc.spec2.fid,proc.spec2.shift);
    if ~f_done
        fprintf('%s -> frequency shift of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- FID data cut-off ---
if flag.procFidCut
    if proc.fidCut<proc.nspecC
        proc.spec1.fid = proc.spec1.fid(1,1:proc.fidCut);
        proc.spec2.fid = proc.spec2.fid(1,1:proc.fidCut);
        fprintf('FID cut-off: %i -> %i\n',proc.nspecC,proc.fidCut);
        proc.nspecC    = proc.fidCut;
    else
        fprintf('%s ->\n cut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,proc.fidCut,proc.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.procFidZf
    if proc.fidZf>proc.nspecC
        fid1Zf = complex(zeros(1,proc.fidZf));
        fid2Zf = complex(zeros(1,proc.fidZf));
        fid1Zf(1,1:proc.nspecC) = proc.spec1.fid;
        fid2Zf(1,1:proc.nspecC) = proc.spec2.fid;
        proc.spec1.fid = fid1Zf;
        proc.spec2.fid = fid2Zf;
        fprintf('FID ZF: %i -> %i\n',proc.nspecC,proc.fidZf);
        proc.nspecC    = proc.fidZf;
        clear fid1Zf fid2Zf
    else
        fprintf('%s ->\n ZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,proc.fidZf,proc.nspecC)
    end
end

%--- FID difference calculation ---
proc.diff.fid = proc.spec1.fid - proc.spec2.fid;

%--- spectral analysis ---
[proc.spec1.specOrig, f_done] = SP2_Proc_SpectralFft(proc.spec1.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end
[proc.spec2.specOrig, f_done] = SP2_Proc_SpectralFft(proc.spec2.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- PHC0 & PHC1 phase correction ---
[proc.spec1.spec, f_done] = SP2_Proc_PhaseCorr(proc.spec1.specOrig,...
                                               flag.procSpec1Phc0*proc.spec1.phc0,...
                                               flag.procSpec1Phc1*proc.spec1.phc1);
if ~f_done
    fprintf('%s ->\nphasing of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end
[proc.spec2.spec, f_done] = SP2_Proc_PhaseCorr(proc.spec2.specOrig,...
                                               flag.procSpec2Phc0*proc.spec2.phc0,...
                                               flag.procSpec2Phc1*proc.spec2.phc1);
if ~f_done
    fprintf('%s ->\nphasing of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- amplitude scaling ---
if flag.procSpec1Scale
    proc.spec1.spec = proc.spec1.scale * proc.spec1.spec;
end
if flag.procSpec2Scale
    proc.spec2.spec = proc.spec2.scale * proc.spec2.spec;
end

%--- difference spectrum calculation ---
proc.diff.spec = proc.spec1.spec - proc.spec2.spec;

%--- display selection ---
if flag.procFormat==1        % real
    proc.spec1.specDispl = real(proc.spec1.spec);
    proc.spec2.specDispl = real(proc.spec2.spec);
    proc.diff.specDispl  = real(proc.diff.spec);
elseif flag.procFormat==2    % imaginary
    proc.spec1.specDispl = imag(proc.spec1.spec);
    proc.spec2.specDispl = imag(proc.spec2.spec);
    proc.diff.specDispl  = imag(proc.diff.spec);
else                        % magnitude
    proc.spec1.specDispl = abs(proc.spec1.spec);
    proc.spec2.specDispl = abs(proc.spec2.spec);
    proc.diff.specDispl  = abs(proc.diff.spec);
end

%--- plot FID superposition ---
if flag.procPlotFid
    SP2_Proc_PlotFidSuperpos
end

%--- plot spectrum superposition ---
SP2_Proc_PlotSpecSuperpos

%--- update success flag ---
f_done = 1;

%--- analysis done at least once: yes ---
flag.procProcInit = 1;
