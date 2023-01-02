%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SatRecShowSpecSingle( f_new )
%%
%%  Plot spectrum of selected saturation-recovery time point.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag

FCTNAME = 'SP2_MM_SatRecShowSpecSingle';


%--- break condition ---
if ~f_new && (~isfield(mm,'fhSatRecSpecSingle') || ~ishandle(mm.fhSatRecSpecSingle))
    return
end

%--- check data existence ---
if ~isfield(mm,'spec')
    fprintf('%s ->\nNo saturation-recovery data set found.\nLoad/simulate first. Program aborted.\n',FCTNAME);
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

%--- consistency check ---
if mm.satRecSelect>size(mm.spec,2)
    fprintf('%s ->\nSelected saturation-recovery delay exceeds total number of available timings. Program aborted.\n',FCTNAME);
    return
end

%--- data extraction: spectrum 1 ---
if flag.mmFormat==1           % real part
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,real(mm.spec(:,mm.satRecSelect)));
elseif flag.mmFormat==2       % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,imag(mm.spec(:,mm.satRecSelect)));
elseif flag.mmFormat==3       % magnitude
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,abs(mm.spec(:,mm.satRecSelect)));
else                            % phase
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,angle(mm.spec(:,mm.satRecSelect)));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mm,'fhSatRecSpecSingle') && ~flag.mmKeepFig
    if ishandle(mm.fhSatRecSpecSingle)
        delete(mm.fhSatRecSpecSingle)
    end
    mm = rmfield(mm,'fhSatRecSpecSingle');
end
% create figure if necessary
if ~isfield(mm,'fhSatRecSpecSingle') || ~ishandle(mm.fhSatRecSpecSingle)
    mm.fhSatRecSpecSingle = figure('IntegerHandle','off');
    set(mm.fhSatRecSpecSingle,'NumberTitle','off','Name',sprintf(' Selected Saturation-Recovery Spectrum'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhSatRecSpecSingle)
    if flag.mmKeepFig
        if ~SP2_KeepFigure(mm.fhSatRecSpecSingle)
            return
        end
    end
end
clf(mm.fhSatRecSpecSingle)

%--- data visualization ---
% plot(ppmZoom,specZoom,'LineWidth',2)
plot(ppmZoom,specZoom)
set(gca,'XDir','reverse')
if flag.mmAmplShow          % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
else                        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    plotLim(3) = mm.amplShowMin;
    plotLim(4) = mm.amplShowMax;
end
if flag.mmPpmShowPos
    hold on
    plot([mm.ppmShowPos mm.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
if flag.mmFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')
title(sprintf('Spectrum %.0f (%.3f s)',mm.satRecSelect,mm.satRecDelays(mm.satRecSelect)))

%--- export handling ---
mm.expt.fid    = ifft(ifftshift(mm.spec(:,mm.satRecSelect),1),[],1);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;



