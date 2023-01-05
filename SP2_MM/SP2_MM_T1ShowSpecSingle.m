%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_T1ShowSpecSingle( f_new )
%%
%%  Plot spectrum of selected T1 component.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_T1ShowSpecSingle';


%--- break condition ---
if ~f_new && (~isfield(mm,'fhT1SpecSingle') || ~ishandle(mm.fhT1SpecSingle))
    return
end

%--- check data existence ---
if ~isfield(mm,'t1spec')
    if f_new        % intention to display -> load data
        fprintf('%s ->\nNo T1 compents found. Run analysis first.\n',FCTNAME);
    end
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
if mm.tOneSelect>size(mm.t1spec,2)
    fprintf('%s ->\nSelected saturation-recovery delay exceeds total number of available timings. Program aborted.\n',FCTNAME);
    return
end

%--- data extraction: spectrum 1 ---
if flag.mmFormat==1           % real part
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,real(mm.t1spec(:,mm.tOneSelect)));
elseif flag.mmFormat==2       % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,imag(mm.t1spec(:,mm.tOneSelect)));
elseif flag.mmFormat==3       % magnitude
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,abs(mm.t1spec(:,mm.tOneSelect)));
else                            % phase
    [minI,maxI,ppmZoom,specZoom,f_done] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,angle(mm.t1spec(:,mm.tOneSelect)));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mm,'fhT1SpecSingle') && ~flag.mmKeepFig
    if ishandle(mm.fhT1SpecSingle)
        delete(mm.fhT1SpecSingle)
    end
    mm = rmfield(mm,'fhT1SpecSingle');
end
% create figure if necessary
if ~isfield(mm,'fhT1SpecSingle') || ~ishandle(mm.fhT1SpecSingle)
    mm.fhT1SpecSingle = figure('IntegerHandle','off');
    set(mm.fhT1SpecSingle,'NumberTitle','off','Name',sprintf(' Selected T1 Component'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhT1SpecSingle)
    if flag.mmKeepFig
        if ~SP2_KeepFigure(mm.fhT1SpecSingle)
            return
        end
    end
end
clf(mm.fhT1SpecSingle)

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
title(sprintf('T1 %.3f sec',mm.anaTOne(mm.tOneSelect)))

%--- export handling ---
mm.expt.fid    = ifft(ifftshift(mm.t1spec(:,mm.tOneSelect),1),[],1);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;



