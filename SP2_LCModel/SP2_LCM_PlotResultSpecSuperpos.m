%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotResultSpecSuperpos( f_new )
%%
%%  Plot spectrum superposition of target spectrum and overall LCM fit.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_PlotResultSpecSuperpos';


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
if (flag.lcmAnaPoly || flag.lcmAnaSpline) && ~isfield(lcm.fit,'polySpec')
    fprintf('%s -> No polynomial baseline found. Program aborted\n',FCTNAME);
    return
end
%--- metabolite selection ---
if flag.lcmShowSelAll           % selection
    if any(lcm.showSel<1)
        fprintf('%s ->\nMinimum metabolite number <1 detected!\n',FCTNAME);
        return
    end
    if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')              % baseline included
        % if any(lcm.showSel>lcm.fit.appliedFitN+1)
        if any(lcm.showSel>lcm.fit.appliedFitN)
%             fprintf('%s ->\nAt least one metabolite number exceeds number of fitted\nspectral components (%.0f metabs + baseline = %.0f)\n',...
%                     FCTNAME,lcm.fit.appliedFitN,lcm.fit.appliedFitN+1)
            fprintf('%s ->\nAt least one metabolite number exceeds number of fitted\nspectral components (%.0f metabs)\n',...
                    FCTNAME,lcm.fit.appliedFitN)
            return
        end
    else                            % baseline not fitted
        if any(lcm.showSel>lcm.fit.appliedFitN)
            fprintf('%s ->\nAt least one metabolite number exceeds number of\nfitted spectral components (%.0f metabs)\n',...
                    FCTNAME,lcm.fit.appliedFitN)
            return
        end
    end
    if isempty(lcm.showSel)
        fprintf('%s ->\nEmpty metabolite selection detected.\nMinimum: 1 metabolite!\n',FCTNAME);
        return
    end
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

%--- dimension handling ---
if flag.lcmShowSelAll           % spectrum selection
    nSuper = lcm.showSelN;
else                            % all metabolites
    if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotBaseCorr && isfield(lcm.fit,'polySpec')         % include polynomial baseline: 1) itself, 2) as part of every metabolite trace
        nSuper = lcm.fit.appliedFitN + 1;
    else
        nSuper = lcm.fit.appliedFitN;
    end
end 
    
%--- definition of color matrix ---
if flag.lcmColorMap==1
    colorMat = colormap(jet(nSuper));
elseif flag.lcmColorMap==2
    colorMat = colormap(hsv(nSuper));
elseif flag.lcmColorMap==3
    colorMat = colormap(hot(nSuper));
end

%--- data extraction: target spectrum ---
if flag.lcmPlotInclTarget
    [minI,maxI,ppmZoom,specTargetZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinLcm,ppmMaxLcm,lcm.ppmCalib,...
                                                                        lcm.sw,real(lcm.spec));
    if ~f_done
        fprintf('%s ->\nppm extraction of target spectrum failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- data extraction: polynomial baseline ---
if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
    [minI,maxI,ppmZoom,specBaseZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinLcm,ppmMaxLcm,lcm.ppmCalib,...
                                                                      lcm.sw,real(lcm.fit.polySpec));
    if ~f_done
        fprintf('%s ->\nppm extraction of target spectrum failed. Program aborted.\n\n',FCTNAME);
        return
    end
end

%--- data extraction: LCM fit sum ---
% note that here the same ppmCalib is used as the spectra are already aligned
[minI,maxI,ppmZoom,specSumZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                 lcm.sw,real(lcm.fit.sumSpec));
if ~f_done
    fprintf('%s ->\nppm extraction of LCM residual failed. Program aborted.\n\n',FCTNAME);
    return
end
% note: always loaded (for axis handling), but not necessarily shown

%--- data extraction: LCM result ---
% note that here the same ppmCalib is used as the spectra are already aligned
if flag.lcmPlotInclResid
    [minI,maxI,ppmZoom,specResidZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                    lcm.sw,real(lcm.fit.resid));
    if ~f_done
        fprintf('%s ->\nppm extraction of LCM residual failed. Program aborted.\n\n',FCTNAME);
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
if isfield(lcm,'fhLcmFitSpecSuperpos') && ishandle(lcm.fhLcmFitSpecSuperpos)
    lcm.fig.fhLcmFitSpecSuperpos = get(lcm.fhLcmFitSpecSuperpos,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmFitSpecSuperpos') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmFitSpecSuperpos)
        delete(lcm.fhLcmFitSpecSuperpos)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecSuperpos');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmFitSpecSuperpos') || ~ishandle(lcm.fhLcmFitSpecSuperpos)
    lcm.fhLcmFitSpecSuperpos = figure('IntegerHandle','off');
    if isfield(lcm,'fig')
        if isfield(lcm.fig,'fhLcmFitSpecSuperpos')
            set(lcm.fhLcmFitSpecSuperpos,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
                'Position',lcm.fig.fhLcmFitSpecSuperpos,'Color',[1 1 1],'Tag','LCM');
        else
            set(lcm.fhLcmFitSpecSuperpos,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
                'Color',[1 1 1],'Tag','LCM');
        end
    else
        set(lcm.fhLcmFitSpecSuperpos,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
            'Color',[1 1 1],'Tag','LCM');
    end
else
    set(0,'CurrentFigure',lcm.fhLcmFitSpecSuperpos)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmFitSpecSuperpos)
            return
        end
    end
