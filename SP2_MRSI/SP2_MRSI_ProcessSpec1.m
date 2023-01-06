%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MRSI_ProcessSpec1
%%
%%  Spectral processing of data set 1
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

    
FCTNAME = 'SP2_MRSI_ProcessSpec1';

%--- init success flag ---
f_done = 0;

%--- spectral analysis ---
[mrsi.spec1.spec, f_done] = SP2_MRSI_SpectralFft(mrsi.spec1.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- PHC0 & PHC1 phase correction ---
[mrsi.spec1.spec, f_done] = SP2_MRSI_PhaseCorr(mrsi.spec1.spec,mrsi.spec1.nspecC,...
                                               flag.mrsiSpec1Phc0*mrsi.spec1.phc0,...
                                               flag.mrsiSpec1Phc1*mrsi.spec1.phc1);
if ~f_done
    fprintf('%s ->\nPhasing of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- amplitude scaling ---
if flag.mrsiSpec1Scale
    mrsi.spec1.spec = mrsi.spec1.scale * mrsi.spec1.spec;
end

%--- update success flag ---
f_done = 1;


end
