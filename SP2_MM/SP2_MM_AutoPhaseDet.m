%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [optPhase,f_done] = SP2_MM_AutoPhaseDet(datFid,varargin)
%% 
%%  Automated determination of optimal zero order phasing based on multiple
%%  NAA peaks via
%%  1: maximization of real spectral range
%%  2: maximization of peak congruency with reference
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_AutoPhaseDet';


%--- init success flag ---
f_done = 0;


%--- verbose handling ---
f_show   = 0;           % default: no figure display
delayInd = 0;           % delay index (for figure label)
if nargin==2            % verbose flag
    f_show = SP2_Check4FlagR( varargin{1} );
elseif nargin==3        % delay display
    f_show   = SP2_Check4FlagR( varargin{1} );
    delayInd = SP2_Check4IntBigger0R( varargin{2} );
elseif nargin==4        % reference FID (for congruency mode)
    f_show   = SP2_Check4FlagR( varargin{1} );
    delayInd = SP2_Check4IntBigger0R( varargin{2} );
    refFid   = varargin{3};
elseif nargin~=1
    fprintf('%s ->\n%i function arguments are not supported. Program aborted.\n',FCTNAME,nargin);
    return
end

%--- consistency check ---
if ~SP2_Check4ColVec(datFid)
    return
end
if flag.mmAlignPhMode           % congruency
    if ~SP2_Check4ColVec(refFid)
        return
    end
end

%--- exponential line broadening for SNR improvement ---
lbWeight = exp(-mm.phAlignExpLb*mm.dwell*(0:mm.nspecC-1)*pi)';
datFid   = datFid.*lbWeight;
refFid   = refFid.*lbWeight;

%--- spectral FFT ---
datSpecOrig = fftshift(fft(datFid(1:mm.phAlignFftCut),mm.phAlignFftZf,1),1);
if flag.mmAlignPhMode           % congruency         
    datSpecRef = fftshift(fft(refFid(1:mm.phAlignFftCut),mm.phAlignFftZf,1),1);
end

%--- spectral window extraction: full SW ---
[minIFull,maxIFull,ppmFull,specOrigFull,f_succ] = SP2_MM_ExtractPpmRange(-mm.sw/2+mm.ppmCalib,mm.sw/2+mm.ppmCalib,...
                                                                         mm.ppmCalib,mm.sw,datSpecOrig);
if ~f_succ
    return
end

