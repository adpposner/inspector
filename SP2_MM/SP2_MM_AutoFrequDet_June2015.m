%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [optFrequ,f_done] = SP2_MM_AutoFrequDet(datFid,datFidRef,varargin)
%% 
%%  Automated determination of optimal frequency shift to align a spectra
%%  with a reference.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm

FCTNAME = 'SP2_MM_AutoFrequDet';


%--- init success flag ---
f_done = 0;

%--- verbose handling ---
f_show   = 0;       % default: no figure display
delayInd = 0;       % delay index (for figure label)
if nargin==3        % verbose flag
    f_show = SP2_Check4FlagR( varargin{1} );
elseif nargin==4        % verbose flag
    f_show   = SP2_Check4FlagR( varargin{1} );
    delayInd = SP2_Check4IntBigger0R( varargin{2} );
elseif nargin~=2
    fprintf('%s ->\n%i function arguments are not supported. Program aborted.\n',FCTNAME,nargin)
    return
end

%--- consistency check ---
SP2_Check4ColVec(datFid)
SP2_Check4ColVec(datFidRef)

%--- exponential line broadening for SNR improvement ---
lbWeight  = exp(-mm.frAlignExpLb*mm.dwell*(0:mm.nspecC-1)*pi)';
datFid    = datFid.*lbWeight;
datFidRef = datFidRef.*lbWeight;

%--- spectral FFT ---
if f_show
    datSpecOrig = fftshift(fft(datFid(1:mm.frAlignFftCut),mm.frAlignFftZf,1),1);
end
datSpecRef  = fftshift(fft(datFidRef(1:mm.frAlignFftCut),mm.frAlignFftZf,1),1);

if f_show
    %--- spectral window extraction: full SW of original spectrum ---
    [minIFull,maxIFull,ppmFull,specOrigFull,f_succ] = SP2_Data_ExtractPpmRange(-mm.sw/2+mm.ppmCalib,mm.sw/2+mm.ppmCalib,...
                                                            mm.ppmCalib,mm.sw,abs(datSpecOrig));
    if ~f_succ
        return
    end

    %--- spectral window extraction: full SW of reference spectrum ---
    [minIFull,maxIFull,ppmFull,specRefFull,f_succ] = SP2_Data_ExtractPpmRange(-mm.sw/2+mm.ppmCalib,mm.sw/2+mm.ppmCalib,...
                                                                              mm.ppmCalib,mm.sw,abs(datSpecRef));
    if ~f_succ
        return
    end

    %--- spectral window extraction: original spectrum ---
    [minI,maxI,ppmZoom,specOrigZoom,f_succ] = SP2_Data_ExtractPpmRange(mm.frAlignPpmMin,mm.frAlignPpmMax,...
                                                                       mm.ppmCalib,mm.sw,abs(datSpecOrig));
    if ~f_succ
        return
    end
end

%--- spectral window extraction: reference spectrum ---
[minI,maxI,ppmZoom,specRefZoom,f_succ] = SP2_Data_ExtractPpmRange(mm.frAlignPpmMin,mm.frAlignPpmMax,...
                                                                  mm.ppmCalib,mm.sw,abs(datSpecRef));
if ~f_succ
    return
end

%--- apply frequency shift ---
datFidShift  = repmat(datFid,[1 mm.opt.nFrequ]) .* mm.opt.frequShiftMat;

if maxI>mm.frAlignFftZf/2         % index would exceed spectral range (without unwrapping): fftshift necessary
    datSpecShift  = fftshift(fft(datFidShift,mm.frAlignFftZf,1),1);
    specShiftZoom = abs(datSpecShift(minI:maxI,:));        % all shifted spectral ranges
else            % substitute fftshift by index reassignment
    datSpecShift  = fft(datFidShift,mm.frAlignFftZf,1);
    specShiftZoom = abs(datSpecShift((mm.frAlignFftZf/2+minI):(mm.frAlignFftZf/2+maxI),:));        % all shifted spectral ranges
