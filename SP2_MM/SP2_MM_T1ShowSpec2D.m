%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_T1ShowSpec2D( f_new )
%%
%%  Plot 2D representation of T1 analysis.
%% 
%%  05-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_T1ShowSpec2D';


%--- init success flag ---
f_done = 0;

%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhT1Spec2D') || ~ishandle(mm.fhT1Spec2D))
    return
end

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
if f_new && isfield(mm,'fhT1Spec2D')
    if ishandle(mm.fhT1Spec2D)
        delete(mm.fhT1Spec2D)
    end
    data = rmfield(mm,'fhT1Spec2D');
end
% create figure if necessary
if ~isfield(mm,'fhT1Spec2D') || ~ishandle(mm.fhT1Spec2D)
    mm.fhT1Spec2D = figure('IntegerHandle','off');
    set(mm.fhT1Spec2D,'NumberTitle','off','Name',sprintf(' Multi-T1 Analysis: 2D Representation'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhT1Spec2D)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhT1Spec2D)
            return
        end
    end
end
clf(mm.fhT1Spec2D)

%--- index determination ---
[minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                             mm.sw,real(mm.t1spec(:,1)));

% %--- data extraction ---
% if flag.mmFormat==1            % real part
%     specZoom = real(mm.t1spec(minI:maxI,mm.tOneCons));
% elseif flag.mmFormat==2        % imaginary part
%     specZoom = imag(mm.t1spec(minI:maxI,mm.tOneCons));
% elseif flag.mmFormat==3        % magnitude mode
%     specZoom = abs(mm.t1spec(minI:maxI,mm.tOneCons));
% else                                    % phase mode                                             
%     specZoom = angle(mm.t1spec(minI:maxI,mm.tOneCons));
% end        
%--- data extraction ---
if flag.mmFormat==1            % real part
    specZoom = real(mm.t1spec(minI:maxI,:));
elseif flag.mmFormat==2        % imaginary part
    specZoom = imag(mm.t1spec(minI:maxI,:));
elseif flag.mmFormat==3        % magnitude mode
    specZoom = abs(mm.t1spec(minI:maxI,:));
else                                    % phase mode                                             
    specZoom = angle(mm.t1spec(minI:maxI,:));
end                                             

%--- matrix formating ---
specZoom = rot90(flipdim(flipdim(specZoom,2),1));

%--- 2D display ---
if flag.mmAmplShow
    %--- display ---
    imagesc(specZoom)
    
    %--- info printout ---
    if f_new
        fprintf('2D matrix: min %.0f, max %.0f\n',min(min(specZoom)),max(max(specZoom)))
    end
else
    imagesc(specZoom,[mm.amplShowMin mm.amplShowMax])
end
set(gca,'YTick',1:mm.anaTOneN,'YTickLabel',mm.anaTOne)
specLen   = maxI - minI + 1;          % spectral dimension
tickSpace = 0.1*round((maxI-minI+1)/(8*0.1));          % (7 or) 8 steps
nXTick    = floor(specLen/tickSpace);                   % label every 100 points
XTickVec  = tickSpace:tickSpace:nXTick*tickSpace;       % XTick vector
set(gca,'XTick',XTickVec,'XTickLabel',maxI-XTickVec+1)
xlabel('frequency [points]')
ylabel('T1 [sec]')

%--- visualize spectral position ---
if flag.mmPpmShowPos
    hold on
    plot([maxI-mm.expPointSelect+1 maxI-mm.expPointSelect+1],[0.5 size(specZoom,1)+0.5],'Color',[1 0 0])
    hold off
end

%--- add time axis ---
ppmVec  = (ppmMax-ppmMin)/(maxI-minI)*(0:(maxI-minI)) + ppmMin;
ppmStep = 0.1*round((ppmVec(end)-ppmVec(1))/(8*0.1));     % (7 or) 8 steps
ppmStep = 0.5;
ppmAxis = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
               'Color','none','XLim',[ppmMin ppmMax],'XDir','reverse',...
               'XTick',ppmMin:ppmStep:ppmMax,'YTick',[]);
xlabel('frequency [ppm]')


%--- visualize spectral position ---
if flag.mmPpmShowPos
    hold on
%     plot([maxI-mm.expPointSelect+1 maxI-mm.expPointSelect+1],[0.5 length(mm.tOneCons)+0.5],'Color',[1 0 0])
    plot([maxI-mm.expPointSelect+1 maxI-mm.expPointSelect+1],[0.5 mm.anaTOneN+0.5],'Color',[1 0 0])
    hold off
end

%--- update success flag ---
f_done = 1;
