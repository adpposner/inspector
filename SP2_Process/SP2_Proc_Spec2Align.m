%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_Spec1Align
%%
%%  Align spectrum 2 with spectrum 1.
%%  Optimization parameters:
%%  1) line broadening (LB)
%%  2) Zero order phase (PHC0)
%%  3) Amplitude scaling
%%  4) Frequency shift
%%  Note that the optimization is done on the complex signals.
%%
%%  09-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm proc flag align

FCTNAME = 'SP2_Proc_Spec2Align';


%--- check data existence and parameter consistency ---
if flag.procNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME);
    return
else                        % 2 spectra
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nSpectral data set 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec2,'sw')
        fprintf('%s ->\nSpectrum 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    %--- SW (and dwell time) ---
    if SP2_RoundToNthDigit(proc.spec1.sw,4)~=SP2_RoundToNthDigit(proc.spec2.sw,4)
        fprintf('%s -> SW mismatch detected (%.4fMHz ~= %.4fMHz)\n',FCTNAME,...
                proc.spec1.sw,proc.spec2.sw)
        return
    end
    %--- number of points ---
    if proc.spec1.nspecC~=proc.spec2.nspecC
        fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
                proc.spec1.nspecC,proc.spec2.nspecC)
    end
end

%--- enable parameter flags (this might be more flexible in the future) ---
flag.procSpec1LB    = 1;
flag.procSpec1Phc0  = 1;
flag.procSpec1Scale = 1;
flag.procSpec1Shift = 1;
set(fm.proc.spec1LbFlag,'Value',flag.procSpec1Lb==1);
set(fm.proc.spec1Phc0Flag,'Value',flag.procSpec1Phc0==1);
set(fm.proc.spec1ScaleFlag,'Value',flag.procSpec1Scale==1);
set(fm.proc.spec1ShiftFlag,'Value',flag.procSpec1Shift==1);

%--- get reference spectrum 2 as is ---
[align.minI,align.maxI,ppm2Zoom,refSpecZoom,f_done] = ...
    SP2_Proc_ExtractPpmRange(proc.ppmTargetMin,proc.ppmTargetMax,proc.ppmCalib,proc.spec2.sw,proc.spec2.spec);
if ~f_done
    fprintf('%s ->\nppm extraction of reference spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- extraction of spectral range ---
if flag.procFormat==1           % real part
    refSpecZoomFit = real(refSpecZoom);
elseif flag.procFormat==2       % imaginary part
    refSpecZoomFit = imag(refSpecZoom);
elseif flag.procFormat==3       % magnitude
    refSpecZoomFit = abs(refSpecZoom);
else                            % phase, here: real AND imaginary
    refSpecZoomFit = [real(refSpecZoom); imag(refSpecZoom)];
end

%--- align spectrum 1 with spectrum 2 ---
opt        = [];
lb         = [0 -360 0 -30];    % lower limit
coeffStart = [0 0 1 0];         % lb, phc0, scale, shift
ub         = [10 360 10 30];    % upper limit

%--- least-squares fit ---
[coeffFit,resnorm,resid,exitflag,output] = ...
    lsqcurvefit('SP2_Proc_Spec1AlignFitFct',coeffStart,[],refSpecZoomFit.^proc.alignAmpWeight,lb,ub,opt);

%--- parameter assignment ---
proc.spec1.lb    = coeffFit(1);
proc.spec1.phc0  = coeffFit(2);
proc.spec1.scale = coeffFit(3);
proc.spec1.shift = coeffFit(4);

%--- info printout ---
fprintf('Alignment result:\n');
fprintf('LB:\t\t%.2f Hz\n',proc.spec1.lb);
fprintf('PHC0:\t%.1f deg\n',proc.spec1.phc0);
fprintf('Scale:\t%.3f\n',proc.spec1.scale);
fprintf('Shift:\t%.3f Hz\n',proc.spec1.shift);

%--- display update ---
set(fm.proc.spec1LbVal,'String',sprintf('%.2f',proc.spec1.lb));
set(fm.proc.spec1Phc0Val,'String',sprintf('%.1f',proc.spec1.phc0));
set(fm.proc.spec1ScaleVal,'String',sprintf('%.3f',proc.spec1.scale));
set(fm.proc.spec1ShiftVal,'String',sprintf('%.3f',proc.spec1.shift));

%--- spectrum update / result visualization ---
if ~SP2_Proc_ProcAndPlotSpecSuperpos
    return
end
if ~SP2_Proc_PlotSpecDiff(1)
    return
end






