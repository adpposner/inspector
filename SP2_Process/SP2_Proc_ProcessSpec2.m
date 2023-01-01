%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_ProcessSpec2
%%
%%  Spectral processing of data set 2
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

    
FCTNAME = 'SP2_Proc_ProcessSpec2';

%--- init success flag ---
f_done = 0;

%--- spectral analysis ---
[proc.spec2.spec, f_done] = SP2_Proc_SpectralFft(proc.spec2.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 2 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- PHC0 & PHC1 phase correction ---
[proc.spec2.spec, f_done] = SP2_Proc_PhaseCorr(proc.spec2.spec,proc.spec2.nspecC,...
                                               flag.procSpec2Phc0*proc.spec2.phc0,...
                                               flag.procSpec2Phc1*proc.spec2.phc1);
if ~f_done
    fprintf('%s ->\nPhasing of spectrum 2 failed. Program aborted.\n\n',FCTNAME)
    return
end

% %--- amplitude scaling ---
% if flag.procSpec2Scale
%     proc.spec2.spec = proc.spec2.scale * proc.spec2.spec;
% end

%--- frequency stretch ---
if flag.procSpec2Stretch
    frequVecOrig = -proc.spec2.sw_h/2:proc.spec2.sw_h/(proc.spec2.nspecC-1):proc.spec2.sw_h/2;
    frequVecNew  = 1/(1+proc.spec2.stretch/proc.spec2.sf)*frequVecOrig;
    realSpec2 = spline(frequVecOrig,real(proc.spec2.spec),frequVecNew);
    imagSpec2 = spline(frequVecOrig,imag(proc.spec2.spec),frequVecNew);
    proc.spec2.spec = complex(realSpec2.',imagSpec2.');
end

%--- magnitude of real part ---
% instead of true magnitude that also includes the imaginary part 
if flag.procAnaAbsOfReal
    proc.spec2.spec = complex(abs(real(proc.spec2.spec)),imag(proc.spec2.spec));
end  

%--- update success flag ---
f_done = 1;
