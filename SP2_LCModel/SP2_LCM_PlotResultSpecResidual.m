%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotResultSpecResidual( f_new )
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
    fprintf('%s ->\nNo target spectrum found. Program aborted.\n',FCTNAME)
    return
end
if ~isfield(lcm,'sw')
    fprintf('%s ->\nTarget spectrum not found. Program aborted.\n',FCTNAME)
    return
end
if ~isfield(lcm.fit,'spec')
    fprintf('%s ->\nNo LCM result spectrum found. Program aborted.\n',FCTNAME)
    return
end
if ~isfield(lcm.fit,'sw')
    fprintf('%s ->\nNo LCM result found. Program aborted.\n',FCTNAME)
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

%--- data extraction: residual ---
% note that here the same ppmCalib is used as the spectra are already aligned
[minI,maxI,ppmZoom,specResidZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                   lcm.sw,real(lcm.fit.resid));
if ~f_done
    fprintf('%s ->\nppm extraction of LCM result failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- noise area extraction (for CRLB analysis) ---
[noiseMinI,noiseMaxI,noisePpmZoom,noiseSpecZoom,f_done] = ...
    SP2_LCM_ExtractPpmRange(lcm.ppmNoiseMin,lcm.ppmNoiseMax,lcm.ppmCalib,lcm.sw,real(lcm.fit.resid));
if ~f_done
    fprintf('%s ->\nNoise area extraction failed. Program aborted.\n',FCTNAME)
    return
end

%--- keep current figure position ---
if isfield(lcm,'fhLcmFitSpecResid') && ishandle(lcm.fhLcmFitSpecResid)
    lcm.fig.fhLcmFitSpecResid = get(lcm.fhLcmFitSpecResid,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmFitSpecResid') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmFitSpecResid)
        delete(lcm.fhLcmFitSpecResid)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecResid');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmFitSpecResid') || ~ishandle(lcm.fhLcmFitSpecResid)
    lcm.fhLcmFitSpecResid = figure('IntegerHandle','off');
    if isfield(lcm,'fig')
        if isfield(lcm.fig,'fhLcmFitSpecResid')
            set(lcm.fhLcmFitSpecResid,'NumberTitle','off','Name',sprintf(' LCM Residual'),...
                'Position',lcm.fig.fhLcmFitSpecResid,'Color',[1 1 1],'Tag','LCM');
        else
            set(lcm.fhLcmFitSpecResid,'NumberTitle','off','Name',sprintf(' LCM Residual'),...
                'Color',[1 1 1],'Tag','LCM');
        end
    else
        set(lcm.fhLcmFitSpecResid,'NumberTitle','off','Name',sprintf(' LCM Residual'),...
            'Color',[1 1 1],'Tag','LCM');
    end 
else
    set(0,'CurrentFigure',lcm.fhLcmFitSpecResid)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmFitSpecResid)
            return
        end
    end
end
clf(lcm.fhLcmFitSpecResid)

%--- data visualization ---
plot(ppmZoom,specResidZoom,'LineWidth',lcm.lineWidth,'Color',[0.6 0.6 0.6])
set(gca,'XDir','reverse')
if flag.lcmAmpl         % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specLcmZoom);
    minY = lcm.amplMin;
    maxY = lcm.amplMax;
else                    % automatic
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specResidZoom);
end
if flag.lcmPpmShowPos
    hold on
    plot([lcm.ppmShowPos lcm.ppmShowPos],[minY maxY],'Color',[0 0 0])
    hold off
end
axis([minX maxX minY maxY])
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- show LCModel limits as vertical lines ---
xLim = get(gca,'XLim');
yLim = get(gca,'YLim');
hold on
for winCnt = 1:lcm.anaPpmN
    plot([lcm.anaPpmMin(winCnt) lcm.anaPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
    plot([lcm.anaPpmMax(winCnt) lcm.anaPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
end
hold off

%--- visualization of noise area ---
hold on 
plot([lcm.ppmNoiseMin lcm.ppmNoiseMin],[yLim(1) yLim(2)],'r')
plot([lcm.ppmNoiseMax lcm.ppmNoiseMax],[yLim(1) yLim(2)],'r')
hold off

%--- info printout ---
if f_new || flag.verbose
    fprintf('Display limits of residual plot %s\n',SP2_Vec2PrintStr([xLim, yLim],3,1))
end

%--- figure selection ---
flag.lcmFigSelect = 6;

%--- export handling ---
lcm.expt.fid    = ifft(ifftshift(lcm.fit.resid,1),[],1);
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- update success flag ---
f_succ = 1;


