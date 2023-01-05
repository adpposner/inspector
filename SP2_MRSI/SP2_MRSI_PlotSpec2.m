%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotSpec2( f_new )
%%
%%  Plot processed spectrum of data set 2.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotSpec2';


%--- check data existence ---
if ~isfield(mrsi.spec2,'spec')
    fprintf('%s ->\nSpectrum 2 does not exist. Load/analyze first.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.mrsiPpmShow     % direct
    ppmMin = mrsi.ppmShowMin;
    ppmMax = mrsi.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -mrsi.spec2.sw/2 + mrsi.ppmCalib;
    ppmMax = mrsi.spec2.sw/2  + mrsi.ppmCalib;
end

%--- data extraction: spectrum 2 ---
if flag.mrsiFormat==1           % real part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,real(mrsi.spec2.spec));
elseif flag.mrsiFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,imag(mrsi.spec2.spec));
elseif flag.mrsiFormat==3       % magnitude
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,abs(mrsi.spec2.spec));
else                            % phase
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec2.sw,angle(mrsi.spec2.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhSpec2') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhSpec2)
        delete(mrsi.fhSpec2)
    end
    mrsi = rmfield(mrsi,'fhSpec2');
end
% create figure if necessary
if ~isfield(mrsi,'fhSpec2') || ~ishandle(mrsi.fhSpec2)
    mrsi.fhSpec2 = figure('IntegerHandle','off');
    set(mrsi.fhSpec2,'NumberTitle','off','Name',sprintf(' Spectrum 2'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhSpec2)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhSpec2)
            return
        end
    end
end
clf(mrsi.fhSpec2)

%--- data visualization ---
plot(ppmZoom,spec2Zoom)
set(gca,'XDir','reverse')
if flag.mrsiAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
    plotLim(3) = mrsi.amplMin;
    plotLim(4) = mrsi.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
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
    fprintf('ANALYSIS OF SPECTRUM 2\n');
    if ~SP2_MRSI_Analysis(mrsi.spec2.spec,mrsi.spec2,plotLim,[flag.mrsiSpec2Lb flag.mrsiSpec2Gb])
        return
    end
end

%--- export handling ---
mrsi.expt.fid    = ifft(ifftshift(mrsi.spec2.spec,1),[],1);
mrsi.expt.sf     = mrsi.spec2.sf;
mrsi.expt.sw_h   = mrsi.spec2.sw_h;
mrsi.expt.nspecC = mrsi.spec2.nspecC;

