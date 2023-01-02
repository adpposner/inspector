%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_SatRecShowSpecArray( f_new )
%%
%%  Plot array of spectra from saturation-recovery experiment.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag

FCTNAME = 'SP2_MM_SatRecShowSpecArray';


%--- init success flag ---
f_done = 0;

%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhSatRecSpecArray') || ~ishandle(mm.fhSatRecSpecArray))
    return
end

%--- check data existence ---
if ~isfield(mm,'spec')
    fprintf('%s ->\nNo saturation-recovery data set found.\nLoad/simulate first. Program aborted.\n',FCTNAME);
    return
end

%--- consistency check ---
if any(mm.satRecCons>size(mm.spec,2))
    fprintf('%s ->\nAt least one delay exceeds the experiment dimension\n',FCTNAME);
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
if f_new && isfield(mm,'fhSatRecSpecArray')
    if ishandle(mm.fhSatRecSpecArray)
        delete(mm.fhSatRecSpecArray)
    end
    data = rmfield(mm,'fhSatRecSpecArray');
end
% create figure if necessary
if ~isfield(mm,'fhSatRecSpecArray') || ~ishandle(mm.fhSatRecSpecArray)
    mm.fhSatRecSpecArray = figure('IntegerHandle','off');
    set(mm.fhSatRecSpecArray,'NumberTitle','off','Name',sprintf(' Saturation-Recovery: Spectral Array'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhSatRecSpecArray)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhSatRecSpecArray)
            return
        end
    end
end
clf(mm.fhSatRecSpecArray)

%--- definition of color matrix ---
if flag.mmCMap==1
    colorMat = colormap(jet(mm.satRecConsN));
elseif flag.mmCMap==2
    colorMat = colormap(hsv(mm.satRecConsN));
elseif flag.mmCMap==3
    colorMat = colormap(hot(mm.satRecConsN));
end
cCnt = 1;       % init total/color counter

%--- determine appropriate subplot handling ---
spl      = ceil(sqrt(mm.satRecConsN));
NoResidD = mod(mm.satRecConsN,spl);     % spl = spectra per line
NoRowsD  = (mm.satRecConsN-NoResidD)/spl;
if NoRowsD*spl<mm.satRecConsN           % in rare cases an additional increase by one is required...
    NoRowsD = NoRowsD + 1;
end

%--- selected spectral series ---
for plCnt = 1:mm.satRecConsN
    subplot(NoRowsD,spl,plCnt);
    %--- data extraction: spectrum 1 ---
    if flag.mmFormat==1            % real part
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,real(mm.spec(:,mm.satRecCons(plCnt))));
    elseif flag.mmFormat==2        % imaginary part
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,imag(mm.spec(:,mm.satRecCons(plCnt))));
    elseif flag.mmFormat==3        % magnitude mode
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,abs(mm.spec(:,mm.satRecCons(plCnt))));
    else                                    % phase mode                                             
        [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                     mm.sw,angle(mm.spec(:,mm.satRecCons(plCnt))));
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
    set(gca,'XDir','reverse')
    if flag.mmAmplShow              % automatic
        [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
    else                            % direct
        [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
        minY = mm.amplShowMin;
        maxY = mm.amplShowMax;
    end
    axis([minX maxX minY maxY])
    title(sprintf('S-R Delay %.0f (%.3f s)',mm.satRecCons(plCnt),mm.satRecDelays(plCnt)))
    if plCnt==mm.satRecConsN
        xlabel('frequency [ppm]')
    end
end
    
%--- update success flag ---
f_done = 1;
