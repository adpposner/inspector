%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datSpec, f_done] = SP2_MRSI_SpectralFft(datFid)
%%
%%  Spectral FFT of individual (selected) FID.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
FCTNAME = 'SP2_MRSI_SpectralFft';

%--- init success flag ---
f_done = 0;

%--- consistency check ---
SP2_Check4ColVec(datFid)

%--- spectral FFT --------------------
datSpec = fftshift(fft(datFid,[],1),1);

%--- update success flag ---
f_done = 1;
