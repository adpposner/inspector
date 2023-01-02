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

global loggingfile mm flag

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
SP2_Check4ColVec(datFid)
if flag.mmAlignPhMode
    SP2_Check4ColVec(refFid)
end

%--- exponential line broadening for SNR improvement ---
lbWeight = exp(-mm.phAlignExpLb*mm.dwell*(0:mm.nspecC-1)*pi)';

%--- spectral FFT ---
datSpecOrig = fftshift(fft(datFid.*lbWeight,[],1),1);
if flag.mmAlignPhMode         
    datSpecRef = fftshift(fft(refFid.*lbWeight,[],1),1);
end

%--- spectral window extraction: full SW ---
[minIFull,maxIFull,ppmFull,specOrigFull,f_succ] = SP2_MM_ExtractPpmRange(-mm.sw/2+mm.ppmCalib,mm.sw/2+mm.ppmCalib,...
                                                        mm.ppmCalib,mm.sw,datSpecOrig);
if ~f_succ
    return
end

%--- spectral window extraction: up-field / 2 ppm ---
[minIUp,maxIUp,ppmUp,specOrigUp,f_succ] = SP2_MM_ExtractPpmRange(mm.phAlignPpmUpMin,mm.phAlignPpmUpMax,...
                                                        mm.ppmCalib,mm.sw,datSpecOrig);
if ~f_succ
    return
end

%--- spectral window extraction: down-field / 8 ppm ---
if flag.mmAlignPhSpecRg==1        % 2 spectral windows
    [minIDn,maxIDn,ppmDn,specOrigDn,f_succ] = SP2_MM_ExtractPpmRange(mm.phAlignPpmDnMin,mm.phAlignPpmDnMax,...
                                                            mm.ppmCalib,mm.sw,datSpecOrig);
    if ~f_succ
        return
    end
end

%--- phase optimization ---
phaseVec = 0:mm.phAlignPhStep:360;    % phase vector
nPhSteps = length(phaseVec);            % number of phasing steps
areaDn   = zeros(1,nPhSteps);           % vector of integrated down-field area
areaUp   = zeros(1,nPhSteps);           % vector of integrated up-field area
for phCnt = 1:nPhSteps
    specPhase = exp(1i*phaseVec(phCnt)*pi/180)*datSpecOrig;
    if flag.mmAlignPhMode         % congruency
        %--- congruency calculation ---
        if flag.mmAlignPhSpecRg==1        % 2 spectral windows 
            areaDn(phCnt) = sum(abs(real(specPhase(minIDn:maxIDn)-real(datSpecRef(minIDn:maxIDn)))));
        end
        areaUp(phCnt) = sum(abs(real(specPhase(minIUp:maxIUp)-real(datSpecRef(minIUp:maxIUp)))));

        %--- calculation of the optimization metric ---
        if flag.mmAlignPhSpecRg==1        % 2 spectral windows
            areaComb         = areaDn + areaUp;                 % combination of peak areas as measure for best phasing
            [optComb,optInd] = min(areaComb);                   % determination of optimal phase
            optPhase         = phaseVec(optInd);                % optimal phasing (output parameter)
        else                                % single (up-field) window only
            [optUp,optInd] = min(areaUp);                       % determination of optimal phase
            optPhase       = phaseVec(optInd);                  % optimal phasing (output parameter)
        end
    else                        % spectral integral
        %--- integral calculation ---
        if flag.mmAlignPhSpecRg==1        % 2 spectral windows 
            areaDn(phCnt) = sum(real(specPhase(minIDn:maxIDn)));
        end
        areaUp(phCnt) = sum(real(specPhase(minIUp:maxIUp)));

        %--- calculation of the optimization metric ---
        if flag.mmAlignPhSpecRg==1        % 2 spectral windows
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
end