end

%--- amplitude matching ---
% since significant amplitude variations make the minimum of the
% difference measure broad and therefore error prone.
specShiftZoom = specShiftZoom * max(specRefZoom) ./ repmat(max(specShiftZoom),[maxI-minI+1 1]);

%--- amplitude-weighted, integral difference measure ---
specRefZoomMat = repmat(specRefZoom,[1 mm.opt.nFrequ]);    % matrix of (the same) reference spectrum
specCompMat    = reshape([specShiftZoom specRefZoomMat],maxI-minI+1,mm.opt.nFrequ,2);
ampWeight      = max(specCompMat,[],3);             % two-sided signal weight (the larger one is taken), additional ^3 weight
ampWeight      = ampWeight.^2.*ampWeight;
intDiff        = sum(ampWeight.*abs(specShiftZoom-specRefZoomMat));     % integral deviation measure

%--- determination of optimal phase ---
[minIntDiff,minInd] = min(intDiff);         % determination of optimal phase
optFrequ = mm.opt.frequVec(minInd);       % optimal phasing (output parameter)

%--- result visualization ---
if f_show
    %--- calculate and extract corrected FID and spectrum ---
    phPerPt = optFrequ*mm.dwell*mm.nspecC*(pi/180)/(2*pi);      % corr phase per point
    datFidShift  = datFid .* exp(-1i*phPerPt*(0:mm.nspecC-1)');               % apply phase correction
    datSpecShift = fftshift(fft(datFidShift,mm.frAlignFftZf,1),1);
    [minI,maxI,ppmZoom,specShiftZoom,f_succ] = SP2_Data_ExtractPpmRange(mm.frAlignPpmMin,mm.frAlignPpmMax,...
                                                            mm.ppmCalib,mm.sw,abs(datSpecShift));
    if ~f_succ
        return
    end
    
    %--- plot figure ---
    autoFrequFh = figure('IntegerHandle','off');
    if delayInd>0
        titleStr = sprintf(' Automated Frequency Alignment (delay #%.0f, %.3fs)',...
                           delayInd,mm.satRecDelays(delayInd));
    else
        titleStr = sprintf(' Automated Frequency Alignment');
    end
    set(autoFrequFh,'NumberTitle','off','Name',titleStr,...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
    % full spectra for ppm range selection
    subplot(3,1,1)
    hold on
    plot(ppmFull,specOrigFull)
    plot(ppmFull,specRefFull,'r')
    plot(ppmFull,abs(datSpecShift),'g')
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmFull,specRefFull);
    plot([mm.frAlignPpmMin mm.frAlignPpmMin],[minY maxY],'Color',[0 0 0])
    plot([mm.frAlignPpmMax mm.frAlignPpmMax],[minY maxY],'Color',[0 0 0])
    axis([minX maxX min(minY) max(maxY)])
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    legend('orig','ref','shifted')
    
    %--- frequency shift optimization ---
    subplot(3,1,2)
    hold on
    plot(mm.opt.frequVec,intDiff)
    plot(mm.opt.frequVec,intDiff,'*')
    plot(mm.opt.frequVec(minInd),intDiff(minInd),'ro')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(mm.opt.frequVec,intDiff);
    axis([minX maxX min(minY) max(maxY)])
    ylabel('Difference Integral [a.u.]')
    xlabel('Frequency Shift [Hz]')
    
    % original, shifted and reference spectrum
    subplot(3,1,3)
    hold on
    plot(ppmZoom,specOrigZoom)
    plot(ppmZoom,specRefZoom,'r')
    plot(ppmZoom,specShiftZoom,'g')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmZoom,specRefZoom);
    axis([minX maxX min(minY) max(maxY)])
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    legend('orig','ref','shifted')

    %--- info printout ---
%     fprintf('%s done.\n',FCTNAME)
end

%--- update success flag ---
f_done = 1;
