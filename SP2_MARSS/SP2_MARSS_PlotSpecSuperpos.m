%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_MARSS_PlotSpecSuperpos( f_new )
%%
%%  Plot spectrum superposition of simulated spectra.
%% 
%%  01-2020, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global marss flag

FCTNAME = 'SP2_MARSS_PlotSpecSuperpos';


%--- init success flag ---
f_succ = 0;

%--- check data existence and parameter consistency ---
if ~isfield(marss,'basis')
    fprintf('%s ->\nNo basis data found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'sf')
    fprintf('%s ->\nLarmor frequency of basis not found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'sw')
    fprintf('%s ->\nSweep width of basis not found. Program aborted.\n',FCTNAME);
    return
end
if ~isfield(marss.basis,'spec')
    fprintf('%s ->\nBasis spectra not found. Program aborted.\n',FCTNAME);
    return
end

%--- metabolite selection ---
if flag.marssShowSelAll           % selection
    if any(marss.showSel<1)
        fprintf('%s ->\nMinimum metabolite number <1 detected!\n',FCTNAME);
        return
    end
    if any(marss.showSel>marss.basis.n)
        fprintf('%s ->\nAt least one metabolite number exceeds number of\nfitted spectral components (%.0f metabs)\n',...
                FCTNAME,marss.basis.n)
        return
    end
    if isempty(marss.showSel)
        fprintf('%s ->\nEmpty metabolite selection detected.\nMinimum: 1 metabolite!\n',FCTNAME);
        return
    end
end

%--- ppm limit handling ---
if flag.marssPpmShow        % full
    ppmMin = -marss.sw/2 + marss.ppmCalib;
    ppmMax = marss.sw/2  + marss.ppmCalib;
else                        % direct
    ppmMin = marss.ppmShowMin;
    ppmMax = marss.ppmShowMax;
end

%--- dimension handling ---
if flag.marssShowSelAll             % spectrum selection
    nSuper = marss.showSelN;
else                                % all metabolites
    nSuper = marss.basis.n;
end 
    
%--- definition of color matrix ---
if flag.marssColorMap==1
    colorMat = colormap(jet(nSuper));
elseif flag.marssColorMap==2
    colorMat = colormap(hsv(nSuper));
elseif flag.marssColorMap==3
    colorMat = colormap(hot(nSuper));
end

%--- index extraction  ---
[minI,maxI,ppmZoom,specZoom1st,f_done] = SP2_MARSS_ExtractPpmRange(ppmMin,ppmMax,marss.ppmCalib,...
                                                                   marss.sw,real(marss.basis.spec(:,1)));
if ~f_done
    fprintf('%s ->\nppm extraction of basis spectra failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: 1) ppm, 2) metabs ---
if flag.marssShowSelAll             % spectrum selection
    specZoomReal = real(marss.basis.spec(minI:maxI,marss.showSel));
else                                % all spectra
    specZoomReal = real(marss.basis.spec(minI:maxI,:));
end

%--- keep current figure position ---
if isfield(marss,'fhMarssSpecSuperpos') && ishandle(marss.fhMarssSpecSuperpos)
    marss.fig.fhMarssSpecSuperpos = get(marss.fhMarssSpecSuperpos,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(marss,'fhMarssSpecSuperpos') && ~flag.marssKeepFig
    if ishandle(marss.fhMarssSpecSuperpos)
        delete(marss.fhMarssSpecSuperpos)
    end
    lcm = rmfield(marss,'fhMarssSpecSuperpos');
end
% create figure if necessary
if ~isfield(marss,'fhMarssSpecSuperpos') || ~ishandle(marss.fhMarssSpecSuperpos)
    marss.fhMarssSpecSuperpos = figure('IntegerHandle','off');
    if isfield(marss,'fig')
        if isfield(marss.fig,'fhMarssSpecSuperpos')
            set(marss.fhMarssSpecSuperpos,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
                'Position',marss.fig.fhMarssSpecSuperpos,'Color',[1 1 1],'Tag','MARSS');
        else
            set(marss.fhMarssSpecSuperpos,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
                'Color',[1 1 1],'Tag','MARSS');
        end
    else
        set(marss.fhMarssSpecSuperpos,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
            'Color',[1 1 1],'Tag','MARSS');
    end
else
    set(0,'CurrentFigure',marss.fhMarssSpecSuperpos)
    if flag.marssKeepFig
        if ~SP2_KeepFigure(marss.fhMarssSpecSuperpos)
            return
        end
    end
end
clf(marss.fhMarssSpecSuperpos)


%--- axis handling - part 1 ---
if flag.marssAmplShow                   % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom1st);
    minY = marss.amplShowMin;
    maxY = marss.amplShowMax;
else                                    % automatic
    %--- init plot limits ---
    minX = 1e20;
    maxX = -1e20;
    minY = 1e20;
    maxY = -1e20;
    
    for bCnt = 1:nSuper
        [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppmZoom,specZoomReal(:,bCnt));
        minX = min([minX minX2]);
        maxX = max([maxX maxX2]);
        minY = min([minY minY2]);
        maxY = max([maxY maxY2]);
    end
end

%--- serial plot of individual traces ---
hold on
for bCnt = 1:nSuper
    %--- plot individual trace ---
    if flag.marssColorMap==0          % blue only
        plot(ppmZoom,specZoomReal(:,bCnt),'LineWidth',marss.lineWidth)
    else
        plot(ppmZoom,specZoomReal(:,bCnt),'LineWidth',marss.lineWidth,'Color',colorMat(bCnt,:))
    end
end
set(gca,'XDir','reverse')
% if flag.marssPpmShowPos
%     hold on
%     plot([marss.ppmShowPos marss.ppmShowPos],[minY maxY],'Color',[0 0 0])
%     hold off
% end
axis([minX maxX minY maxY])
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
if flag.marssLegend
    legCell = {};
    for bCnt = 1:nSuper
        if flag.marssShowSelAll                           % selected metabolites
            legCell{bCnt} = marss.basis.metabNames{marss.showSel(bCnt)};
        else                                            % all metabolites
            legCell{bCnt} = marss.basis.metabNames{bCnt};
        end
    end
    lh = legend(SP2_PrVersionUscoreCell(legCell));
    set(lh,'Location','Northwest')
end

%--- info printout ---
if f_new || flag.verbose
    fprintf('Display limits of superposition plot %s\n',SP2_Vec2PrintStr([minX maxX minY maxY],3,1));
end

%--- figure selection ---
flag.marssFigSelect = 2;

%--- update success flag ---
f_succ = 1;


end
