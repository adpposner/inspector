%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PpmAssignToPeak
%%
%%  Assign ppm value to manually selected peak.
%% 
%%  01-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

FCTNAME = 'SP2_MRSI_PpmAssignToPeak';



%--- data processing ---
%--- check data existence and parameter consistency ---
if flag.mrsiNumSpec==0      % single spectrum
    if ~isfield(mrsi,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(mrsi.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME);
        return
    end
else                        % 2 spectra
    if ~isfield(mrsi,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(mrsi.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(mrsi,'spec2')
        fprintf('%s ->\nSpectral data set 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(mrsi.spec2,'sw')
        fprintf('%s ->\nSpectrum 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    %--- SW (and dwell time) ---
    if SP2_RoundToNthDigit(mrsi.spec1.sw,5)~=SP2_RoundToNthDigit(mrsi.spec2.sw,5)
        fprintf('%s -> SW mismatch detected (%.1fMHz ~= %.1fMHz)\n',FCTNAME,...
                mrsi.spec1.sw,mrsi.spec2.sw)
        return
    end
    %--- number of points ---
    if mrsi.spec1.nspecC~=mrsi.spec2.nspecC
        fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
                mrsi.spec1.nspecC,mrsi.spec2.nspecC)
    end
end

%--- ppm limit handling ---
if flag.mrsiPpmShow     % direct
    ppmMin = mrsi.ppmShowMin;
    ppmMax = mrsi.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -mrsi.spec1.sw/2 + mrsi.ppmCalib;
    ppmMax = mrsi.spec1.sw/2  + mrsi.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,real(mrsi.spec1.spec));
elseif flag.mrsiFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,imag(mrsi.spec1.spec));
else                            % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,abs(mrsi.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: spectrum 2 ---
if flag.mrsiNumSpec==1
    if flag.mrsiFormat==1           % real part
        [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                   mrsi.spec2.sw,real(mrsi.spec2.spec));
    elseif flag.mrsiFormat==2       % imaginary part
        [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                   mrsi.spec2.sw,imag(mrsi.spec2.spec));
    else                            % magnitude
        [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                   mrsi.spec2.sw,abs(mrsi.spec2.spec));
    end                                             
    if ~f_done
        fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- figure creation ---
% remove existing figure if new figure is forced
if isfield(mrsi,'fhPpmAssign') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhPpmAssign)
        delete(mrsi.fhPpmAssign)
    end
    mrsi = rmfield(mrsi,'fhPpmAssign');
end
% create figure if necessary
if ~isfield(mrsi,'fhPpmAssign') || ~ishandle(mrsi.fhPpmAssign)
    mrsi.fhPpmAssign = figure('IntegerHandle','off');
    set(mrsi.fhPpmAssign,'NumberTitle','off','Name',sprintf(' Spectrum 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhPpmAssign)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhPpmAssign)
            return
        end
    end
end
clf(mrsi.fhPpmAssign)

%--- data visualization ---
hold on
plot(ppmZoom,spec1Zoom)
if flag.mrsiNumSpec==1
    plot(ppmZoom,spec2Zoom,'r')
end
hold off
set(gca,'XDir','reverse')
if flag.mrsiAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = mrsi.amplMin;
    plotLim(4) = mrsi.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) minX(1) maxX(1)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    if flag.mrsiNumSpec==1      % two spectra
        [plotLim(1) plotLim(2) minX(2) maxX(2)] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
    end
    plotLim(3) = min(minX);
    plotLim(4) = max(maxX);
end
if flag.mrsiPpmShowPos
    hold on
    plot([mrsi.ppmShowPos mrsi.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- peak retrieval ---
[ppmPos,y] = ginput(1);

%--- ppm assignment ---
mrsi.ppmCalib = mrsi.ppmCalib + mrsi.ppmAssign - ppmPos;

%--- remove figure ---
delete(mrsi.fhPpmAssign)
mrsi = rmfield(mrsi,'fhPpmAssign');

%--- ppm position update ---
if flag.mrsiPpmShowPos
    SP2_MRSI_PpmShowPosValUpdate
end

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate




