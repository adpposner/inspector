%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_SatRecShowSpecSum( f_new )
%%
%%  Plot sum of spectra from saturation-recovery experiment.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mm flag

FCTNAME = 'SP2_MM_SatRecShowSpecSum';


%--- init success flag ---
f_done = 0;
%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhSatRecSpecSum') || ~ishandle(mm.fhSatRecSpecSum))
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
if f_new && isfield(mm,'fhSatRecSpecSum')
    if ishandle(mm.fhSatRecSpecSum)
        delete(mm.fhSatRecSpecSum)
    end
    data = rmfield(mm,'fhSatRecSpecSum');
end
% create figure if necessary
if ~isfield(mm,'fhSatRecSpecSum') || ~ishandle(mm.fhSatRecSpecSum)
    mm.fhSatRecSpecSum = figure('IntegerHandle','off');
    set(mm.fhSatRecSpecSum,'NumberTitle','off','Name',sprintf(' Saturation-Recovery: Spectral Sum'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhSatRecSpecSum)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhSatRecSpecSum)
            return
        end
    end
end
clf(mm.fhSatRecSpecSum)

%--- spectrum summation ---
satRecSpecSum = sum(mm.spec(:,mm.satRecCons),2);

%--- data extraction ---
if flag.mmFormat==1            % real part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,real(satRecSpecSum));
elseif flag.mmFormat==2        % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,imag(satRecSpecSum));
elseif flag.mmFormat==3        % magnitude mode
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,abs(satRecSpecSum));
else                                    % phase mode                                             
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,angle(satRecSpecSum));
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
mm.expt.fid    = ifft(ifftshift(satRecSpecSum,1),[],1);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;

%--- update success flag ---
f_done = 1;