%--- result visualization ---
if f_show
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
    if flag.mmAlignPhSpecRg==1        % 2 spectral windows
        subplot(4,1,1)
    else
        subplot(3,1,1)
    end
    hold on
    plot(ppmFull,real(specOrigFull(minIFull:maxIFull)))
    if flag.mmAlignPhMode         
        plot(ppmFull,real(datSpecRef(minIFull:maxIFull)),'r')
    end
    plot(ppmFull,real(specPhased(minIFull:maxIFull)),'g')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmFull,real(specOrigFull));
    [minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmFull,real(specPhased(minIFull:maxIFull)));
    if flag.mmAlignPhMode         
        [minX maxX minY(3) maxY(3)] = SP2_IdealAxisValues(ppmFull,real(datSpecRef));
    end
    minY = min(minY);
    maxY = max(maxY);
    if flag.mmAlignPhSpecRg==1        % 2 spectral windows
        plot([mm.phAlignPpmDnMin mm.phAlignPpmDnMin],[minY maxY],'Color',[0 0 0])
        plot([mm.phAlignPpmDnMax mm.phAlignPpmDnMax],[minY maxY],'Color',[0 0 0])
    end
    plot([mm.phAlignPpmUpMin mm.phAlignPpmUpMin],[minY maxY],'Color',[0 0 0])
    plot([mm.phAlignPpmUpMax mm.phAlignPpmUpMax],[minY maxY],'Color',[0 0 0])
    axis([minX maxX minY maxY])
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    if flag.mmAlignPhMode         
        legend('original','reference','phased')
    else
        legend('original','phased')
    end
    
    %--- quality measure ---
    if flag.mmAlignPhSpecRg==1        % 2 spectral windows
        subplot(4,1,2)
    else
        subplot(3,1,2)
    end
    hold on
    if flag.mmAlignPhSpecRg==1        % 2 spectral windows
        plot(phaseVec,areaComb)
        plot(phaseVec,areaComb,'*')
        plot(phaseVec(optInd),areaComb(optInd),'ro')
        [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(phaseVec,areaComb);
        ylabel('Combined Optimization Metric [a.u.]')
    else                                % single spectral window
        plot(phaseVec,areaUp)
        plot(phaseVec,areaUp,'*')
        plot(phaseVec(optInd),areaUp(optInd),'ro')
        [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(phaseVec,areaUp);
        ylabel('Single Optimization Metric [a.u.]')
    end
    hold off
    axis([minX maxX min(minY) max(maxY)])
    xlabel('Phase Shift [deg]')
    
    %--- zoom on selected spectral range (window 1) ---
    if flag.mmAlignPhSpecRg==1        % congruency && 2 spectral windows
        subplot(4,1,3)
    else
        subplot(3,1,3)
    end
    hold on
    plot(ppmUp,real(specOrigFull(minIUp:maxIUp)))
    if flag.mmAlignPhMode      
        plot(ppmUp,real(datSpecRef(minIUp:maxIUp)),'r')
    end
    plot(ppmUp,real(specPhased(minIUp:maxIUp)),'g')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmFull(minIUp:maxIUp),real(specOrigFull(minIUp:maxIUp)));
    [minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmFull(minIUp:maxIUp),real(specPhased(minIUp:maxIUp)));
    if flag.mmAlignPhMode      
        [minX maxX minY(3) maxY(3)] = SP2_IdealAxisValues(ppmFull(minIUp:maxIUp),real(datSpecRef(minIUp:maxIUp)));
    end
    axis([minX maxX min(minY) max(maxY)])
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
%     if flag.mmAlignPhMode         
%         legend('original','ref','phased')
%     else
%         legend('original','phased')
%     end
    
    %--- zoom on selected spectral range (window 2) ---
    if flag.mmAlignPhSpecRg==1        % congruency && 2 spectral windows
        subplot(4,1,4)
        hold on
        plot(ppmDn,real(specOrigFull(minIDn:maxIDn)))
        if flag.mmAlignPhMode      
            plot(ppmDn,real(datSpecRef(minIDn:maxIDn)),'r')
        end
        plot(ppmDn,real(specPhased(minIDn:maxIDn)),'g')
        [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmFull(minIDn:maxIDn),real(specOrigFull(minIDn:maxIDn)));
        [minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmFull(minIDn:maxIDn),real(specPhased(minIDn:maxIDn)));
        if flag.mmAlignPhMode      
            [minX maxX minY(3) maxY(3)] = SP2_IdealAxisValues(ppmFull(minIDn:maxIDn),real(datSpecRef(minIDn:maxIDn)));
        end
        axis([minX maxX min(minY) max(maxY)])
        hold off
        ylabel('Amplitude [a.u.]')
        xlabel('Frequency [ppm]')
        set(gca,'XDir','reverse')
%         if flag.mmAlignPhMode         
%             legend('original','ref','phased')
%         else
%             legend('original','phased')
%         end
    end

    %--- info printout ---
%     fprintf('%s done.\n',FCTNAME);
end

%--- update success flag ---
f_done = 1;
