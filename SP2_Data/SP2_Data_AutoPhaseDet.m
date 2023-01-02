%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [optPhase,f_succ] = SP2_Data_AutoPhaseDet(datFid,refFid,pars,phAlignPpmMin,phAlignPpmMax,infoStr,f_show)
%% 
%%  Automated determination of optimal zero order phasing based on multiple
%%  NAA peaks via
%%  1: maximization of real spectral range
%%  2: maximization of peak congruency with reference
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data flag

FCTNAME = 'SP2_Data_AutoPhaseDet';


%--- init success flag ---
f_succ = 0;

%--- verbose handling ---
if nargin~=7
    fprintf('%s ->\n%i function arguments are not supported. Program aborted.\n',FCTNAME,nargin);
    return
end

%--- consistency check ---
if ~SP2_Check4ColVec(datFid)
    return
end
if ~SP2_Check4ColVec(refFid)
    return
end

%--- parameter handling ---
phAlignPpmN = length(phAlignPpmMin);
if length(phAlignPpmMax)~=phAlignPpmN
    fprintf('Inconsistent PPM window dimension detected (Min %.0f ~= Max %.0f).\nProgram aborted.\n',...
            length(phAlignPpmMin),length(phAlignPpmMax))
    return
end

%--- exponential line broadening for SNR improvement ---
lbWeight = exp(-data.phAlignExpLb*pars.dwell*(0:data.spec1.nspecC-1)*pi)';
datFid   = datFid.*lbWeight;
refFid   = refFid.*lbWeight;

%--- spectral FFT ---
if data.phAlignFftCut<data.spec1.nspecC
    datSpecOrig = fftshift(fft(datFid(1:data.phAlignFftCut),data.phAlignFftZf,1),1);
    datSpecRef = fftshift(fft(refFid(1:data.phAlignFftCut),data.phAlignFftZf,1),1);
else
    datSpecOrig = fftshift(fft(datFid,data.phAlignFftZf,1),1);
    datSpecRef = fftshift(fft(refFid,data.phAlignFftZf,1),1);
end

%--- spectral window extraction: full SW ---
[minIFull,maxIFull,ppmFull,specOrigFull,f_succ] = SP2_Data_ExtractPpmRange(-pars.sw/2+data.ppmCalib,pars.sw/2+data.ppmCalib,...
                                                        data.ppmCalib,pars.sw,datSpecOrig);
if ~f_succ
    return
end

