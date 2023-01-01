%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_T1ShowSpecArray( f_new )
%%
%%  Plot array of spectra from saturation-recovery experiment.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_T1ShowSpecArray';


%--- init success flag ---
f_done = 0;

%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhT1SpecArray') || ~ishandle(mm.fhT1SpecArray))
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
    fprintf('Total number of T1 components: %.0f\n',size(mm.t1spec,2))
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
if f_new && isfield(mm,'fhT1SpecArray')
    if ishandle(mm.fhT1SpecArray)
        delete(mm.fhT1SpecArray)
    end
    data = rmfield(mm,'fhT1SpecArray');
end
% create figure if necessary
if ~isfield(mm,'fhT1SpecArray') || ~ishandle(mm.fhT1SpecArray)
    mm.fhT1SpecArray = figure('IntegerHandle','off');
    set(mm.fhT1SpecArray,'NumberTitle','off','Name',sprintf(' Saturation-Recovery: Spectral Array'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhT1SpecArray)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhT1SpecArray)
            return
        end
    end
end
clf(mm.fhT1SpecArray)

%--- definition of color matrix ---
if flag.mmCMap==1
    colorMat = colormap(jet(mm.tOneConsN));
elseif flag.mmCMap==2
    colorMat = colormap(hsv(mm.tOneConsN));
elseif flag.mmCMap==3
    colorMat = colormap(hot(mm.tOneConsN));
end
cCnt = 1;       % init total/color counter

%--- determine appropriate subplot handling ---
spl      = ceil(sqrt(mm.tOneConsN));
NoResidD = mod(mm.tOneConsN,spl);     % spl = spectra per line
NoRowsD  = (mm.tOneConsN-NoResidD)/spl;
if NoRowsD*spl<mm.tOneConsN           % in rare cases an additional increase by one is required...
    NoRowsD = NoRowsD + 1;
end

%--- selected spectral series ---
for plCnt = 1:mm.tOneConsN
    subplot(NoRowsD,spl,plCnt);
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
        fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
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
    set(gca,'XDir','reverse')
    if flag.mmAmplShow              % automatic
        [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
    else                            % direct
        [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
        minY = mm.amplShowMin;
        maxY = mm.amplShowMax;
    end
    axis([minX maxX minY maxY])
    title(sprintf('T1  #%.0f (%.3f s)',mm.tOneCons(plCnt),mm.anaTOne(plCnt)))
    if plCnt==mm.tOneConsN
        xlabel('frequency [ppm]')
    end
end
    
%--- update success flag ---
f_done = 1;