%--- extraction of spectral parts to be fitted ---
alignAllBin = zeros(1,mm.nspecC);           % init global index vector for ppm ranges to be used (binary format)
alignMinI   = zeros(1,mm.phAlignPpmN);            % init minimum ppm index vector
alignMaxI   = zeros(1,mm.phAlignPpmN);            % init maximum ppm index vector
for winCnt = 1:mm.phAlignPpmN
    [alignMinI(winCnt),alignMaxI(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_MM_ExtractPpmRange(mm.phAlignPpmMin(winCnt),mm.phAlignPpmMax(winCnt),...
                                 mm.ppmCalib,mm.sw,datSpecOrig);
    alignAllBin(alignMinI(winCnt):alignMaxI(winCnt)) = 1;
end
mm.phAlignAllInd = find(alignAllBin);             % global index vector including all ppm ranges

%--- phase optimization ---
phaseVec = 0:mm.phAlignPhStep:360;    % phase vector
nPhSteps = length(phaseVec);            % number of phasing steps
areaDn   = zeros(1,nPhSteps);           % vector of integrated down-field area
areaUp   = zeros(1,nPhSteps);           % vector of integrated up-field area
areaSum  = zeros(1,nPhSteps);           % vector of integrated area (new implementation)
if flag.mmAlignPhMode           % congruency
    for phCnt = 1:nPhSteps
        %--- phase value ---
        specPhase = exp(1i*phaseVec(phCnt)*pi/180)*datSpecOrig;

        %--- difference integration ---
        areaSum(phCnt) = sum(abs(real(specPhase(mm.phAlignAllInd)-real(datSpecRef(mm.phAlignAllInd)))));

    end
    
    %--- minimum determination ---
    [optUp,optInd] = min(areaSum);                          % determination of optimal phase
    optPhase       = phaseVec(optInd);                      % optimal phasing (output parameter)
else                        % spectral integral
    %--- integral calculation ---
    if flag.dataAlignPhSpecRg==1        % 2 spectral windows 
        areaDn(phCnt) = sum(real(specPhase(mm.phAlignAllInd)));
    end
    areaUp(phCnt) = sum(real(specPhase(mm.phAlignAllInd)));

    %--- calculation of the optimization metric ---
    if flag.dataAlignPhSpecRg==1        % 2 spectral windows
        areaComb         = areaDn .* areaUp;                % combination of peak areas as measure for best phasing
        doubleNegInd     = find(areaDn<0 & areaUp<0);       % both areas negative 
        areaComb(doubleNegInd) = -areaComb(doubleNegInd);   % invert to effectively discard (but keep in memory for visualization)
        [optComb,optInd] = max(areaComb);                   % determination of optimal phase
        optPhase         = phaseVec(optInd);                % optimal phasing (output parameter)
    else                                % single (up-field) window only
        [optUp,optInd] = max(areaUp);                       % determination of optimal phase
        optPhase       = phaseVec(optInd);                  % optimal phasing (output parameter)
    end
end


%--- result visualization ---
if f_show
    %--- zoomed window extension ---
    ppmExt = 0.1;       % 0.1 ppm, symmetric
    
    %--- calculate optimally phased spectrum ---
    specPhased = exp(1i*optPhase*pi/180)*datSpecOrig;

    %--- plot figure ---
    autoPhFh = figure('IntegerHandle','off');
    if delayInd>0
        titleStr = sprintf(' Automated Phase Alignment (delay #%.0f, %.3fs)',...
                           delayInd,mm.satRecDelays(delayInd));
    else
        titleStr = sprintf(' Automated Phase Alignment');
    end
    set(autoPhFh,'NumberTitle','off','Name',titleStr,...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
    %--- original and phased spectra ---
    subplot(3,1,1)
    hold on
    plot(ppmFull,real(specOrigFull(minIFull:maxIFull)))
    if flag.mmAlignPhMode           % congruency         
        plot(ppmFull,real(datSpecRef(minIFull:maxIFull)),'r')
    end
    plot(ppmFull,real(specPhased(minIFull:maxIFull)),'g')
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmFull,real(specOrigFull));
    axis([minX maxX minY maxY])
    yLim = get(gca,'YLim');
    for winCnt = 1:mm.phAlignPpmN
        plot([mm.phAlignPpmMin(winCnt) mm.phAlignPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
        plot([mm.phAlignPpmMax(winCnt) mm.phAlignPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
    end
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    if flag.mmAlignPhMode           % congruency         
        legend('original','reference','phased')
    else
        legend('original','phased')
    end
    
    %--- quality measure ---
    subplot(3,1,2)
    hold on
        plot(phaseVec,areaSum)
        plot(phaseVec,areaSum,'*')
        plot(phaseVec(optInd),areaSum(optInd),'ro')
        [minX maxX minY maxY] = SP2_IdealAxisValues(phaseVec,areaSum);
    hold off
    axis([minX maxX minY maxY])
    xlabel('Phase Shift [deg]')
    
    %--- zoom on selected spectral range ---
    subplot(3,1,3)
    % spectral window extraction: full SW of reference spectrum ---
    %--- spectral window extraction: reference spectrum (display) ---
    [minI,maxI,ppmZoomDisplay,specRefZoomDisplay,f_succ] = SP2_MM_ExtractPpmRange(min(mm.phAlignPpmMin)-ppmExt,max(mm.phAlignPpmMax)+ppmExt,...
                                                                       mm.ppmCalib,mm.sw,real(datSpecRef));
    if ~f_succ
        return
    end
    hold on
    plot(ppmFull(minI:maxI),real(specOrigFull(minI:maxI)))
    plot(ppmFull(minI:maxI),real(specPhased(minI:maxI)),'g')
    if flag.mmAlignPhMode           % congruency      
        plot(ppmFull(minI:maxI),real(datSpecRef(minI:maxI)),'r')
    end
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmFull(minI:maxI),real(specOrigFull(minI:maxI)));
    [minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmFull(minI:maxI),real(specPhased(minI:maxI)));
    if flag.mmAlignPhMode           % congruency      
        [minX maxX minY(3) maxY(3)] = SP2_IdealAxisValues(ppmFull(minI:maxI),real(datSpecRef(minI:maxI)));
    end
    minY = min(minY);
    maxY = max(maxY);
    axis([minX maxX minY maxY])
    yLim = get(gca,'YLim');
    for winCnt = 1:mm.phAlignPpmN
        plot([mm.phAlignPpmMin(winCnt) mm.phAlignPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
        plot([mm.phAlignPpmMax(winCnt) mm.phAlignPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[1 0.25 1])
    end
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')

    %--- info printout ---
%     fprintf('%s done.\n',FCTNAME);
end

%--- update success flag ---
f_done = 1;
