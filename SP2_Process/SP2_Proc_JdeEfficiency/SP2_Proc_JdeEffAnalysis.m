%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_JdeEffAnalysis
%%
%%  JDE efficiency analysis.
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_JdeEffAnalysis';


%--- check data existence and parameter consistency ---
if flag.procNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME)
    return
else                        % 2 spectra
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME)
        return
    end
    if ~isfield(proc.spec1,'spec') || ~isfield(proc.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME)
        return
    end
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nSpectral data set 2 not found. Program aborted.\n',FCTNAME)
        return
    end
    if ~isfield(proc.spec2,'spec') || ~isfield(proc.spec2,'sw')
        fprintf('%s ->\nSpectrum 2 not found. Program aborted.\n',FCTNAME)
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

%--- consistency check ---
if proc.jdeEffPpmRg(1)==proc.jdeEffPpmRg(2)
    fprintf('%s ->\nIdentical ppm values are not supported. Program aborted.\n',FCTNAME)
    return
end

%--- data extraction: spectrum 1 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(proc.jdeEffPpmRg(1),proc.jdeEffPpmRg(2),...
                                                proc.ppmCalib,proc.spec1.sw,real(proc.spec1.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(proc.jdeEffPpmRg(1),proc.jdeEffPpmRg(2),...
                                                proc.ppmCalib,proc.spec1.sw,imag(proc.spec1.spec));
else                            % magnitude
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(proc.jdeEffPpmRg(1),proc.jdeEffPpmRg(2),...
                                                proc.ppmCalib,proc.spec1.sw,abs(proc.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- data extraction: spectrum 2 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(proc.jdeEffPpmRg(1),proc.jdeEffPpmRg(2),...
                                                proc.ppmCalib,proc.spec2.sw,real(proc.spec2.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(proc.jdeEffPpmRg(1),proc.jdeEffPpmRg(2),...
                                                proc.ppmCalib,proc.spec2.sw,imag(proc.spec2.spec));
else                            % magnitude
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(proc.jdeEffPpmRg(1),proc.jdeEffPpmRg(2),...
                                                proc.ppmCalib,proc.spec2.sw,abs(proc.spec2.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- data display extraction: spectrum 1 ---
procJdeEffDisplay(1) = proc.jdeEffPpmRg(1)-(proc.jdeEffPpmRg(2)-proc.jdeEffPpmRg(1))/5;
procJdeEffDisplay(2) = proc.jdeEffPpmRg(2)+(proc.jdeEffPpmRg(2)-proc.jdeEffPpmRg(1))/5;
if flag.procFormat==1           % real part
    [minI,maxI,ppm1Display,spec1Display,f_done] = SP2_Proc_ExtractPpmRange(procJdeEffDisplay(1),procJdeEffDisplay(2),...
                                                    proc.ppmCalib,proc.spec1.sw,real(proc.spec1.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppm1Display,spec1Display,f_done] = SP2_Proc_ExtractPpmRange(procJdeEffDisplay(1),procJdeEffDisplay(2),...
                                                    proc.ppmCalib,proc.spec1.sw,imag(proc.spec1.spec));
else                            % magnitude
    [minI,maxI,ppm1Display,spec1Display,f_done] = SP2_Proc_ExtractPpmRange(procJdeEffDisplay(1),procJdeEffDisplay(2),...
                                                    proc.ppmCalib,proc.spec1.sw,abs(proc.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- data extraction: spectrum 2 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppm2Display,spec2Display,f_done] = SP2_Proc_ExtractPpmRange(procJdeEffDisplay(1),procJdeEffDisplay(2),...
                                                    proc.ppmCalib,proc.spec2.sw,real(proc.spec2.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppm2Display,spec2Display,f_done] = SP2_Proc_ExtractPpmRange(procJdeEffDisplay(1),procJdeEffDisplay(2),...
                                                    proc.ppmCalib,proc.spec2.sw,imag(proc.spec2.spec));
else                            % magnitude
    [minI,maxI,ppm2Display,spec2Display,f_done] = SP2_Proc_ExtractPpmRange(procJdeEffDisplay(1),procJdeEffDisplay(2),...
                                                    proc.ppmCalib,proc.spec2.sw,abs(proc.spec2.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(proc,'fhJdeEff') && ~flag.procKeepFig
    if ishandle(proc.fhJdeEff)
        delete(proc.fhJdeEff)
    end
    proc = rmfield(proc,'fhJdeEff');
end
% create figure if necessary
if ~isfield(proc,'fhJdeEff') || ~ishandle(proc.fhJdeEff)
    proc.fhJdeEff = figure('IntegerHandle','off');
    set(proc.fhJdeEff,'NumberTitle','off','Name',sprintf(' JDE Efficiency Analysis'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',proc.fhJdeEff)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhJdeEff)
            return
        end
    end
end
clf(proc.fhJdeEff)

%--- JDE efficiency analysis ---
jdeEff        = 0.5;       % maximum editing efficiency for GABA
spec1ZoomCorr = spec1Zoom - proc.jdeEffOffset;
spec2ZoomCorr = spec2Zoom - proc.jdeEffOffset;
integSpec1    = sum(spec1ZoomCorr);
integSpec2    = sum(spec2ZoomCorr);
integSum      = sum(spec1ZoomCorr + spec2ZoomCorr);
integDiff     = sum(spec1ZoomCorr - spec2ZoomCorr);
spec1Norm     = 4*integSpec1/integSpec1;
spec2Norm     = 4*integSpec2/integSpec1;
sumNorm       = 4*integSum/integSpec1;
diffNorm      = 4*integDiff/integSpec1;
jdeEffRel     = 1-(spec2Norm*jdeEff);

% rationale:
% considered: GABA H2 triplet at 2.3ppm
% maximum editing efficiency: 50%
% non-edited:       +1 +2 +1        -> sum=4
% perfectly edited: -1 +2 -1        -> sum=0
% rel. 50% edited:  -0.5 +2 -0.5    -> sum=1
% rel. 0% edited:   0 +2 0          -> sum=2

fprintf('JDE efficiency analysis:\n')
fprintf('integral spec1:   %.2f (set)\n',spec1Norm)
fprintf('integral spec2:   %.2f\n',spec2Norm)
fprintf('integral spec1+2: %.2f\n',sumNorm)
fprintf('integral spec1-2: %.2f\n',diffNorm)
fprintf('Absolute/relative JDE efficiency: %.1f%%/%.1f%%\n\n',...
        100*jdeEff*jdeEffRel,100*jdeEffRel)

%--- data visualization ---
hold on
plot(ppm1Display,spec1Display)
plot(ppm2Display,spec2Display,'r')
set(gca,'XDir','reverse')
if flag.procAmpl         % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppm1Display,spec1Display);
    minY = proc.amplMin;
    maxY = proc.amplMax;
else                    % automatic
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppm1Display,spec1Display);
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppm2Display,spec2Display);
    minX = min(minX1,minX2);
    maxX = max(maxX1,maxX2);
    minY = min(minY1,minY2);
    maxY = max(maxY1,maxY2);
end
if flag.procPpmShowPos
    plot([proc.ppmShowPos proc.ppmShowPos],[minY maxY],'Color',[0 0 0])
end
plot([minX maxX],[proc.jdeEffOffset proc.jdeEffOffset],'Color',[0 0 0])
plot([proc.jdeEffPpmRg(1) proc.jdeEffPpmRg(1)],[minY maxY],'Color',[0 0 0])
plot([proc.jdeEffPpmRg(2) proc.jdeEffPpmRg(2)],[minY maxY],'Color',[0 0 0])
hold off
axis([minX maxX minY maxY])
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
title(sprintf('JDE Efficiency: abs. %.1f%% / rel. %.1f%%',...
      100*jdeEff*jdeEffRel,100*jdeEffRel))
lh = legend('Spec 1','Spec 2');
set(lh,'Location','Northwest')
