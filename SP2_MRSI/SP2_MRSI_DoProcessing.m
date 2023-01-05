%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_DoProcessing
%%
%%  Spectral processing of time domain data
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

    
FCTNAME = 'SP2_MRSI_DoProcessing';

%--- init success flag ---
f_done = 0;

%--- initial data assignment ---
mrsi.spec1.fid = mrsi.spec1.fidOrig;
mrsi.spec2.fid = mrsi.spec2.fidOrig;

%--- automatic eddy current, frequency and amplitude correction ---
if flag.mrsiECCorr               % frequ. & amplitude correction
    if ~SP2_MRSI_ECCorr    
        fprintf('%s ->\neddy current correction failed.\nProgram aborted.\n\n',FCTNAME);
        return
    end
end
if flag.mrsiFreqCorr             % frequency correction
    if ~SP2_MRSI_FreqCorr    
        fprintf('%s ->\nfrequency correction failed. Program aborted.\n\n',FCTNAME);
        return
    end
end
if flag.mrsiAmplCorr             % amplitude correction (only)
    if ~SP2_MRSI_AmplCorr    
        fprintf('%s ->\namplitude correction failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- data summation ---
mrsi.spec1.fid = sum(mrsi.spec1.fid);
mrsi.spec2.fid = sum(mrsi.spec2.fid);

%--- exponential linebroadening ---
[mrsi.spec1.fid, f_done] = SP2_MRSI_ExpLineBroadening(mrsi.spec1.fid,...
                                                      flag.mrsiSpec1Lb*mrsi.spec1.lb);
if ~f_done
    fprintf('%s ->\nline broadening of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end
[mrsi.spec2.fid, f_done] = SP2_MRSI_ExpLineBroadening(mrsi.spec2.fid,...
                                                      flag.mrsiSpec2Lb*mrsi.spec2.lb);
if ~f_done
    fprintf('%s ->\nline broadening of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- frequency shift ---
if flag.mrsiSpec1Shift
    [mrsi.spec1.fid,f_done] = SP2_MRSI_FreqShift(mrsi.spec1.fid,mrsi.spec1.shift);
    if ~f_done
        fprintf('%s -> frequency shift of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end
if flag.mrsiSpec2Shift
    [mrsi.spec2.fid,f_done] = SP2_MRSI_FreqShift(mrsi.spec2.fid,mrsi.spec2.shift);
    if ~f_done
        fprintf('%s -> frequency shift of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- FID data cut-off ---
if flag.mrsiFidCut
    if mrsi.fidCut<mrsi.nspecC
        mrsi.spec1.fid = mrsi.spec1.fid(1,1:mrsi.fidCut);
        mrsi.spec2.fid = mrsi.spec2.fid(1,1:mrsi.fidCut);
        fprintf('FID cut-off: %i -> %i\n',mrsi.nspecC,mrsi.fidCut);
        mrsi.nspecC    = mrsi.fidCut;
    else
        fprintf('%s ->\n cut value (%i) >= FID length (%i). Nothing to cut.\n\n',...
                FCTNAME,mrsi.fidCut,mrsi.nspecC)
    end
end

%--- time-domaine zero-filling ---
if flag.mrsiFidZf
    if mrsi.fidZf>mrsi.nspecC
        fid1Zf = complex(zeros(1,mrsi.fidZf));
        fid2Zf = complex(zeros(1,mrsi.fidZf));
        fid1Zf(1,1:mrsi.nspecC) = mrsi.spec1.fid;
        fid2Zf(1,1:mrsi.nspecC) = mrsi.spec2.fid;
        mrsi.spec1.fid = fid1Zf;
        mrsi.spec2.fid = fid2Zf;
        fprintf('FID ZF: %i -> %i\n',mrsi.nspecC,mrsi.fidZf);
        mrsi.nspecC    = mrsi.fidZf;
        clear fid1Zf fid2Zf
    else
        fprintf('%s ->\n ZF length (%i) <= FID length (%i). Nothing to fill.\n\n',...
                FCTNAME,mrsi.fidZf,mrsi.nspecC)
    end
end

%--- FID difference calculation ---
mrsi.diff.fid = mrsi.spec1.fid - mrsi.spec2.fid;

%--- spectral analysis ---
[mrsi.spec1.specOrig, f_done] = SP2_MRSI_SpectralFft(mrsi.spec1.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end
[mrsi.spec2.specOrig, f_done] = SP2_MRSI_SpectralFft(mrsi.spec2.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- PHC0 & PHC1 phase correction ---
[mrsi.spec1.spec, f_done] = SP2_MRSI_PhaseCorr(mrsi.spec1.specOrig,...
                                               flag.mrsiSpec1Phc0*mrsi.spec1.phc0,...
                                               flag.mrsiSpec1Phc1*mrsi.spec1.phc1);
if ~f_done
    fprintf('%s ->\nphasing of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end
[mrsi.spec2.spec, f_done] = SP2_MRSI_PhaseCorr(mrsi.spec2.specOrig,...
                                               flag.mrsiSpec2Phc0*mrsi.spec2.phc0,...
                                               flag.mrsiSpec2Phc1*mrsi.spec2.phc1);
if ~f_done
    fprintf('%s ->\nphasing of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- amplitude scaling ---
if flag.mrsiSpec1Scale
    mrsi.spec1.spec = mrsi.spec1.scale * mrsi.spec1.spec;
end
if flag.mrsiSpec2Scale
    mrsi.spec2.spec = mrsi.spec2.scale * mrsi.spec2.spec;
end

%--- difference spectrum calculation ---
mrsi.diff.spec = mrsi.spec1.spec - mrsi.spec2.spec;

%--- display selection ---
if flag.mrsiFormat==1        % real
    mrsi.spec1.specDispl = real(mrsi.spec1.spec);
    mrsi.spec2.specDispl = real(mrsi.spec2.spec);
    mrsi.diff.specDispl  = real(mrsi.diff.spec);
elseif flag.mrsiFormat==2    % imaginary
    mrsi.spec1.specDispl = imag(mrsi.spec1.spec);
    mrsi.spec2.specDispl = imag(mrsi.spec2.spec);
    mrsi.diff.specDispl  = imag(mrsi.diff.spec);
else                        % magnitude
    mrsi.spec1.specDispl = abs(mrsi.spec1.spec);
    mrsi.spec2.specDispl = abs(mrsi.spec2.spec);
    mrsi.diff.specDispl  = abs(mrsi.diff.spec);
end

%--- plot FID superposition ---
if flag.mrsiPlotFid
    SP2_MRSI_PlotFidSuperpos
end

%--- plot spectrum superposition ---
SP2_MRSI_PlotSpecSuperpos

%--- update success flag ---
f_done = 1;

%--- analysis done at least once: yes ---
flag.mrsiProcInit = 1;
