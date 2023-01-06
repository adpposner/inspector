%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotResultSpecSummary( f_new )
%%
%%  Plot summary of LCM analysis.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_PlotResultSpecSummary';


%--- init success flag ---
f_succ = 0;

%--- check data existence and parameter consistency ---
if ~isfield(lcm,'spec')
    fprintf('%s ->\nNo target spectrum found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm,'sw')
    fprintf('%s ->\nTarget spectrum not found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm.fit,'sumSpec')
    fprintf('%s ->\nNo LCM result spectrum found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(lcm.fit,'sw')
    fprintf('%s ->\nNo LCM result found. Program aborted.\n',FCTNAME);
    return
end
%--- SW (and dwell time) ---
if SP2_RoundToNthDigit(lcm.sw,2)~=SP2_RoundToNthDigit(lcm.fit.sw,2)
    fprintf('%s -> SW mismatch detected (%.2 fMHz ~= %.2 fMHz)\n',FCTNAME,...
            lcm.sw,lcm.fit.sw)
    return
end
%--- number of points ---
if lcm.nspecC~=lcm.fit.nspecC
    fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
            lcm.nspecC,lcm.fit.nspecC)
end

%--- ppm limit handling ---
if flag.lcmPpmShow     % direct
    ppmMinLcm = lcm.ppmShowMin;
    ppmMaxLcm = lcm.ppmShowMax;
    ppmMinFit = lcm.ppmShowMin;
    ppmMaxFit = lcm.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMinLcm = -lcm.sw/2 + lcm.ppmCalib;
    ppmMaxLcm = lcm.sw/2  + lcm.ppmCalib;
    ppmMinFit = -lcm.sw/2 + lcm.ppmCalib;
    ppmMaxFit = lcm.sw/2  + lcm.ppmCalib;
end

%--- data extraction: target spectrum ---
[minI,maxI,ppmZoom,specLcmZoom,f_done] = SP2_LCM_ExtractPpmRange(min(ppmMinLcm),max(ppmMaxLcm),lcm.ppmCalib,...
                                                                 lcm.sw,real(lcm.spec));
if ~f_done
    fprintf('%s ->\nppm extraction of target spectrum failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: polynomial baseline spectrum ---
if flag.lcmAnaPoly && isfield(lcm.fit,'polySpec')
    [minI,maxI,ppmZoom,specBaseZoom,f_done] = SP2_LCM_ExtractPpmRange(min(ppmMinLcm),max(ppmMaxLcm),lcm.ppmCalib,...
                                                                      lcm.sw,real(lcm.fit.polySpec));
    if ~f_done
        fprintf('%s ->\nppm extraction of target spectrum failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- data extraction: LCM result ---
% note that here the same ppmCalib is used as the spectra are already aligned
[minI,maxI,ppmZoom,specFitZoom,f_done] = SP2_LCM_ExtractPpmRange(min(ppmMinFit),max(ppmMaxFit),lcm.ppmCalib,...
                                                                 lcm.sw,real(lcm.fit.sumSpec));
if ~f_done
    fprintf('%s ->\nppm extraction of LCM result failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: residual ---
% note that here the same ppmCalib is used as the spectra are already aligned
if flag.lcmPlotInclResid
    [minI,maxI,ppmZoom,specResidZoom,f_done] = SP2_LCM_ExtractPpmRange(min(ppmMinFit),max(ppmMaxFit),lcm.ppmCalib,...
                                                                       lcm.sw,real(lcm.fit.resid));
    if ~f_done
        fprintf('%s ->\nppm extraction of LCM result failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

% %--- noise area extraction (for CRLB analysis) ---
% [noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
%     SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,real(lcm.fit.resid));
% if ~f_done
%     fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME);
%     return
% end

%--- keep current figure position ---
if isfield(lcm,'fhLcmFitSpecSummary') && ishandle(lcm.fhLcmFitSpecSummary)
    lcm.fig.fhLcmFitSpecSummary = get(lcm.fhLcmFitSpecSummary,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmFitSpecSummary') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmFitSpecSummary)
        delete(lcm.fhLcmFitSpecSummary)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecSummary');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmFitSpecSummary') || ~ishandle(lcm.fhLcmFitSpecSummary)
    lcm.fhLcmFitSpecSummary = figure('IntegerHandle','off');
    if isfield(lcm,'fig')
        if isfield(lcm.fig,'fhLcmFitSpecSummary')
            set(lcm.fhLcmFitSpecSummary,'NumberTitle','off','Name',sprintf(' LCM Summary'),...
                'Position',lcm.fig.fhLcmFitSpecSummary,'Color',[1 1 1],'Tag','LCM');
        else
            set(lcm.fhLcmFitSpecSummary,'NumberTitle','off','Name',sprintf(' LCM Summary'),...
                'Color',[1 1 1],'Tag','LCM');
        end
    else
        set(lcm.fhLcmFitSpecSummary,'NumberTitle','off','Name',sprintf(' LCM Summary'),...
            'Color',[1 1 1],'Tag','LCM');
    end
else
    set(0,'CurrentFigure',lcm.fhLcmFitSpecSummary)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmFitSpecSummary)
            return
        end
    end
end
clf(lcm.fhLcmFitSpecSummary)

%--- data visualization ---
hold on
if flag.lcmAnaPoly && isfield(lcm.fit,'polySpec')
    plot(ppmZoom,specBaseZoom,'LineWidth',lcm.lineWidth,'Color',[0 1 1])
end
if flag.lcmPlotInclResid
    plot(ppmZoom,specResidZoom,'LineWidth',lcm.lineWidth,'Color',[0.6 0.6 0.6])
end
if flag.lcmPlotInclTarget
    plot(ppmZoom,specLcmZoom,'LineWidth',lcm.lineWidth,'Color',[0 0 0])
end
if flag.lcmPlotInclFit
    plot(ppmZoom,specFitZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
end
hold off
set(gca,'XDir','reverse')
minX1 = 1e20;
minX2 = minX1;
minX3 = minX1;
minX4 = minX1;
maxX1 = -1e20;
maxX2 = maxX1;
maxX3 = maxX1;
maxX4 = maxX1;
minY1 = 1e20;
minY2 = minY1;
minY3 = minY1;
minY4 = minY1;
maxY1 = -1e20;
maxY2 = maxY1;
maxY3 = maxY1;
maxY4 = maxY1;
if flag.lcmAmpl                     % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specLcmZoom);
    minY = lcm.amplMin;
    maxY = lcm.amplMax;
elseif flag.lcmAnaPoly && isfield(lcm.fit,'polySpec')   % automatic including polynomial baseline
    if flag.lcmPlotInclTarget    
        [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specLcmZoom);
    end
    if flag.lcmPlotInclFit
        [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specFitZoom);
    end
    [minX3 maxX3 minY3 maxY3] = SP2_IdealAxisValues(ppmZoom,specBaseZoom);
    if flag.lcmPlotInclResid
        [minX4 maxX4 minY4 maxY4] = SP2_IdealAxisValues(ppmZoom,specResidZoom);
    end
    minX = min([minX1 minX2 minX3 minX4]);
    maxX = max([maxX1 maxX2 maxX3 maxX4]);
    minY = min([minY1 minY2 minY3 minY4]);
    maxY = max([maxY1 maxY2 maxY3 maxY4]);
else                                                    % automatic without polynomial baseline
    if flag.lcmPlotInclTarget    
        [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specLcmZoom);
    end
    if flag.lcmPlotInclFit    
        [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specFitZoom);
    end
    if flag.lcmPlotInclResid
        [minX3 maxX3 minY3 maxY3] = SP2_IdealAxisValues(ppmZoom,specResidZoom);
    end
    minX = min([minX1 minX2 minX3]);
    maxX = max([maxX1 maxX2 maxX3]);
    minY = min([minY1 minY2 minY3]);
    maxY = max([maxY1 maxY2 maxY3]);
    if ~flag.lcmPlotInclTarget && ~flag.lcmPlotInclFit && ~flag.lcmPlotInclResid
        [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specLcmZoom);
    end
end
if flag.lcmPpmShowPos
    hold on
    plot([lcm.ppmShowPos lcm.ppmShowPos],[minY maxY],'Color',[0 0 0],'HandleVisibility','off')
    hold off
end
axis([minX maxX minY maxY])
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
if flag.lcmLegend
    legCell = {};
    if flag.lcmAnaPoly && isfield(lcm.fit,'polySpec')
        legCell{length(legCell)+1} = 'Baseline';
    end
    if flag.lcmPlotInclResid
        legCell{length(legCell)+1} = 'Residual';
    end
    if flag.lcmPlotInclTarget
        legCell{length(legCell)+1} = 'Spectrum';
    end
    if flag.lcmPlotInclFit
        legCell{length(legCell)+1} = 'LCM Fit';
    end
    lh = legend(legCell);
    set(lh,'Location','Best')
end

%--- show LCModel limits as vertical lines ---
xLim = get(gca,'XLim');
yLim = get(gca,'YLim');
hold on
for winCnt = 1:lcm.anaPpmN
    plot([lcm.anaPpmMin(winCnt) lcm.anaPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0],'HandleVisibility','off')
    plot([lcm.anaPpmMax(winCnt) lcm.anaPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0],'HandleVisibility','off')
end
hold off

%--- visualization of noise area ---
hold on 
plot([lcm.ppmNoiseMin lcm.ppmNoiseMin],[yLim(1) yLim(2)],'r','HandleVisibility','off')
plot([lcm.ppmNoiseMax lcm.ppmNoiseMax],[yLim(1) yLim(2)],'r','HandleVisibility','off')
hold off

%--- info printout ---
if f_new || flag.verbose
    fprintf('Display limits of summary plot %s\n',SP2_Vec2PrintStr([xLim, yLim],3,1));
end

%--- figure selection ---
flag.lcmFigSelect = 2;

%--- export handling ---
lcm.expt.fid    = ifft(ifftshift(lcm.fit.sumSpec,1),[],1);
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- update success flag ---
f_succ = 1;


end
