%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function outdata = SP2_Proc_SvdPhaseAndAmpFitFct(coeff,data)
%%
%%  Amplitude and phase fitting function used within Hankel SVD-based 
%%  removal of spectral peaks. Note that the damping factors can also have
%%  negative values.
%%  Literature: PijnappelWWF92a, DeBeerR92b
%%
%%  08-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc

%--- init fitted FID ---
if proc.svd.specNumber==1           % spectrum 1
    proc.svd.fid = complex(zeros(1,proc.spec1.nspecC));
elseif proc.svd.specNumber==2       % spectrum 2
    proc.svd.fid = complex(zeros(1,proc.spec2.nspecC));
else                                % export
    proc.svd.fid = complex(zeros(1,proc.expt.nspecC));
end

%--- peak creation and summation ---
for peakCnt = 1:proc.svd.nValid
   proc.svd.fid = proc.svd.fid + ...
                  coeff(peakCnt) * exp(-1i*coeff(proc.svd.nValid+peakCnt)*pi/180) * ...
                  exp(-2*pi*1i*proc.svd.frequ(peakCnt)*proc.svd.tVec) .* ...
                  exp(-proc.svd.tVec/proc.svd.damp(peakCnt));
end

%--- difference measure: original spectrum vs. fit ---
if proc.svd.specNumber==1           % spectrum 1
    diffSpec = proc.spec1.spec - fftshift(fft(proc.svd.fid'));
elseif proc.svd.specNumber==2       % spectrum 2
    diffSpec = proc.spec2.spec - fftshift(fft(proc.svd.fid'));
else                                % export
    diffSpec = proc.expt.spec - fftshift(fft(proc.svd.fid'));
end
outdata  = abs(diffSpec(proc.svd.indVec))';
