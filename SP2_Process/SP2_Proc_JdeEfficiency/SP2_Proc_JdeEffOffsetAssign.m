%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_JdeEffOffsetAssign
%%
%%  Manual assignment of offset for JDE efficiency analysis.
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_JdeEffOffsetAssign';


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

%--- ppm limit handling ---
if flag.procPpmShow     % direct
    ppmMin = proc.ppmShowMin;
    ppmMax = proc.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -proc.spec1.sw/2 + proc.ppmCalib;
    ppmMax = proc.spec1.sw/2  + proc.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec1.sw,real(proc.spec1.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec1.sw,imag(proc.spec1.spec));
else                            % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec1.sw,abs(proc.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: spectrum 2 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec2.sw,real(proc.spec2.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec2.sw,imag(proc.spec2.spec));
else                            % magnitude
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec2.sw,abs(proc.spec2.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(proc,'fhJdeOffAssign') && ~flag.procKeepFig
    if ishandle(proc.fhJdeOffAssign)
        delete(proc.fhJdeOffAssign)
    end
    proc = rmfield(proc,'fhJdeOffAssign');
end
% create figure if necessary
if ~isfield(proc,'fhJdeOffAssign') || ~ishandle(proc.fhJdeOffAssign)
    proc.fhJdeOffAssign = figure('IntegerHandle','off');
    set(proc.fhJdeOffAssign,'NumberTitle','off','Name',sprintf(' Spectrum Superposition for Offset Assignment'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',proc.fhJdeOffAssign)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhJdeOffAssign)
            return
        end
    end
end
clf(proc.fhJdeOffAssign)

%--- data visualization ---
hold on
plot(ppmZoom,spec1Zoom)
plot(ppmZoom,spec2Zoom,'r')
hold off
set(gca,'XDir','reverse')
if flag.procAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = proc.amplMin;
    plotLim(4) = proc.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) minX(1) maxX(1)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    [plotLim(1) plotLim(2) minX(2) maxX(2)] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
    plotLim(3) = min(minX);
    plotLim(4) = max(maxX);
end
if flag.procPpmShowPos
    hold on
    plot([proc.ppmShowPos proc.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- peak retrieval ---
[x,proc.jdeEffOffset] = ginput(1);

%--- info printout ---
fprintf('Amplitude offset: %.1f\n',proc.jdeEffOffset);

%--- remove figure ---
delete(proc.fhJdeOffAssign)
proc = rmfield(proc,'fhJdeOffAssign');

%--- window update ---
SP2_Proc_JdeEfficiencyWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate




