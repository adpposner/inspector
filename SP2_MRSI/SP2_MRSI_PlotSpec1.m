%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotSpec1( f_new )
%%
%%  Plot processed spectrum of data set 1.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotSpec1';


%--- check data existence ---
if ~isfield(mrsi.spec1,'spec')
    fprintf('%s ->\nSpectrum 1 does not exist. Load/analyze first.\n',FCTNAME);
    return
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
elseif flag.mrsiFormat==3       % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,abs(mrsi.spec1.spec));
else                            % phase
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.spec1.sw,angle(mrsi.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhSpec1') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhSpec1)
        delete(mrsi.fhSpec1)
    end
    mrsi = rmfield(mrsi,'fhSpec1');
end
% create figure if necessary
if ~isfield(mrsi,'fhSpec1') || ~ishandle(mrsi.fhSpec1)
    mrsi.fhSpec1 = figure('IntegerHandle','off');
    set(mrsi.fhSpec1,'NumberTitle','off','Name',sprintf(' Spectrum 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhSpec1)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhSpec1)
            return
        end
    end
end
clf(mrsi.fhSpec1)

%--- data visualization ---
% plot(ppmZoom,spec1Zoom,'LineWidth',2)
plot(ppmZoom,spec1Zoom)
set(gca,'XDir','reverse')
if flag.mrsiAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = mrsi.amplMin;
    plotLim(4) = mrsi.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
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
    ylabel(sprintf('Amplitude [a.u.], L/R %.0f, P/A %.0f',mrsi.selectLR,mrsi.selectPA))
else
    ylabel(sprintf('Angle [rad], L/R %.0f, P/A %.0f',mrsi.selectLR,mrsi.selectPA)')
end
xlabel('Frequency [ppm]')

%--- spectrum analysis ---
if flag.mrsiAnaSNR || flag.mrsiAnaFWHM || flag.mrsiAnaIntegr
    fprintf('ANALYSIS OF SPECTRUM 1\n');
    if ~SP2_MRSI_Analysis(mrsi.spec1.spec,mrsi.spec1,plotLim,[flag.mrsiSpec1Lb flag.mrsiSpec1Gb])
        return
    end
end

%--- export handling ---
mrsi.expt.fid    = ifft(ifftshift(mrsi.spec1.spec,1),[],1);
mrsi.expt.sf     = mrsi.spec1.sf;
mrsi.expt.sw_h   = mrsi.spec1.sw_h;
mrsi.expt.nspecC = mrsi.spec1.nspecC;




end
