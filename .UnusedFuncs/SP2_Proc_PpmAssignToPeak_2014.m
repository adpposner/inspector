%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmAssignToPeak
%%
%%  Assign ppm value to manually selected peak.
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PpmAssignToPeak';



%--- data processing ---
%--- check data existence and parameter consistency ---
if flag.procNumSpec==0      % single spectrum
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME);
        return
    end
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
if flag.procNumSpec==1
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
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(proc,'fhPpmAssign') && ~flag.procKeepFig
    if ishandle(proc.fhPpmAssign)
        delete(proc.fhPpmAssign)
    end
    proc = rmfield(proc,'fhPpmAssign');
end
% create figure if necessary
if ~isfield(proc,'fhPpmAssign') || ~ishandle(proc.fhPpmAssign)
    proc.fhPpmAssign = figure('IntegerHandle','off');
    set(proc.fhPpmAssign,'NumberTitle','off','Name',sprintf(' Spectrum 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',proc.fhPpmAssign)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhPpmAssign)
            return
        end
    end
end
clf(proc.fhPpmAssign)

%--- data visualization ---
hold on
plot(ppmZoom,spec1Zoom)
if flag.procNumSpec==1
    plot(ppmZoom,spec2Zoom,'r')
end
hold off
set(gca,'XDir','reverse')
if flag.procAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = proc.amplMin;
    plotLim(4) = proc.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) minX(1) maxX(1)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    if flag.procNumSpec==1      % two spectra
        [plotLim(1) plotLim(2) minX(2) maxX(2)] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
    end
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
[ppmPos,y] = ginput(1);

%--- ppm assignment ---
proc.ppmCalib = proc.ppmCalib + proc.ppmAssign - ppmPos;

%--- remove figure ---
delete(proc.fhPpmAssign)
proc = rmfield(proc,'fhPpmAssign');

%--- ppm position update ---
if flag.procPpmShowPos
    SP2_Proc_PpmShowPosValUpdate
end

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate





end
