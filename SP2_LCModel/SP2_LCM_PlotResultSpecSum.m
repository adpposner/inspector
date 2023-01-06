%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotResultSpecSum( f_new )
%%
%%  Plot single metabolite fit of LCM analysis.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag fm

FCTNAME = 'SP2_LCM_PlotResultSpecSum';


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

%--- dimension handling ---
if flag.lcmShowSelAll           % spectrum selection
    nSum = lcm.showSelN;
else                            % all metabolites
%     if flag.lcmAnaPoly && flag.lcmUpdProcBasis && isfield(lcm.fit,'polySpec')         % include polynomial baseline: 1) itself, 2) as part of every metabolite trace
    if (flag.lcmAnaPoly || flag.lcmAnaSpline) && isfield(lcm.fit,'polySpec')         % include polynomial baseline: 1) itself, 2) as part of every metabolite trace
        nSum = lcm.fit.appliedFitN + 1;
    else
        nSum = lcm.fit.appliedFitN;
    end
end 

%--- data extraction: LCM result ---
% note that here the same ppmCalib is used as for the spectra that are already aligned
for bCnt = 1:nSum
    %--- data extraction: individual LCM traces ---
    % note that here the same ppmCalib is used as the spectra are already aligned
    if flag.lcmShowSelAll                                   % metabolite selection
%         if flag.lcmAnaPoly && ~flag.lcmUpdProcBasis && isfield(lcm.fit,'polySpec')
        if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotBaseCorr && isfield(lcm.fit,'polySpec')
            if bCnt==lcm.fit.appliedFitN+1                     % baseline
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec));
                specSingleFull = lcm.fit.polySpec;
            else                                            % baseline + metabolite
                if bCnt==1
                    [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                        lcm.sw,real(lcm.fit.polySpec+lcm.fit.spec(:,lcm.showSel(bCnt))));
                    specSingleFull = lcm.fit.polySpec+lcm.fit.spec(:,lcm.showSel(bCnt));
                else
                    [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                        lcm.sw,real(lcm.fit.spec(:,lcm.showSel(bCnt))));
                    specSingleFull = lcm.fit.spec(:,lcm.showSel(bCnt));
                end
            end
        else                                                % metabolite only
            if lcm.showSel(bCnt)>lcm.fit.appliedFitN           % baseline
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.polySpec));
                specSingleFull = lcm.fit.polySpec;
            else                                            % metabolites
                [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                    lcm.sw,real(lcm.fit.spec(:,lcm.showSel(bCnt))));
                specSingleFull = lcm.fit.spec(:,lcm.showSel(bCnt));
            end
        end
    else                                                    % all metabolites
        if bCnt>lcm.fit.appliedFitN                     % baseline
            [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                lcm.sw,real(lcm.fit.polySpec));
            specSingleFull = lcm.fit.polySpec;
        else                                            % metabolites
            [minI,maxI,ppmZoom,specSingleZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMinFit,ppmMaxFit,lcm.ppmCalib,...
                                                                                lcm.sw,real(lcm.fit.spec(:,bCnt)));
            specSingleFull = lcm.fit.spec(:,bCnt);
        end
    end
    if ~f_done
        fprintf('%s ->\nppm extraction of LCM result failed. Program aborted.\n\n',FCTNAME);
        return
    end
    if bCnt==1
        specSumZoom = specSingleZoom;
        specSumFull = specSingleFull;
    else
        specSumZoom = specSumZoom + specSingleZoom;
        specSumFull = specSumFull + specSingleFull;
    end
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
if isfield(lcm,'fhLcmFitSpecSum') && ishandle(lcm.fhLcmFitSpecSum)
    lcm.fig.fhLcmFitSpecSum = get(lcm.fhLcmFitSpecSum,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmFitSpecSum') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmFitSpecSum)
        delete(lcm.fhLcmFitSpecSum)
    end
    lcm = rmfield(lcm,'fhLcmFitSpecSum');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmFitSpecSum') || ~ishandle(lcm.fhLcmFitSpecSum)
    lcm.fhLcmFitSpecSum = figure('IntegerHandle','off');
    if isfield(lcm,'fig')
        if isfield(lcm.fig,'fhLcmFitSpecSum')
            set(lcm.fhLcmFitSpecSum,'NumberTitle','off','Name',sprintf(' LCM Summation'),...
                'Position',lcm.fig.fhLcmFitSpecSum,'Color',[1 1 1],'Tag','LCM');
        else
            set(lcm.fhLcmFitSpecSum,'NumberTitle','off','Name',sprintf(' LCM Summation'),...
                'Color',[1 1 1],'Tag','LCM');
        end
    else
        set(lcm.fhLcmFitSpecSum,'NumberTitle','off','Name',sprintf(' LCM Summation'),...
            'Color',[1 1 1],'Tag','LCM');
    end
else
    set(0,'CurrentFigure',lcm.fhLcmFitSpecSum)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmFitSpecSum)
            return
        end
    end
