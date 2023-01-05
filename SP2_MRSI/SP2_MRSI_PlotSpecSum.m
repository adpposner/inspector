%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotSpecSum( f_new )
%%
%%  Plot spectrum summation.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotSpecSum';


%--- check data existence and parameter consistency ---
if flag.mrsiNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME);
    return
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
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,real(mrsi.specSum));
elseif flag.mrsiFormat==2       % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,imag(mrsi.specSum));
elseif flag.mrsiFormat==3       % magnitude
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,abs(mrsi.specSum));
else                            % phase
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,angle(mrsi.specSum));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhSpecSum') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhSpecSum)
        delete(mrsi.fhSpecSum)
    end
    mrsi = rmfield(mrsi,'fhSpecSum');
end
% create figure if necessary
if ~isfield(mrsi,'fhSpecSum') || ~ishandle(mrsi.fhSpecSum)
    mrsi.fhSpecSum = figure('IntegerHandle','off');
    set(mrsi.fhSpecSum,'NumberTitle','off','Name',sprintf(' Summation Spectrum'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhSpecSum)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhSpecSum)
            return
        end
    end
end
clf(mrsi.fhSpecSum)

%--- data visualization ---
plot(ppmZoom,specZoom)
set(gca,'XDir','reverse')
if flag.mrsiAmpl         % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    plotLim(3) = mrsi.amplMin;
    plotLim(4) = mrsi.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
end
if flag.mrsiPpmShowPos
    hold on
    plot([mrsi.ppmShowPos mrsi.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    if flag.mrsiPpmShowPosMirr
        plot([mrsi.ppmShowPosMirr mrsi.ppmShowPosMirr],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    end
    hold off
end
axis(plotLim)
if flag.mrsiFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')

%--- spectrum analysis ---
if flag.mrsiAnaSNR || flag.mrsiAnaFWHM || flag.mrsiAnaIntegr
    fprintf('ANALYSIS OF SPECTRAL SUM\n');
    if ~SP2_MRSI_Analysis(mrsi.specSum,mrsi.spec1,plotLim)
        return
    end
end

%--- export handling ---
mrsi.expt.fid    = ifft(ifftshift(mrsi.specSum,1),[],1);
mrsi.expt.sf     = mrsi.spec1.sf;
mrsi.expt.sw_h   = mrsi.spec1.sw_h;
mrsi.expt.nspecC = mrsi.spec1.nspecC;


