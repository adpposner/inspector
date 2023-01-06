%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_SatRecShowSpecSubtract( f_new )
%%
%%  Plot sum of spectra from saturation-recovery experiment.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_SatRecShowSpecSubtract';


%--- init success flag ---
f_done = 0;
%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && (~isfield(mm,'fhSatRecSpecDiff') || ~ishandle(mm.fhSatRecSpecDiff))
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
if f_new && isfield(mm,'fhSatRecSpecDiff')
    if ishandle(mm.fhSatRecSpecDiff)
        delete(mm.fhSatRecSpecDiff)
    end
    data = rmfield(mm,'fhSatRecSpecDiff');
end
% create figure if necessary
if ~isfield(mm,'fhSatRecSpecDiff') || ~ishandle(mm.fhSatRecSpecDiff)
    mm.fhSatRecSpecDiff = figure('IntegerHandle','off');
    set(mm.fhSatRecSpecDiff,'NumberTitle','off','Name',sprintf(' Saturation-Recovery: Spectral Sum'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhSatRecSpecDiff)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(mm.fhSatRecSpecDiff)
            return
        end
    end
end
clf(mm.fhSatRecSpecDiff)

%--- spectrum summation ---
satRecSpecDiff = mm.spec(:,end);        % init
for srCnt = 1:mm.satRecConsN
    satRecSpecDiff = satRecSpecDiff - mm.spec(:,mm.satRecCons(srCnt));
end

%--- data extraction ---
if flag.mmFormat==1            % real part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,real(satRecSpecDiff));
elseif flag.mmFormat==2        % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,imag(satRecSpecDiff));
elseif flag.mmFormat==3        % magnitude mode
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,abs(satRecSpecDiff));
else                                    % phase mode                                             
    [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_MM_ExtractPpmRange(ppmMin,ppmMax,mm.ppmCalib,...
                                                                 mm.sw,angle(satRecSpecDiff));
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
set(gca,'XDir','reverse')
axis([minX maxX minY maxY])
xlabel('frequency [ppm]')

%--- export handling ---
mm.expt.fid    = ifft(ifftshift(satRecSpecDiff,1),[],1);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;

%--- update success flag ---
f_done = 1;

end
