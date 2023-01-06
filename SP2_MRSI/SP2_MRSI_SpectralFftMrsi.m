%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_SpectralFftMrsi(datStruct)
%%
%%  Spectral FFT of MRSI data.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_SpectralFftMrsi';


%--- init success flag ---
f_succ = 0;

%--- spectral FFT --------------------
datStruct.specimg = fftshift(fft(datStruct.fidimg,[],1),1);
% datStruct.specimg = complex(zeros(datStruct.nspecC,datStruct.nEncR,datStruct.nEncP));
% for rCnt = 1:datStruct.nEncR
%     for pCnt = 1:datStruct.nEncP
%         datStruct.specimg(:,rCnt,pCnt) = fftshift(fft(datStruct.fidimg(:,rCnt,pCnt)));
%     end
% end

%--- info printout ---
fprintf('Spectral FFT applied (%s)\n',datStruct.name);

%--- update success flag ---
f_succ = 1;

end
