%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [optFrequ,f_done] = SP2_Data_AutoFrequDetIndiv(datFid,datFidRef,pars,varargin)
%% 
%%  Automated determination of optimal frequency shift to align a spectra
%%  with a reference for an individual FID.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data

FCTNAME = 'SP2_Data_AutoFrequDetIndiv';


%---
fprintf('--- WARNING ---\n(inside %s)\n',FCTNAME);
return

%--- init success flag ---
f_done = 0;

%--- verbose handling ---
f_show = 0;         % default: no figure display
anaPars = data;     % default: parameters from global loggingfile 'data' structure
if nargin==4        % verbose flag
    f_show = SP2_Check4FlagR( varargin{1} );
elseif nargin==5    % verbose flag & analysis parameters
    f_show  = SP2_Check4FlagR( varargin{1} );
    anaPars = SP2_Check4StructR( varargin{2} );
elseif nargin~=3
    fprintf('%s ->\n%i function arguments are not supported. Program aborted.\n',FCTNAME,nargin);
    return
end

%--- consistency check ---
if ~SP2_Check4ColVec(datFid)
    return
end
if ~SP2_Check4ColVec(datFidRef)
    return
end

%--- exponential line broadening for SNR improvement ---
lbWeight  = exp(-anaPars.frAlignExpLb*pars.dwell*(0:pars.nspecC-1)*pi)';
datFid    = datFid.*lbWeight;
datFidRef = datFidRef.*lbWeight;

%--- spectral FFT ---
datSpecOrig = fftshift(fft(datFid(1:anaPars.frAlignFftCut),anaPars.frAlignFftZf,1),1);
datSpecRef  = fftshift(fft(datFidRef(1:anaPars.frAlignFftCut),anaPars.frAlignFftZf,1),1);

%--- spectral window extraction: full SW of original spectrum ---
[minIFull,maxIFull,ppmFull,specOrigFull,f_succ] = SP2_Data_ExtractPpmRange(-pars.sw/2+data.ppmCalib,pars.sw/2+data.ppmCalib,...
                                                        data.ppmCalib,pars.sw,abs(datSpecOrig));
if ~f_succ
    return
end

%--- spectral window extraction: full SW of reference spectrum ---
[minIFull,maxIFull,ppmFull,specRefFull,f_succ] = SP2_Data_ExtractPpmRange(-pars.sw/2+data.ppmCalib,pars.sw/2+data.ppmCalib,...
                                                        data.ppmCalib,pars.sw,abs(datSpecRef));
if ~f_succ
    return
end

%--- spectral window extraction: original spectrum ---
[minI,maxI,ppmZoom,specOrigZoom,f_succ] = SP2_Data_ExtractPpmRange(anaPars.frAlignPpmMin,anaPars.frAlignPpmMax,...
                                                        data.ppmCalib,pars.sw,abs(datSpecOrig));
if ~f_succ
    return
end

%--- spectral window extraction: reference spectrum ---
[minI,maxI,ppmZoom,specRefZoom,f_succ] = SP2_Data_ExtractPpmRange(anaPars.frAlignPpmMin,anaPars.frAlignPpmMax,...
                                                        data.ppmCalib,pars.sw,abs(datSpecRef));
if ~f_succ
    return
end

%--- determination of frequency shift ---
frequVec = -anaPars.frAlignFrequRg:anaPars.frAlignFrequRes:anaPars.frAlignFrequRg;       % test frequency shift
nFrequ   = length(frequVec);                % number of test frequency shifts
intDiff  = zeros(1,nFrequ);                 % integral difference measures
for fCnt = 1:nFrequ
    %--- calculate shifted spectrum ---
    phPerPt = frequVec(fCnt)*pars.dwell*pars.nspecC*(pi/180)/(2*pi);        % corr phase per point
    datFidShift  = datFid .* exp(-1i*phPerPt*(0:pars.nspecC-1)');           % apply phase correction
    datSpecShift = fftshift(fft(datFidShift,anaPars.frAlignFftZf,1),1);

    %--- integral quality measure ---
    [minI,maxI,ppmZoom,specShiftZoom,f_succ] = SP2_Data_ExtractPpmRange(anaPars.frAlignPpmMin,anaPars.frAlignPpmMax,...
                                                            data.ppmCalib,pars.sw,abs(datSpecShift));
    if ~f_succ
        return
    end
    
    %--- amplitude matching ---
    % since significant amplitude variations make the minimum of the
    % difference measure broad and therefore error prone.
    specShiftZoom = specShiftZoom*max(specRefZoom)/max(specShiftZoom);
    
    %--- amplitude-weighted, integral difference measure ---
    ampWeight     = max([specShiftZoom specRefZoom],[],2).^3;           % two-sided signal weight (the larger one is taken), additional ^3 weight
    intDiff(fCnt) = sum(ampWeight.*abs(specShiftZoom-specRefZoom));     % integral deviation measure
end
[minIntDiff,minInd] = min(intDiff);         % determination of optimal phase
optFrequ = frequVec(minInd);                % optimal phasing (output parameter)

%--- result visualization ---
if f_show
    %--- calculate and extract corrected FID and spectrum ---
    phPerPt = optFrequ*pars.dwell*pars.nspecC*(pi/180)/(2*pi);      % corr phase per point
    datFidShift  = datFid .* exp(-1i*phPerPt*(0:pars.nspecC-1)');               % apply phase correction
    datSpecShift = fftshift(fft(datFidShift,anaPars.frAlignFftZf,1),1);
    [minI,maxI,ppmZoom,specShiftZoom,f_succ] = SP2_Data_ExtractPpmRange(anaPars.frAlignPpmMin,anaPars.frAlignPpmMax,...
                                                            data.ppmCalib,pars.sw,abs(datSpecShift));
    if ~f_succ
        return
    end
    
    %--- plot figure ---
    autoFrequFh = figure('IntegerHandle','off');
    set(autoFrequFh,'NumberTitle','off','Name',sprintf(' Automated Frequency Alignment'),...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
    % full spectra for ppm range selection
    subplot(3,1,1)
    hold on
    plot(ppmFull,specOrigFull)
    plot(ppmFull,specRefFull,'r')
    plot(ppmFull,abs(datSpecShift),'g')
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmFull,specRefFull);
    plot([anaPars.frAlignPpmMin anaPars.frAlignPpmMin],[minY maxY],'Color',[0 0 0])
    plot([anaPars.frAlignPpmMax anaPars.frAlignPpmMax],[minY maxY],'Color',[0 0 0])
    axis([minX maxX min(minY) max(maxY)])
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    legend('orig','ref','shifted')
    
    %--- frequency shift optimization ---
    subplot(3,1,2)
    hold on
    plot(frequVec,intDiff)
    plot(frequVec,intDiff,'*')
    plot(frequVec(minInd),intDiff(minInd),'ro')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(frequVec,intDiff);
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
    fprintf('%s done.\n',FCTNAME);
end

%--- update success flag ---
f_done = 1;
