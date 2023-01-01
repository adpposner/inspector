%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_2DShowAndDefine( f_new )
%%
%%  Manual selection/definition of spectral pattern of 2D T1-ppm image.
%% 
%%  06-2014, Christoph Juchem
%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_2DShowAndDefine';


%--- init success flag ---
f_done = 0;

% %--- figure handling: part 1 ---
% % potentially open new figure only if requested
% % (not if parameters are changed before a figure has been created)
% if ~isfield(mm,'fhT1Spec2D_Select') || ~ishandle(mm.fhT1Spec2D_Select)
%     return
% end

%--- check data existence ---
if ~isfield(mm,'spec')
    fprintf('%s ->\nNo saturation-recovery data set found.\nLoad/simulate first. Program aborted.\n',FCTNAME)
    return
end

%--- consistency check ---
if any(mm.tOneCons>size(mm.t1spec,2))
    fprintf('%s ->\nAt least one T1 component exceeds the number of fitted T1''s\n',FCTNAME)
    return
end

%--- ppm limit handling ---
if flag.mmPpmShow       % full sweep width (symmetry assumed)
    ppmMin = -mm.sw/2 + mm.ppmCalib;
    ppmMax = mm.sw/2  + mm.ppmCalib;
else                    % direct  
    ppmMin = mm.ppmShowMin;
    ppmMax = mm.ppmShowMax;
end

%--- figure handling: part 2 ---
% remove existing figure if new figure is forced
if isfield(mm,'fh2DSelect')
    if ishandle(mm.fh2DSelect)
        delete(mm.fh2DSelect)
    end
    data = rmfield(mm,'fh2DSelect');
end
% create figure if necessary
if ~isfield(mm,'fh2DSelect') || ~ishandle(mm.fh2DSelect)
    mm.fh2DSelect = figure('IntegerHandle','off');
    set(mm.fh2DSelect,'NumberTitle','off','Name',sprintf(' Multi-T1 Analysis: 2D Representation'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fh2DSelect)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fh2DSelect)
            return
        end
    end
end
clf(mm.fh2DSelect)

%--- index determination ---
[minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                             mm.sw,real(mm.t1spec(:,1)));

%--- data extraction ---
if flag.mmFormat==1            % real part
    specZoom = real(mm.t1spec(minI:maxI,mm.tOneCons));
elseif flag.mmFormat==2        % imaginary part
    specZoom = imag(mm.t1spec(minI:maxI,mm.tOneCons));
elseif flag.mmFormat==3        % magnitude mode
    specZoom = abs(mm.t1spec(minI:maxI,mm.tOneCons));
else                                    % phase mode                                             
    specZoom = angle(mm.t1spec(minI:maxI,mm.tOneCons));
end                                             

%--- matrix formating ---
specZoom = rot90(flipdim(flipdim(specZoom,2),1));

%--- 2D display ---
if flag.mmAmplShow
    imagesc(specZoom)
else
    imagesc(specZoom,[mm.amplShowMin mm.amplShowMax])
end
set(gca,'YTick',1:mm.anaTOneN,'YTickLabel',mm.anaTOne)
specLen   = maxI - minI + 1;          % spectral dimension
tickSpace = 0.1*round((maxI-minI+1)/(10*0.1));          % (9 or) 10 steps
nXTick    = floor(specLen/tickSpace);                   % label every 100 points
XTickVec  = tickSpace:tickSpace:nXTick*tickSpace;       % XTick vector
set(gca,'XTick',XTickVec,'XTickLabel',maxI-XTickVec+1)
xlabel('frequency [points]')
ylabel('T1 [sec]')

%--- visualize spectral position ---
if flag.mmPpmShowPos
    hold on
    plot([maxI-mm.expPointSelect+1 maxI-mm.expPointSelect+1],[0.5 length(mm.tOneCons)+0.5],'Color',[1 0 0])
    hold off
end

%--- extraction of 2D ROI ---
[mm.roi2D.maskPlot,mm.roi2D.x,mm.roi2D.y] = roipoly;
% rewind image orientation formatting
mm.roi2D.mask = permute(flipdim(flipdim(mm.roi2D.maskPlot,2),1),[2 1 3]);
mm.roi2D.n = length(find(mm.roi2D.mask));       % number of ROI voxels

%--- slice ROI assignment ---
mm.roi2D.roi = zeros(mm.nspecC,mm.anaTOneN);
mm.roi2D.roi(minI:maxI,mm.tOneCons) = flipdim(mm.roi2D.mask,2);     % note that this can be discontinous!

%--- superimpose selected T1/ppm region ---
hold on
% plot ROI trace to image
if flag.mmCMap==0           % blue   
    lh = plot(mm.roi2D.x,mm.roi2D.y,'w');
elseif flag.mmCMap==1       % gray
    lh = plot(mm.roi2D.x,mm.roi2D.y,'k');
elseif flag.mmCMap==2       % red
    lh = plot(mm.roi2D.x,mm.roi2D.y,'r');
else                        % yellow
    lh = plot(mm.roi2D.x,mm.roi2D.y,'y');
end
set(lh,'LineWidth',1.5)

