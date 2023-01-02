%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function outdata = SP2_MRSI_SvdPhaseAndAmpFitFct(coeff,data)
%%
%%  Amplitude and phase fitting function used within Hankel SVD-based 
%%  removal of spectral peaks. Note that the damping factors can also have
%%  negative values.
%%  Literature: PijnappelWWF92a, DeBeerR92b
%%
%%  08-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi

%--- init fitted FID ---
if mrsi.svd.specNumber==1           % spectrum 1
    mrsi.svd.fid = complex(zeros(1,mrsi.spec1.nspecC));
elseif mrsi.svd.specNumber==2       % spectrum 2
    mrsi.svd.fid = complex(zeros(1,mrsi.spec2.nspecC));
else                                % export
    mrsi.svd.fid = complex(zeros(1,mrsi.expt.nspecC));
end

%--- peak creation and summation ---
for peakCnt = 1:mrsi.svd.nValid
   mrsi.svd.fid = mrsi.svd.fid + ...
                  coeff(peakCnt) * exp(-1i*coeff(mrsi.svd.nValid+peakCnt)*pi/180) * ...
                  exp(-2*pi*1i*mrsi.svd.frequ(peakCnt)*mrsi.svd.tVec) .* ...
                  exp(-mrsi.svd.tVec/mrsi.svd.damp(peakCnt));
end

%--- difference measure: original spectrum vs. fit ---
if mrsi.svd.specNumber==1           % spectrum 1
    diffSpec = mrsi.spec1.spec - fftshift(fft(mrsi.svd.fid'));
elseif mrsi.svd.specNumber==2       % spectrum 2
    diffSpec = mrsi.spec2.spec - fftshift(fft(mrsi.svd.fid'));
else                                % export
    diffSpec = mrsi.expt.spec - fftshift(fft(mrsi.svd.fid'));
end
outdata  = abs(diffSpec(mrsi.svd.indVec))';