%--- extraction of spectral parts to be fitted ---
alignAllBin = zeros(1,data.spec1.nspecC);           % init global loggingfile index vector for ppm ranges to be used (binary format)
alignMinI   = zeros(1,phAlignPpmN);            % init minimum ppm index vector
alignMaxI   = zeros(1,phAlignPpmN);            % init maximum ppm index vector
for winCnt = 1:phAlignPpmN
    [alignMinI(winCnt),alignMaxI(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_Data_ExtractPpmRange(phAlignPpmMin(winCnt),phAlignPpmMax(winCnt),...
                                 data.ppmCalib,data.spec1.sw,datSpecOrig);
    if ~f_done
        fprintf('\n%s ->\nPhase window extraction failed for section #2 (%.2f-%.2f ppm). Program aborted.\n',...
                winCnt,frAlignPpmMin(winCnt),frAlignPpmMax(winCnt))
        return
    end
    alignAllBin(alignMinI(winCnt):alignMaxI(winCnt)) = 1;
end
data.phAlignAllInd = find(alignAllBin);             % global loggingfile index vector including all ppm ranges

%--- phase optimization ---
phaseVec = 0:data.phAlignPhStep:360;    % phase vector
nPhSteps = length(phaseVec);            % number of phasing steps
areaDn   = zeros(1,nPhSteps);           % vector of integrated down-field area
areaUp   = zeros(1,nPhSteps);           % vector of integrated up-field area
areaSum  = zeros(1,nPhSteps);           % vector of integrated area (new implementation)
for phCnt = 1:nPhSteps
    %--- phase value ---
    specPhase = exp(1i*phaseVec(phCnt)*pi/180)*datSpecOrig;

    %--- difference integration ---
    areaSum(phCnt) = sum(abs(real(specPhase(data.phAlignAllInd)-real(datSpecRef(data.phAlignAllInd)))));

end

%--- minimum determination ---
[optUp,optInd] = min(areaSum);                          % determination of optimal phase
optPhase       = phaseVec(optInd);                      % optimal phasing (output parameter)


%--- result visualization ---
if f_show
    %--- zoomed window extension ---
    ppmExt = 0.1;       % 0.1 ppm, symmetric
    
    %--- calculate optimally phased spectrum ---
    specPhased = exp(1i*optPhase*pi/180)*datSpecOrig;

    %--- plot figure ---
    autoPhFh = figure('IntegerHandle','off');
    set(autoPhFh,'NumberTitle','off','Name',sprintf(' Automated Phase Alignment (%s): %.1f deg',infoStr,optPhase),...
        'Position',[378 -2 769 850],'Color',[1 1 1],'Tag','AlignQA');
    %--- original and phased spectra ---
    subplot(3,1,1)
    hold on
    plot(ppmFull,real(specOrigFull(minIFull:maxIFull)))
    plot(ppmFull,real(datSpecRef(minIFull:maxIFull)),'r')
    plot(ppmFull,real(specPhased(minIFull:maxIFull)),'g')
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmFull,real(specOrigFull));
    if maxX>minX && maxY>minY && ~any(isnan([minX maxX minY maxY]))
        axis([minX maxX minY maxY])
    else
        fprintf('\n\nWARNING: Phase alignment failed! (global loggingfile display)\n');
        fprintf('[minX maxX minY maxY] = [%.1f %.1f %.1f %.1f]\n\n',minX,maxX,minY,maxY);
    end
    yLim = get(gca,'YLim');
    for winCnt = 1:phAlignPpmN
        plot([phAlignPpmMin(winCnt) phAlignPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
        plot([phAlignPpmMax(winCnt) phAlignPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
    end
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    legend('original','reference','phased')
    
    %--- quality measure ---
    subplot(3,1,2)
    hold on
        plot(phaseVec,areaSum)
        plot(phaseVec,areaSum,'*')
        plot(phaseVec(optInd),areaSum(optInd),'ro')
        [minX maxX minY maxY] = SP2_IdealAxisValues(phaseVec,areaSum);
    hold off
    if maxX>minX && maxY>minY && ~any(isnan([minX maxX minY maxY]))
        axis([minX maxX minY maxY])
    else
        fprintf('\n\nWARNING: Phase alignment failed! (optimization display)\n');
        fprintf('[minX maxX minY maxY] = [%.1f %.1f %.1f %.1f]\n\n',minX,maxX,minY,maxY);
    end
    ylabel('Difference Integral [a.u.]')
    xlabel('Phase Shift [deg]')
    
    %--- zoom on selected spectral range ---
    subplot(3,1,3)
    % spectral window extraction: full SW of reference spectrum ---
    %--- spectral window extraction: reference spectrum (display) ---
    [minI,maxI,ppmZoomDisplay,specRefZoomDisplay,f_succ] = SP2_Data_ExtractPpmRange(min(phAlignPpmMin)-ppmExt,max(phAlignPpmMax)+ppmExt,...
                                                                       data.ppmCalib,pars.sw,real(datSpecRef));
    if ~f_succ
        return
    end
    hold on
    plot(ppmFull(minI:maxI),real(specOrigFull(minI:maxI)))
    plot(ppmFull(minI:maxI),real(specPhased(minI:maxI)),'g')
    plot(ppmFull(minI:maxI),real(datSpecRef(minI:maxI)),'r')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmFull(minI:maxI),real(specOrigFull(minI:maxI)));
    [minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmFull(minI:maxI),real(specPhased(minI:maxI)));
    [minX maxX minY(3) maxY(3)] = SP2_IdealAxisValues(ppmFull(minI:maxI),real(datSpecRef(minI:maxI)));
    minY = min(minY);
    maxY = max(maxY);
    if maxX>minX && maxY>minY && ~any(isnan([minX maxX minY maxY]))
        axis([minX maxX minY maxY])
    else
        fprintf('\n\nWARNING: Phase alignment failed! (zoomed display)\n');
        fprintf('[minX maxX minY maxY] = [%.1f %.1f %.1f %.1f]\n\n',minX,maxX,minY,maxY);
    end
    yLim = get(gca,'YLim');
    for winCnt = 1:phAlignPpmN
        plot([phAlignPpmMin(winCnt) phAlignPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
        plot([phAlignPpmMax(winCnt) phAlignPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
    end
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')

    %--- info printout ---
    % fprintf('%s done.\n',FCTNAME);
end

%--- update success flag ---
f_succ = 1;
