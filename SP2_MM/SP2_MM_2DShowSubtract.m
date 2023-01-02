%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_2DShowSubtract( f_new )
%%
%%  Plot subraction of selected spectra from last saturation-recovery experiment.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag

FCTNAME = 'SP2_MM_2DShowSubract';


%--- init success flag ---
f_done = 0;
%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhT1SpecSubract') || ~ishandle(mm.fhT1SpecSubract))
    return
end

%--- check data existence ---
if ~isfield(mm,'roi2D')
    fprintf('%s ->\nNo 2D selection found.\nAnalyze and define 2D selection first. Program aborted.\n',FCTNAME);
    return
end

%--- check data existence ---
if ~isfield(mm.roi2D,'roi')
    fprintf('%s ->\nNo 2D ROI found.\nAnalyze and define 2D ROI first. Program aborted.\n',FCTNAME);
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
if f_new && isfield(mm,'fhT1SpecSubract')
    if ishandle(mm.fhT1SpecSubract)
        delete(mm.fhT1SpecSubract)
    end
    data = rmfield(mm,'fhT1SpecSubract');
end
% create figure if necessary
if ~isfield(mm,'fhT1SpecSubract') || ~ishandle(mm.fhT1SpecSubract)
    mm.fhT1SpecSubract = figure('IntegerHandle','off');
    if flag.mmPpmShowPos
        set(mm.fhT1SpecSubract,'NumberTitle','off','Name',sprintf(' Multi-T1 Analysis: Longest saturation delay minus 2D T1/spectral selection (point %i, %.3f ppm)',mm.expPointSelect,mm.expPpmSelect),...
            'Position',[314 114 893 550],'Color',[1 1 1]);
    else
        set(mm.fhT1SpecSubract,'NumberTitle','off','Name',sprintf(' Multi-T1 Analysis: Longest saturation delay minus 2D T1/spectral selection'),...
            'Position',[314 114 893 550],'Color',[1 1 1]);
    end
else
    set(0,'CurrentFigure',mm.fhT1SpecSubract)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhT1SpecSubract)
            return
        end
    end
end
clf(mm.fhT1SpecSubract)

%--- spectrum subraction: longest saturation delay minus spectra selection ---
if flag.mmTOneSpline
    tOneSpecSubtract = real(sum(mm.t1spec,2)) - smooth(sum(mm.t1spec.*mm.roi2D.roi,2),7);
else
    tOneSpecSubtract = real(sum(mm.t1spec,2)) - sum(mm.t1spec.*mm.roi2D.roi,2);
end

%--- data extraction ---
if flag.mmFormat==1            % real part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,real(tOneSpecSubtract));
elseif flag.mmFormat==2        % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,imag(tOneSpecSubtract));
elseif flag.mmFormat==3        % magnitude mode
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,abs(tOneSpecSubtract));
else                                    % phase mode                                             
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,angle(tOneSpecSubtract));
end                                             
if ~f_succ
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data visualization ---
plot(ppmZoom,specZoom)
if flag.mmAmplShow              % automatic
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
else                            % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    minY = mm.amplShowMin;
    maxY = mm.amplShowMax;
end
if flag.mmPpmShowPos
    hold on
    plot([mm.ppmShowPos mm.ppmShowPos],[minY maxY],'Color',[0 0 0])
    hold off
end
set(gca,'XDir','reverse')
axis([minX maxX minY maxY])
xlabel('frequency [ppm]')

%--- export handling ---
mm.expt.fid    = ifft(ifftshift(tOneSpecSubtract,1),[],1);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;

%--- update success flag ---
f_done = 1;
