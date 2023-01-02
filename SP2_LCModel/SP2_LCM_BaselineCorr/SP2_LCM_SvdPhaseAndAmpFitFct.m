%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function outdata = SP2_LCM_SvdPhaseAndAmpFitFct(coeff,data)
%%
%%  Amplitude and phase fitting function used within Hankel SVD-based 
%%  removal of spectral peaks. Note that the damping factors can also have
%%  negative values.
%%  Literature: PijnappelWWF92a, DeBeerR92b
%%
%%  08-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm

%--- init fitted FID ---
if lcm.svd.specNumber==1           % spectrum 1
    lcm.svd.fid = complex(zeros(1,lcm.spec1.nspecC));
elseif lcm.svd.specNumber==2       % spectrum 2
    lcm.svd.fid = complex(zeros(1,lcm.spec2.nspecC));
else                                % export
    lcm.svd.fid = complex(zeros(1,lcm.expt.nspecC));
end

%--- peak creation and summation ---
for peakCnt = 1:lcm.svd.nValid
   lcm.svd.fid = lcm.svd.fid + ...
                  coeff(peakCnt) * exp(-1i*coeff(lcm.svd.nValid+peakCnt)*pi/180) * ...
                  exp(-2*pi*1i*lcm.svd.frequ(peakCnt)*lcm.svd.tVec) .* ...
                  exp(-lcm.svd.tVec/lcm.svd.damp(peakCnt));
end

%--- difference measure: original spectrum vs. fit ---
if lcm.svd.specNumber==1           % spectrum 1
    diffSpec = lcm.spec1.spec - fftshift(fft(lcm.svd.fid'));
elseif lcm.svd.specNumber==2       % spectrum 2
    diffSpec = lcm.spec2.spec - fftshift(fft(lcm.svd.fid'));
else                                % export
    diffSpec = lcm.expt.spec - fftshift(fft(lcm.svd.fid'));
end
outdata  = abs(diffSpec(lcm.svd.indVec))';
