%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotSpecSuperpos( f_new )
%%
%%  Plot spectrum superposition of data sets 1 and 2.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotSpecSuperpos';


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
    ppmMin1 = mrsi.ppmShowMin;
    ppmMax1 = mrsi.ppmShowMax;
    ppmMin2 = mrsi.ppmShowMin;
    ppmMax2 = mrsi.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin1 = -mrsi.spec1.sw/2 + mrsi.ppmCalib;
    ppmMax1 = mrsi.spec1.sw/2  + mrsi.ppmCalib;
    ppmMin2 = -mrsi.spec2.sw/2 + mrsi.ppmCalib;
    ppmMax2 = mrsi.spec2.sw/2  + mrsi.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin1,ppmMax1,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,real(mrsi.spec1.spec));
elseif flag.mrsiFormat==2       % imaginary part
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin1,ppmMax1,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,imag(mrsi.spec1.spec));
elseif flag.mrsiFormat==3       % magnitude
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin1,ppmMax1,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,abs(mrsi.spec1.spec));
else                            % phase
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin1,ppmMax1,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,angle(mrsi.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: spectrum 2 ---
if flag.mrsiFormat==1           % real part
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin2,ppmMax2,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,real(mrsi.spec2.spec));
elseif flag.mrsiFormat==2       % imaginary part
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin2,ppmMax2,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,imag(mrsi.spec2.spec));
elseif flag.mrsiFormat==3       % magnitude
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin2,ppmMax2,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,abs(mrsi.spec2.spec));
else                            % phase
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin2,ppmMax2,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,angle(mrsi.spec2.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhSpecSuper') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhSpecSuper)
        delete(mrsi.fhSpecSuper)
    end
    mrsi = rmfield(mrsi,'fhSpecSuper');
end
% create figure if necessary
if ~isfield(mrsi,'fhSpecSuper') || ~ishandle(mrsi.fhSpecSuper)
    mrsi.fhSpecSuper = figure('IntegerHandle','off');
    set(mrsi.fhSpecSuper,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhSpecSuper)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhSpecSuper)
            return
        end
    end
end
clf(mrsi.fhSpecSuper)

%--- data visualization ---
plot(ppm1Zoom,spec1Zoom)
% plot(ppm1Zoom,spec1Zoom,'LineWidth',2)
hold on 
    plot(ppm2Zoom,spec2Zoom,'r')
%     plot(ppm2Zoom,spec2Zoom,'LineWidth',2,'Color',[1 0 0])
hold off
set(gca,'XDir','reverse')
if flag.mrsiAmpl         % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppm1Zoom,spec1Zoom);
    minY = mrsi.amplMin;
    maxY = mrsi.amplMax;
else                    % automatic
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppm1Zoom,spec1Zoom);
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppm2Zoom,spec2Zoom);
    minX = min(minX1,minX2);
    maxX = max(maxX1,maxX2);
    minY = min(minY1,minY2);
    maxY = max(maxY1,maxY2);
end
if flag.mrsiPpmShowPos
    hold on
    plot([mrsi.ppmShowPos mrsi.ppmShowPos],[minY maxY],'Color',[0 0 0])
    if flag.mrsiPpmShowPosMirr
        plot([mrsi.ppmShowPosMirr mrsi.ppmShowPosMirr],[minY maxY],'Color',[0 0 0])
    end
    hold off
end
axis([minX maxX minY maxY])
if flag.mrsiFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')
lh = legend('Spec 1','Spec 2');
set(lh,'Location','Northwest')

end
