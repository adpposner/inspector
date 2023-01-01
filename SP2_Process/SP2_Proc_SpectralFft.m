%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datSpec, f_done] = SP2_Proc_SpectralFft(datFid)
%%
%%  Spectral FFT of MRS/CSI data.
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
FCTNAME = 'SP2_Proc_SpectralFft';

%--- init success flag ---
f_done  = 0;
datSpec = 0*datFid;             % init (in case of abort)

%--- consistency check ---
if ~SP2_Check4ColVec(datFid)
    return
end

%--- spectral FFT --------------------
datSpec = fftshift(fft(datFid,[],1),1);

%--- update success flag ---
f_done = 1;
