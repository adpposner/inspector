%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_T1ShowSpecSuper( f_new )
%%
%%  Plot superposition of spectra from saturation-recovery experiment.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_T1ShowSpecSuper';


%--- init success flag ---
f_done = 0;

%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhT1SpecSuper') || ~ishandle(mm.fhT1SpecSuper))
    return
end

%--- check data existence ---
if ~isfield(mm,'t1spec')
    fprintf('%s ->\nNo saturation-recovery data set found.\nLoad/simulate first. Program aborted.\n',FCTNAME);
    return
end

%--- consistency check ---
if any(mm.tOneCons>size(mm.t1spec,2))
    fprintf('%s ->\nAt least one T1 component exceeds the number of fitted T1''s\n',FCTNAME);
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
if f_new && isfield(mm,'fhT1SpecSuper')
    if ishandle(mm.fhT1SpecSuper)
        delete(mm.fhT1SpecSuper)
    end
    data = rmfield(mm,'fhT1SpecSuper');
end
% create figure if necessary
if ~isfield(mm,'fhT1SpecSuper') || ~ishandle(mm.fhT1SpecSuper)
    mm.fhT1SpecSuper = figure('IntegerHandle','off');
    set(mm.fhT1SpecSuper,'NumberTitle','off','Name',sprintf(' Saturation-Recovery: Spectra Superposition'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhT1SpecSuper)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhT1SpecSuper)
            return
        end
    end
end
clf(mm.fhT1SpecSuper)

%--- definition of color matrix ---
if flag.mmCMap==1
    colorMat = colormap(jet(mm.tOneConsN));
elseif flag.mmCMap==2
    colorMat = colormap(hsv(mm.tOneConsN));
elseif flag.mmCMap==3
    colorMat = colormap(hot(mm.tOneConsN));
end
cCnt = 1;       % init total/color counter

%--- plot spectra ---
hold on
for plCnt = 1:mm.tOneConsN
    %--- data extraction: spectrum 1 ---
    if flag.mmFormat==1            % real part
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,real(mm.t1spec(:,mm.tOneCons(plCnt))));
    elseif flag.mmFormat==2        % imaginary part
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,imag(mm.t1spec(:,mm.tOneCons(plCnt))));
    elseif flag.mmFormat==3        % magnitude mode
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,abs(mm.t1spec(:,mm.tOneCons(plCnt))));
    else                                    % phase mode                                             
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,angle(mm.t1spec(:,mm.tOneCons(plCnt))));
    end                                             
    if ~f_succ
        fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
        return
    end

    %--- data visualization ---
    if flag.mmCMap>0
        plot(ppmZoom,specZoom,'Color',colorMat(cCnt,:))
%             plot(ppmZoom,specZoom,'Color',colorMat(cCnt,:),'LineWidth',2)
        cCnt = cCnt + 1;    % update serial/color counter
    else
        plot(ppmZoom,specZoom)
    end
    if flag.mmAmplShow              % automatic
        [minX maxX minY(plCnt) maxY(plCnt)] = SP2_IdealAxisValues(ppmZoom,specZoom);
    end
end
set(gca,'XDir','reverse')
if flag.mmAmplShow              % automatic
    minY = min(minY);
    maxY = max(maxY);
else                            % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    minY = mm.amplShowMin;
    maxY = mm.amplShowMax;
end
axis([minX maxX minY maxY])
if flag.mmPpmShowPos
    hold on
    plot([mm.ppmShowPos mm.ppmShowPos],[minY maxY],'Color',[0 0 0])
    hold off
end
xlabel('frequency [ppm]')
if flag.mmCMapLegend
    legCell = {};
    for plCnt = 1:mm.tOneConsN
        legCell{plCnt} = sprintf('#%.0f, %.3fs',mm.tOneCons(plCnt),...
                                 mm.anaTOne(mm.tOneCons(plCnt)));
    end
    legend(legCell)
end

%--- update success flag ---
f_done = 1;

end