end
clf(lcm.fhLcmFitSpecSum)

%--- data visualization ---
% not that the inclusion of the baseline means that the baseline is
% subtracted from both the target and the fitted spectrum.
% When the baseline is not considered, it is still displayed as is.
hold on
if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotInclBase && isfield(lcm.fit,'polySpec')
    plot(ppmZoom,specBaseZoom,'LineWidth',lcm.lineWidth,'Color',[0 1 1])
end
if flag.lcmPlotInclTarget
    plot(ppmZoom,specTargetZoom,'LineWidth',lcm.lineWidth,'Color',[0 0 0])
end
plot(ppmZoom,specSumZoom,'LineWidth',lcm.lineWidth,'Color',[1 0 0])
hold off
set(gca,'XDir','reverse')

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
if flag.lcmPpmShowPos
    hold on
    plot([lcm.ppmShowPos lcm.ppmShowPos],[minY maxY],'Color',[0 0 0],'HandleVisibility','off')
    hold off
end
axis([minX maxX minY maxY])
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
if flag.lcmLegend
    if flag.lcmShowSelAll                % selected metabolites
        legCell    = {};
        if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotInclBase && isfield(lcm.fit,'polySpec')     % baseline shown separatrel
            legCell{length(legCell)+1} = 'Baseline';
        end
        if flag.lcmPlotInclTarget
            legCell{length(legCell)+1} = 'Target';
        end
        legSize = length(legCell);
        for bCnt = 1:lcm.showSelN;
            if bCnt==1    
                legCell{legSize+1} = sprintf('%s',lcm.basis.data{lcm.fit.appliedFit(lcm.showSel(bCnt))}{1});
            else
                if lcm.showSel(bCnt)>lcm.fit.appliedFitN          % baseline -> metabolite
                    legCell{legSize+1} = [legCell{legSize+1} '+baseline'];
                else                                            % regular metabolite
                    legCell{legSize+1} = [legCell{legSize+1} '+' sprintf('%s',lcm.basis.data{lcm.fit.appliedFit(lcm.showSel(bCnt))}{1})];
                end
            end
        end
        lh = legend(SP2_PrVersionUscoreCell(legCell));
    else                                % all metabolites
        if flag.lcmPlotInclTarget                           % metab + target
            if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotInclBase && isfield(lcm.fit,'polySpec')     % baseline shown
                lh = legend('Baseline','Target','LCM total');
            else                                            % baseline not shown
                lh = legend('Target','LCM total');
            end
        else                                                % metab without target
            if (flag.lcmAnaPoly || flag.lcmAnaSpline) && flag.lcmPlotInclBase && isfield(lcm.fit,'polySpec')      % baseline shown
                lh = legend('Baseline','LCM total');
            else
                lh = legend('LCM total');
            end
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
    fprintf('Display limit of summation plot %s\n',SP2_Vec2PrintStr([xLim, yLim],3,1));
end

%--- spectrum analysis ---
if (flag.lcmAnaSNR || flag.lcmAnaFWHM || flag.lcmAnaIntegr)             % metab only, no baseline
    fprintf('ANALYSIS OF SUMMATION SPECTRUM\n');
    if ~SP2_LCM_Analysis(specSumFull,[minX maxX minY maxY],[flag.lcmSpecLb flag.lcmSpecGb])
        return
    end
end

%--- figure selection ---
flag.lcmFigSelect = 4;

%--- export handling ---
lcm.expt.fid    = ifft(ifftshift(specSumFull,1),[],1);
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- update success flag ---
f_succ = 1;



end