end
clf(lcm.fhLcmFitSpecSuperpos)

%--- init plot limits ---
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

%--- axis handling - part 1 ---
if flag.lcmAmpl                         % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specSumZoom);
    minY = lcm.amplMin;
    maxY = lcm.amplMax;
elseif flag.lcmPlotInclTarget           % automatic, target spectrum included
    if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
        if flag.lcmPlotBaseCorr && (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
            [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
            if lcm.fit.currShow>lcm.fit.appliedFitN
                [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSumZoom);
            else
                [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSumZoom+specBaseZoom);
            end
            minX = min([minX1 minX2]);
            maxX = max([maxX1 maxX2]);
            minY = min([minY1 minY2]);
            maxY = max([maxY1 maxY2]);
        else
            [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
            [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSumZoom);
            [minX3 maxX3 minY3 maxY3] = SP2_IdealAxisValues(ppmZoom,specBaseZoom);
            minX = min([minX1 minX2 minX3]);
            maxX = max([maxX1 maxX2 maxX3]);
            minY = min([minY1 minY2 minY3]);
            maxY = max([maxY1 maxY2 minY3]);
        end
    else
        [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
        [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specSumZoom);
        minX = min([minX1 minX2]);
        maxX = max([maxX1 maxX2]);
        minY = min([minY1 minY2]);
        maxY = max([maxY1 maxY2]);
    end
else                                    % automatic, target spectrum not included
    if flag.lcmPlotBaseCorr && (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')
        [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specSumZoom+specBaseZoom);
    else
        [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specSumZoom);
    end
end


%--- serial plot of individual traces ---
hold on
for bCnt = 1:nSuper
    %--- data extraction: individual LCM traces ---
    % note that here the same ppmCalib is used as the spectra are already aligned
    if flag.lcmShowSelAll                   % metabolite selection
        if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotBaseCorr && isfield(lcm.fit,'polySpec')
            if bCnt==lcm.fit.appliedFitN+1  % baseline
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec));
            else                            % baseline + metabolite
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec+lcm.fit.spec(:,lcm.showSel(bCnt))));
            end
        else                                % metabolite only
            if lcm.showSel(bCnt)>lcm.fit.appliedFitN        % baseline
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec));
            else                            % metabolite
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.spec(:,lcm.showSel(bCnt))));
            end
        end
    else                                    % all metabolites
        if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotBaseCorr && isfield(lcm.fit,'polySpec')
            if bCnt==nSuper                 % baseline
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec));
            else                            % baseline + metabolite
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec+lcm.fit.spec(:,bCnt)));
            end
        else                                % metabolite only
            if bCnt>lcm.fit.appliedFitN     % baseline
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec));
            else                            % metabolite
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.spec(:,bCnt)));
            end
        end
    end
    if ~f_done
        fprintf('%s ->\nppm extraction of LCM result failed. Program aborted.\n\n',FCTNAME);
        return
    end
    
    %--- plot individual trace ---
    if flag.lcmColorMap==0          % blue only
        plot(ppmZoom,specSingleZoom,'LineWidth',lcm.lineWidth)
    else
        plot(ppmZoom,specSingleZoom,'LineWidth',lcm.lineWidth,'Color',colorMat(bCnt,:))
    end
    
    %--- axis handling - part 2 ---
    if flag.lcmPlotInclTarget
        if ~flag.lcmAmpl                % automatic
            [minX maxX minYsingle maxYsingle] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
            minY = min(minY,minYsingle);
            maxY = max(maxY,maxYsingle);
        end
    end
end

%--- data visualization of main traces ---
if flag.lcmPlotInclResid
    plot(ppmZoom,specResidZoom,'LineWidth',lcm.lineWidth,'Color',[0.6 0.6 0.6]);
end
if flag.lcmPlotInclTarget
    plot(ppmZoom,specTargetZoom,'LineWidth',lcm.lineWidth,'Color',[0 0 0]);
end
if flag.lcmPlotInclFit
    plot(ppmZoom,specSumZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0]);
end
set(gca,'XDir','reverse')
if flag.lcmPlotInclTarget
    if flag.lcmAmpl         % direct
        [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specTargetZoom);
        minY = lcm.amplMin;
        maxY = lcm.amplMax;
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
    for bCnt = 1:nSuper
        if flag.lcmShowSelAll                           % selected metabolites
            if lcm.showSel(bCnt)>lcm.fit.appliedFitN       % baseline
                legCell{bCnt} = 'Baseline';
            else                                        % metabolite
                legCell{bCnt} = lcm.basis.data{lcm.fit.appliedFit(lcm.showSel(bCnt))}{1};
            end
        else                                            % all metabolites
            if bCnt>lcm.fit.appliedFitN                    % baseline
                legCell{bCnt} = 'Baseline';
            else                                        % metabolite
                legCell{bCnt} = lcm.basis.data{lcm.fit.appliedFit(bCnt)}{1};
            end
        end
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
    lh = legend(SP2_PrVersionUscoreCell(legCell));
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
    fprintf('Display limits of superposition plot %s\n',SP2_Vec2PrintStr([xLim, yLim],3,1));
end

%--- figure selection ---
flag.lcmFigSelect = 3;

%--- update success flag ---
f_succ = 1;

