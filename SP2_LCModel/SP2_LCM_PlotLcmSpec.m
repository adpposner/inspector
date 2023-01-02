%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotLcmSpec( f_new )
%%
%%  Plot processed spectrum.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm flag

FCTNAME = 'SP2_LCM_PlotLcmSpec';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(lcm,'spec')
    fprintf('%s ->\nSpectral data does not exist. Load/analyze first.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.lcmPpmShow     % direct
    ppmMin = lcm.ppmShowMin;
    ppmMax = lcm.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -lcm.sw/2 + lcm.ppmCalib;
    ppmMax = lcm.sw/2  + lcm.ppmCalib;
end

%--- data extraction: spectrum 1 ---
[minI,maxI,ppmZoom,specZoom,f_done] = SP2_LCM_ExtractPpmRange(min(ppmMin),max(ppmMax),lcm.ppmCalib,...
                                                               lcm.sw,real(lcm.spec));
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(lcm,'fhLcmSpec') && ishandle(lcm.fhLcmSpec)
    lcm.fig.fhLcmSpec = get(lcm.fhLcmSpec,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmSpec') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmSpec)
        delete(lcm.fhLcmSpec)
    end
    lcm = rmfield(lcm,'fhLcmSpec');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmSpec') || ~ishandle(lcm.fhLcmSpec)
    lcm.fhLcmSpec = figure('IntegerHandle','off');
    set(lcm.fhLcmSpec,'NumberTitle','off','Name',' Spectrum',...
        'Position',lcm.fig.fhLcmSpec,'Color',[1 1 1],'Tag','LCM');
else
    set(0,'CurrentFigure',lcm.fhLcmSpec)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmSpec)
            return
        end
    end
end
clf(lcm.fhLcmSpec)

%--- data visualization ---
% plot(ppmZoom,specZoom,'LineWidth',2)
plot(ppmZoom,specZoom)
set(gca,'XDir','reverse')
if flag.lcmAmpl         % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    plotLim(3) = lcm.amplMin;
    plotLim(4) = lcm.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
end
if flag.lcmPpmShowPos
    hold on
    plot([lcm.ppmShowPos lcm.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
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

%--- spectrum analysis ---
if flag.lcmAnaSNR || flag.lcmAnaFWHM || flag.lcmAnaIntegr
    fprintf('ANALYSIS OF TARGET SPECTRUM\n');
    if ~SP2_LCM_Analysis(lcm.spec,plotLim,[flag.lcmSpecLb flag.lcmSpecGb])
        return
    end
end

%--- info printout ---
if f_new || flag.verbose
    fprintf('Display limits of target plot %s\n',SP2_Vec2PrintStr([xLim, yLim],3,1));
end

%--- figure selection ---
flag.lcmFigSelect = 1;

%--- export handling ---
lcm.expt.fid    = ifft(ifftshift(lcm.spec,1),[],1);
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- update success flag ---
f_succ = 1;


