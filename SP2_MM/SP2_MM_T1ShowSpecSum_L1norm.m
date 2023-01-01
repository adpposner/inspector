%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_T1ShowSpecSum_L1norm( f_new )
%%
%%  Plot sum of spectra from saturation-recovery experiment.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_T1ShowSpecSum_L1norm';


%--- init success flag ---
f_done = 0;
%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhT1SpecSum') || ~ishandle(mm.fhT1SpecSum))
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
if f_new && isfield(mm,'fhT1SpecSum')
    if ishandle(mm.fhT1SpecSum)
        delete(mm.fhT1SpecSum)
    end
    data = rmfield(mm,'fhT1SpecSum');
end
% create figure if necessary
if ~isfield(mm,'fhT1SpecSum') || ~ishandle(mm.fhT1SpecSum)
    mm.fhT1SpecSum = figure('IntegerHandle','off');
    set(mm.fhT1SpecSum,'NumberTitle','off','Name',sprintf(' Multi-T1 Analysis: Spectral Sum'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhT1SpecSum)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhT1SpecSum)
            return
        end
    end
end
clf(mm.fhT1SpecSum)

%--- spectrum summation ---
% tOneSpecSum = sum(mm.t1spec(:,mm.tOneCons),2);

%--- T1-based data extraction ---
% values to be excluded
nonInd = find(mm.l1normBestT<mm.anaTOneFlexThMin);
mmT1spec = mm.t1spec;           % local copy
mmT1spec(nonInd) = 0;           % reset non-relevant entries
tOneSpecSum = sum(mmT1spec,2);  % collapse all time constants

%--- data extraction ---
if flag.mmFormat==1            % real part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,real(tOneSpecSum));
elseif flag.mmFormat==2        % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,imag(tOneSpecSum));
elseif flag.mmFormat==3        % magnitude mode
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,abs(tOneSpecSum));
else                                    % phase mode                                             
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,angle(tOneSpecSum));
end                                             
if ~f_succ
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- spline interpolation ---
if flag.mmTOneSpline
    specZoom = smooth(specZoom,40);
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
mm.expt.fid    = ifft(ifftshift(tOneSpecSum,1),[],1);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;

%--- update success flag ---
f_done = 1;