% plot ROI area to image
if flag.mmCMap>0
    roiPatt    = double(mm.roi2D.maskPlot);
    roiPattCol = zeros(mm.anaTOneN,maxI-minI+1,3);
    if flag.mmCMap>1            % red & yellow
        roiPattCol(mm.tOneCons,:,1) = roiPatt;    % red/yellow (red channel)
        if flag.mmCMap==3       % yellow
            roiPattCol(mm.tOneCons,:,2) = roiPatt;    % yellow (green channel)
        end
    else                        % gray
        roiPattCol(mm.tOneCons,:,1) = 0.5*roiPatt;    % gray (red channel)
        roiPattCol(mm.tOneCons,:,2) = 0.5*roiPatt;    % gray (green channel)
        roiPattCol(mm.tOneCons,:,3) = 0.5*roiPatt;    % gray (blue channel)
    end
    image(roiPattCol,'AlphaData',0.3*roiPatt);
end
hold off

%--- add time axis ---
ppmVec  = (ppmMax-ppmMin)/(maxI-minI)*(0:(maxI-minI)) + ppmMin;
ppmStep = 0.1*round((ppmVec(end)-ppmVec(1))/(10*0.1));     % (9 or) 10 steps
ppmAxis = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
               'Color','none','XLim',[ppmMin ppmMax],'XDir','reverse',...
               'XTick',ppmMin:ppmStep:ppmMax,'YTick',[]);
xlabel('frequency [ppm]')

%--- ROI analysis ---
nTotal    = mm.nspecC*mm.anaTOneN;              % total number of points
nIn       = length(find(mm.roi2D.roi));         % number of points found
percIn    = nIn/nTotal * 100;                   % percentage of points contributing to the pattern

%--- info printout ---
fprintf('2D ROI vs. total: %.0f/%.0f = %.1f%%\n',nIn,nTotal,percIn)
fprintf('T1 range: [%.3f %.3f]s\n',mm.anaTOne(ceil(min(mm.roi2D.y))),mm.anaTOne(floor(max(mm.roi2D.y))))
fprintf('Spectral range: [%.3f %.3f]ppm / [%.0f %.0f]pts\n',...
        ppmMax - (ppmMax-ppmMin)/(maxI-minI)*(floor(min(mm.roi2D.x))-1),...
        ppmMax - (ppmMax-ppmMin)/(maxI-minI)*(ceil(max(mm.roi2D.x))-1),...
        maxI - ceil(max(mm.roi2D.x)),maxI - floor(min(mm.roi2D.x)))

%----------------------    
%--- ROI statistics ---
%----------------------
% basic center-of-mass
nPpm      = squeeze(sum(mm.roi2D.roi,2))';          % vector of ppm bins
nTOne     = squeeze(sum(mm.roi2D.roi,1));           % vector of T1 bins
comPpmPt  = nPpm*(1:mm.nspecC)'/sum(nPpm);          % ppm center-of-mass [points]
comTOnePt = nTOne*(1:mm.anaTOneN)'/sum(nTOne);      % T1 center-of-mass [points]
ppmVec    = -mm.sw/2+mm.ppmCalib:(mm.sw/(mm.nspecC-1)):mm.sw/2 + mm.ppmCalib;
comPpm    = SP2_BestApprox(ppmVec,1:mm.nspecC,comPpmPt);
comTOne   = SP2_BestApprox(mm.anaTOne,1:mm.anaTOneN,comTOnePt);
fprintf('Center-of-mass: %.3f ppm (point %.1f), T1 %.3f sec\n',comPpm,comPpmPt,comTOne)

% weighted center-of-mass
nPpm      = squeeze(sum(mm.t1spec.*mm.roi2D.roi,2))';   % vector of amplitude-weighted ppm bins
nTOne     = squeeze(sum(mm.t1spec.*mm.roi2D.roi,1));    % vector of amplitude-weighted T1 bins
comPpmPt  = nPpm*(1:mm.nspecC)'/sum(nPpm);              % ppm center-of-mass [points]
comTOnePt = nTOne*(1:mm.anaTOneN)'/sum(nTOne);          % T1 center-of-mass [points]
comPpm    = SP2_BestApprox(ppmVec,1:mm.nspecC,comPpmPt);
comTOne   = SP2_BestApprox(mm.anaTOne,1:mm.anaTOneN,comTOnePt);
fprintf('Weighted sum:   %.3f ppm (point %.1f), T1 %.3f sec\n',comPpm,comPpmPt,comTOne)

% straight maximum (amplitude) position
[maxPpmI,maxTOneI] = SP2_MaxMatInd(mm.t1spec.*mm.roi2D.roi);         % maximum search
comPpm    = SP2_BestApprox(ppmVec,1:mm.nspecC,maxPpmI);
comTOne   = SP2_BestApprox(mm.anaTOne,1:mm.anaTOneN,maxTOneI);
fprintf('Maximum ampl.:  %.3f ppm (point %.0f), T1 %.3f sec, amplitude %.1f\n',...
        comPpm,comPpmPt,comTOne,mm.t1spec(maxPpmI,maxTOneI))

%--- init success flag ---
f_done = 1;



