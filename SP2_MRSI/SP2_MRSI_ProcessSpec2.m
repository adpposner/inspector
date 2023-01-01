%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcessSpec2
%%
%%  Spectral processing of data set 2
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

    
FCTNAME = 'SP2_MRSI_ProcessSpec2';

%--- init success flag ---
f_done = 0;

%--- spectral analysis ---
[mrsi.spec2.spec, f_done] = SP2_MRSI_SpectralFft(mrsi.spec2.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 2 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- PHC0 & PHC1 phase correction ---
[mrsi.spec2.spec, f_done] = SP2_MRSI_PhaseCorr(mrsi.spec2.spec,mrsi.spec2.nspecC,...
                                               flag.mrsiSpec2Phc0*mrsi.spec2.phc0,...
                                               flag.mrsiSpec2Phc1*mrsi.spec2.phc1);
if ~f_done
    fprintf('%s ->\nPhasing of spectrum 2 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- amplitude scaling ---
if flag.mrsiSpec2Scale
    mrsi.spec2.spec = mrsi.spec2.scale * mrsi.spec2.spec;
end

%--- update success flag ---
f_done = 1;
