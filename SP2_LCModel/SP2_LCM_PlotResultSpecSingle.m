%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotResultSpecSingle( f_new )
%%
%%  Plot single metabolite fit of LCM analysis.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag fm

FCTNAME = 'SP2_LCM_PlotResultSpecSingle';


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
if ~isfield(lcm.fit,'spec')
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

%--- update current metabolite ---
if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
    lcm.fit.currShow = max(min(str2double(get(fm.lcm.singleCurr,'String')),max(lcm.fit.appliedFitN+1,1)),1);
else
    lcm.fit.currShow = max(min(str2double(get(fm.lcm.singleCurr,'String')),max(lcm.fit.appliedFitN,1)),1);
end
SP2_LCM_LCModelWinUpdate

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

%--- data extraction: LCM result ---
% note that here the same ppmCalib is used as the spectra are already aligned
if lcm.fit.currShow>lcm.fit.appliedFitN            % baseline
    [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                     lcm.sw,real(lcm.fit.polySpec));
else                                            % metabolites
    [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                     lcm.sw,real(lcm.fit.spec(:,lcm.fit.currShow)));
end
if ~f_done
    fprintf('%s ->\nppm extraction of LCM result failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: target spectrum ---
[minI,maxI,ppmZoom,specTargetZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinLcm,ppmMaxLcm,lcm.ppmCalib,...
                                                                    lcm.sw,real(lcm.spec));
if ~f_done
    fprintf('%s ->\nppm extraction of target spectrum failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: baseline spectrum ---
if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
    [minI,maxI,ppmZoom,specBaseZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinLcm,ppmMaxLcm,lcm.ppmCalib,...
                                                                      lcm.sw,real(lcm.fit.polySpec));
    if ~f_done
        fprintf('%s ->\nppm extraction of target spectrum failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- keep current figure position ---
if isfield(lcm,'fhLcmFitSpecSingle') && ishandle(lcm.fhLcmFitSpecSingle)
    lcm.fig.fhLcmFitSpecSingle = get(lcm.fhLcmFitSpecSingle,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmFitSpecSingle') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmFitSpecSingle)
        delete(lcm.fhLcmFitSpecSingle)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecSingle');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmFitSpecSingle') || ~ishandle(lcm.fhLcmFitSpecSingle)
    lcm.fhLcmFitSpecSingle = figure('IntegerHandle','off');
    if isfield(lcm,'fig')
        if isfield(lcm.fig,'fhLcmFitSpecSingle')
            set(lcm.fhLcmFitSpecSingle,'NumberTitle','off','Name',sprintf(' LCM Single'),...
                'Position',lcm.fig.fhLcmFitSpecSingle,'Color',[1 1 1],'Tag','LCM');
        else
            set(lcm.fhLcmFitSpecSingle,'NumberTitle','off','Name',sprintf(' LCM Single'),...
                'Color',[1 1 1],'Tag','LCM');
        end
    else
        set(lcm.fhLcmFitSpecSingle,'NumberTitle','off','Name',sprintf(' LCM Single'),...
            'Color',[1 1 1],'Tag','LCM');
    end
else
    set(0,'CurrentFigure',lcm.fhLcmFitSpecSingle)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmFitSpecSingle)
            return
        end
    end
end
clf(lcm.fhLcmFitSpecSingle)

%--- data visualization ---
% note that the inclusion of the baseline means that the baseline is
% subtracted from both the target and the fitted spectrum.
% When the baseline is not considered, it is still displayed as is.
hold on
if flag.lcmPlotInclTarget
    if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
        if flag.lcmPlotBaseCorr
            if lcm.fit.currShow<=lcm.fit.appliedFitN
                plot(ppmZoom,specBaseZoom,'LineWidth',lcm.lineWidth,'Color',[0 1 1])
            end
            plot(ppmZoom,specTargetZoom,'LineWidth',lcm.lineWidth,'Color',[0 0 0])
            if lcm.fit.currShow>lcm.fit.appliedFitN
                plot(ppmZoom,specSingleZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
            else
                plot(ppmZoom,specSingleZoom+specBaseZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
            end
        else
            if lcm.fit.currShow<=lcm.fit.appliedFitN   % only show if not displayed as 'metabolite'
                plot(ppmZoom,specBaseZoom,'LineWidth',lcm.lineWidth,'Color',[0 1 1])
            end
            plot(ppmZoom,specTargetZoom,'LineWidth',lcm.lineWidth,'Color',[0 0 0])
            plot(ppmZoom,specSingleZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
        end
    else
        plot(ppmZoom,specTargetZoom,'LineWidth',lcm.lineWidth,'Color',[0 0 0])
        plot(ppmZoom,specSingleZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
    end
else
    if flag.lcmPlotBaseCorr && (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
        if lcm.fit.currShow<=lcm.fit.appliedFitN   % only add baseline when baseline is not shown itself as 'metabolite'
            plot(ppmZoom,specSingleZoom+specBaseZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
        else
            plot(ppmZoom,specSingleZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
        end    
    else
        if (flag.lcmAnaPoly || flag.lcmAnaSpline) && lcm.fit.currShow<=lcm.fit.appliedFitN && isfield(lcm.fit,'polySpec')
            plot(ppmZoom,specBaseZoom,'LineWidth',lcm.lineWidth,'Color',[0 1 1])
        end
        plot(ppmZoom,specSingleZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
    end
end
hold off
set(gca,'XDir','reverse')
if flag.lcmAmpl                         % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specSingleZoom);
    minY = lcm.amplMin;
    maxY = lcm.amplMax;
elseif flag.lcmPlotInclTarget           % automatic, target spectrum included
    if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
        if flag.lcmPlotBaseCorr && (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
            [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
            if lcm.fit.currShow>lcm.fit.appliedFitN
                [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSingleZoom);
            else
                [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSingleZoom+specBaseZoom);
            end
            minX = min([minX1 minX2]);
            maxX = max([maxX1 maxX2]);
            minY = min([minY1 minY2]);
            maxY = max([maxY1 maxY2]);
        else
            [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
            [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSingleZoom);
            [minX3 maxX3 minY3 maxY3] = SP2_IdealAxisValues(ppmZoom,specBaseZoom);
            minX = min([minX1 minX2 minX3]);
            maxX = max([maxX1 maxX2 maxX3]);
            minY = min([minY1 minY2 minY3]);
            maxY = max([maxY1 maxY2 minY3]);
        end
    else
        [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
        [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSingleZoom);
        minX = min([minX1 minX2]);
        maxX = max([maxX1 maxX2]);
        minY = min([minY1 minY2]);
        maxY = max([maxY1 maxY2]);
    end
else                                    % automatic, target spectrum not included
    if flag.lcmPlotBaseCorr && (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
        if lcm.fit.currShow<=lcm.fit.appliedFitN   % only add baseline when baseline is not shown itself as 'metabolite'
            [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specSingleZoom+specBaseZoom);
        else
            [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specSingleZoom);
        end
    else
        [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specSingleZoom);
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
    if lcm.fit.currShow>lcm.fit.appliedFitN                 % baseline
        if flag.lcmPlotInclTarget                           % target included
            lh = legend('Target','Baseline');
        else                                                % target not included
            lh = legend('Baseline');
        end
    elseif flag.lcmPlotInclTarget                           % metab + target
        if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')     % baseline shown
            lh = legend(SP2_PrVersionUscoreCell({'Baseline','Target',sprintf('%s',lcm.basis.data{lcm.fit.appliedFit(lcm.fit.currShow)}{1})}));
        else                                                % baseline not shown
            lh = legend(SP2_PrVersionUscoreCell({'Target',sprintf('%s',lcm.basis.data{lcm.fit.appliedFit(lcm.fit.currShow)}{1})}));
        end
    else                                                    % metab without target
        if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')     % baseline shown
            if lcm.fit.currShow<=lcm.fit.appliedFitN        % only consider baseline when baseline is not shown itself as 'metabolite'
                lh = legend(SP2_PrVersionUscoreCell({'Baseline',sprintf('%s',lcm.basis.data{lcm.fit.appliedFit(lcm.fit.currShow)}{1})}));
            else
                lh = legend(SP2_PrVersionUscoreCell(sprintf('%s',lcm.basis.data{lcm.fit.appliedFit(lcm.fit.currShow)}{1})));
            end
        else                                                % baseline not shown
            lh = legend(SP2_PrVersionUscoreCell(sprintf('%s',lcm.basis.data{lcm.fit.appliedFit(lcm.fit.currShow)}{1})));
        end
    end
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

%--- info printout ---
if f_new || flag.verbose
    fprintf('Display limits of single plot %s\n',SP2_Vec2PrintStr([xLim, yLim],3,1));
end

%--- spectrum analysis ---
if (flag.lcmAnaSNR || flag.lcmAnaFWHM || flag.lcmAnaIntegr) && lcm.fit.currShow<=lcm.fit.appliedFitN         % metab only, no baseline
    fprintf('ANALYSIS OF TARGET SPECTRUM\n');
    if flag.lcmPlotBaseCorr && (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
        if ~SP2_LCM_Analysis(lcm.fit.spec(:,lcm.fit.currShow)+lcm.fit.polySpec,[minX maxX minY maxY],[flag.lcmSpecLb flag.lcmSpecGb])
            return
        end
    else
        if ~SP2_LCM_Analysis(lcm.fit.spec(:,lcm.fit.currShow),[minX maxX minY maxY],[flag.lcmSpecLb flag.lcmSpecGb])
            return
        end
    end
end

%--- figure selection ---
flag.lcmFigSelect = 5;

%--- export handling ---
if lcm.fit.currShow>lcm.fit.appliedFitN        % baseline
    lcm.expt.fid    = ifft(ifftshift(lcm.fit.polySpec,1),[],1);
else                                        % metabolite
    lcm.expt.fid    = ifft(ifftshift(lcm.fit.spec(:,lcm.fit.currShow),1),[],1);
end
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- update success flag ---
f_succ = 1;
