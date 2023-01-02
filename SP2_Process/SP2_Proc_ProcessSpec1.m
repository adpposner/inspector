%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Proc_ProcessSpec1
%%
%%  Spectral processing of data set 1
%%
%%  11-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

    
FCTNAME = 'SP2_Proc_ProcessSpec1';

%--- init success flag ---
f_done = 0;

%--- spectral analysis ---
[proc.spec1.spec, f_done] = SP2_Proc_SpectralFft(proc.spec1.fid);
if ~f_done
    fprintf('%s ->\nSpectral analysis of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- PHC0 & PHC1 phase correction ---
[proc.spec1.spec, f_done] = SP2_Proc_PhaseCorr(proc.spec1.spec,proc.spec1.nspecC,...
                                               flag.procSpec1Phc0*proc.spec1.phc0,...
                                               flag.procSpec1Phc1*proc.spec1.phc1);
if ~f_done
    fprintf('%s ->\nPhasing of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

% %--- amplitude scaling ---
% if flag.procSpec1Scale
%     proc.spec1.spec = proc.spec1.scale * proc.spec1.spec;
% end

%--- frequency stretch ---
if flag.procSpec1Stretch
    frequVecOrig = -proc.spec1.sw_h/2:proc.spec1.sw_h/(proc.spec1.nspecC-1):proc.spec1.sw_h/2;
    frequVecNew  = 1/(1+proc.spec1.stretch/proc.spec1.sf)*frequVecOrig;
    realSpec1 = spline(frequVecOrig,real(proc.spec1.spec),frequVecNew);
    imagSpec1 = spline(frequVecOrig,imag(proc.spec1.spec),frequVecNew);
    proc.spec1.spec = complex(realSpec1.',imagSpec1.');
end

%--- magnitude of real part ---
% instead of true magnitude that also includes the imaginary part 
if flag.procAnaAbsOfReal
    proc.spec1.spec = complex(abs(real(proc.spec1.spec)),imag(proc.spec1.spec));
end    

%--- update success flag ---
f_done = 1;

