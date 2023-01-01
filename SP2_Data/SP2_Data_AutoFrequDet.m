%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [optFrequ,f_succ] = SP2_Data_AutoFrequDet(datFid,datFidRef,pars,frAlignPpmMin,frAlignPpmMax,infoStr,f_show)
%% 
%%  Automated determination of optimal frequency shift to align a spectra
%%  with a reference.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_AutoFrequDet';


%--- init success flag ---
f_succ = 0;

%--- verbose handling ---
if nargin~=7
    fprintf('%s ->\n%i function arguments are not supported. Program aborted.\n',FCTNAME,nargin)
    return
end

%--- consistency check ---
if ~SP2_Check4ColVec(datFid)
    return
end
if ~SP2_Check4ColVec(datFidRef)
    return
end

%--- parameter handling ---
frAlignPpmN = length(frAlignPpmMin);
if length(frAlignPpmMax)~=frAlignPpmN
    fprintf('Inconsistent PPM window dimension detected (Min %.0f ~= Max %.0f).\nProgram aborted.\n',...
            length(frAlignPpmMin),length(frAlignPpmMax))
    return
end

%--- exponential line broadening for SNR improvement ---
lbWeight  = exp(-data.frAlignExpLb*pars.dwell*(0:data.spec1.nspecC-1)*pi)';
datFid    = datFid.*lbWeight;
datFidRef = datFidRef.*lbWeight;

%--- spectral FFT ---
if data.frAlignFftCut<data.spec1.nspecC         % true apodization
    if f_show
        datSpecOrig = fftshift(fft(datFid(1:data.frAlignFftCut),data.frAlignFftZf,1),1);
    end
    datSpecRef = fftshift(fft(datFidRef(1:data.frAlignFftCut),data.frAlignFftZf,1),1);
else
    if f_show
        datSpecOrig = fftshift(fft(datFid,data.frAlignFftZf,1),1);
    end
    datSpecRef = fftshift(fft(datFidRef,data.frAlignFftZf,1),1);
end

if f_show
    %--- zoomed window extension ---
    ppmExt = 0.1;       % 0.1 ppm, symmetric
    
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

    %--- spectral window extraction: original spectrum (display) ---
    [minI,maxI,ppmZoomDisplay,specOrigZoomDisplay,f_succ] = SP2_Data_ExtractPpmRange(min(frAlignPpmMin)-ppmExt,max(frAlignPpmMax)+ppmExt,...
                                                                       data.ppmCalib,pars.sw,abs(datSpecOrig));
    if ~f_succ
        return
    end

    %--- spectral window extraction: reference spectrum (display) ---
    [minI,maxI,ppmZoomDisplay,specRefZoomDisplay,f_succ] = SP2_Data_ExtractPpmRange(min(frAlignPpmMin)-ppmExt,max(frAlignPpmMax)+ppmExt,...
                                                                       data.ppmCalib,pars.sw,abs(datSpecRef));
    if ~f_succ
        return
    end
end

%--- spectral window extraction: reference spectrum ---
[minI,maxI,ppmZoom,specRefZoom,f_succ] = SP2_Data_ExtractPpmRange(min(frAlignPpmMin),max(frAlignPpmMax),...
                                                                  data.ppmCalib,pars.sw,abs(datSpecRef));
if ~f_succ
    return
end

% %--- determination of frequency shift ---
% frequVec        = -data.frAlignFrequRg:data.frAlignFrequRes:data.frAlignFrequRg;       % test frequency shift
% data.opt.nFrequ = length(frequVec);                % number of test frequency shifts
% intDiff         = zeros(1,data.opt.nFrequ);                 % integral difference measures
% phPerPtVec      = frequVec*pars.dwell*data.spec1.nspecC*(pi/180)/(2*pi);       % correction phase per point: vector
% phPerPtMat      = repmat(phPerPtVec,[data.spec1.nspecC 1]);                    % correction phase per point: matrix
% pointMat        = repmat((0:(data.spec1.nspecC-1))',[1 data.opt.nFrequ]);
% data.opt.frequShiftMat = exp(-1i*phPerPtMat .* pointMat);      % time domain frequency shift matrix
% !!!!!!!!!!!!!!!!!!!! PUT INTO SP2_DATA_AUTOFREQUDETPREP.M !!!!!!!!!!!!!!


%--- extraction of spectral parts to be matched ---
alignAllBin = zeros(1,max(data.spec1.nspecC,data.frAlignFftZf));     % init global index vector for ppm ranges to be used (binary format)
alignMinI   = zeros(1,frAlignPpmN);            % init minimum ppm index vector
alignMaxI   = zeros(1,frAlignPpmN);            % init maximum ppm index vector
for winCnt = 1:frAlignPpmN
    [alignMinI(winCnt),alignMaxI(winCnt),ppmZoomSingle,specZoomSingle,f_done] = ...
        SP2_Data_ExtractPpmRange(frAlignPpmMin(winCnt),frAlignPpmMax(winCnt),...
                                 data.ppmCalib,data.spec1.sw,datSpecRef);
    if ~f_done
        fprintf('\n%s ->\nFrequency window extraction failed for section #2 (%.2f-%.2f ppm). Program aborted.\n',...
                winCnt,frAlignPpmMin(winCnt),frAlignPpmMax(winCnt))
        return
    end
    alignAllBin(alignMinI(winCnt):alignMaxI(winCnt)) = 1;
end
data.frAlignAllInd  = find(alignAllBin);             % global index vector including all ppm ranges
data.frAlignAllIndN = length(data.frAlignAllInd);

%--- frequency shift determination ---
datFidShiftMat  = repmat(datFid,[1 data.opt.nFrequ]) .* data.opt.frequShiftMat;

if max(data.frAlignAllInd)>data.frAlignFftZf/2      % index would exceed spectral range (without unwrapping): fftshift necessary
    if data.frAlignFftCut<data.spec1.nspecC
        datSpecShift = fftshift(fft(datFidShiftMat(1:data.frAlignFftCut,:),data.frAlignFftZf,1),1);
    else
        datSpecShift = fftshift(fft(datFidShiftMat,data.frAlignFftZf,1),1);
    end
    specShiftZoom = abs(datSpecShift(data.frAlignAllInd,:));        % all
else                                                % substitute fftshift by index reassignment
    if data.frAlignFftCut<data.spec1.nspecC
        datSpecShift  = fft(datFidShiftMat(1:data.frAlignFftCut,:),data.frAlignFftZf,1);
    else
        datSpecShift  = fft(datFidShiftMat,data.frAlignFftZf,1);
    end
    % specShiftZoom = abs(datSpecShift((data.frAlignFftZf/2+min(data.frAlignAllInd)):(data.frAlignFftZf/2+max(data.frAlignAllInd)),:));        % all shifted spectral ranges
    specShiftZoom = abs(datSpecShift(data.frAlignFftZf/2+data.frAlignAllInd,:));        % all shifted spectral ranges
end

%--- amplitude matching ---
% since significant amplitude variations make the minimum of the
% difference measure broad and therefore error prone.
% specShiftZoom = specShiftZoom * max(specRefZoom) ./ repmat(max(specShiftZoom),[data.frAlignAllInd(end)-data.frAlignAllInd(1)+1 1]);
specRefZoomSelect = abs(datSpecRef(data.frAlignAllInd));
specShiftZoom     = specShiftZoom * max(specRefZoom) ./ repmat(max(specShiftZoom),[data.frAlignAllIndN 1]);

%--- amplitude-weighted, integral difference measure ---
specRefZoomMat = repmat(specRefZoomSelect,[1 data.opt.nFrequ]);    % matrix of (the same) reference spectrum
specCompMat    = reshape([specShiftZoom specRefZoomMat],data.frAlignAllIndN,data.opt.nFrequ,2);
ampWeight      = max(specCompMat,[],3);             % two-sided signal weight (the larger one is taken), additional ^3 weight
ampWeight      = ampWeight.^2.*ampWeight;
intDiff        = sum(ampWeight.*abs(specShiftZoom-specRefZoomMat));     % integral deviation measure

%--- determination of optimal phase ---
[minIntDiff,minInd] = min(intDiff);         % determination of optimal phase
optFrequ = data.opt.frequVec(minInd);       % optimal frequency (output parameter)

%--- result visualization ---
if f_show
    %--- calculate and extract corrected FID and spectrum ---
    phPerPt = optFrequ*pars.dwell*data.spec1.nspecC*(pi/180)/(2*pi);      % corr phase per point
    datFidShift  = datFid .* exp(-1i*phPerPt*(0:data.spec1.nspecC-1)');               % apply phase correction
    if data.frAlignFftCut<data.spec1.nspecC
        datSpecShift = fftshift(fft(datFidShift(1:data.frAlignFftCut),data.frAlignFftZf,1),1);
    else
        datSpecShift = fftshift(fft(datFidShift,data.frAlignFftZf,1),1);
    end
    
    %--- spectral window extraction: original spectrum ---
    [minI,maxI,ppmZoomDisplay,specShiftZoomDisplay,f_succ] = SP2_Data_ExtractPpmRange(min(frAlignPpmMin)-ppmExt,max(frAlignPpmMax)+ppmExt,...
                                                                       data.ppmCalib,pars.sw,abs(datSpecShift));
    if ~f_succ
        return
    end    
    
    %--- plot figure ---
    autoFrequFh = figure('IntegerHandle','off');
    set(autoFrequFh,'NumberTitle','off','Name',sprintf(' Automated Frequency Alignment (%s): %.2f Hz',infoStr,optFrequ),...
        'Position',[378 -2 769 850],'Color',[1 1 1],'Tag','AlignQA');
    % full spectra for ppm range selection
    subplot(3,1,1)
    hold on
    plot(ppmFull,specOrigFull)
    plot(ppmFull,specRefFull,'r')
    plot(ppmFull,abs(datSpecShift),'g')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmFull,specOrigFull);
    [minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmFull,specRefFull);
    [minX maxX minY(3) maxY(3)] = SP2_IdealAxisValues(ppmFull,abs(datSpecShift));
    minY = min(minY);
    maxY = max(maxY);
    for winCnt = 1:frAlignPpmN
        plot([frAlignPpmMin(winCnt) frAlignPpmMin(winCnt)],[minY maxY],'Color',[1 0.25 1])
        plot([frAlignPpmMax(winCnt) frAlignPpmMax(winCnt)],[minY maxY],'Color',[1 0.25 1])
    end
    if maxX>minX && maxY>minY && ~any(isnan([minX maxX minY maxY]))
        axis([minX maxX minY maxY])
    else
        fprintf('\n\nWARNING: Frequency alignment failed! (global display)\n')
        fprintf('[minX maxX minY maxY] = [%.1f %.1f %.1f %.1f]\n\n',minX,maxX,minY,maxY)
    end
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    legend('orig','ref','shifted')
    
    %--- frequency shift optimization ---
    subplot(3,1,2)
    hold on
    plot(data.opt.frequVec,intDiff)
    plot(data.opt.frequVec,intDiff,'*')
    plot(data.opt.frequVec(minInd),intDiff(minInd),'ro')
    [minX maxX minY maxY] = SP2_IdealAxisValues(data.opt.frequVec,intDiff);
    if maxX>minX && maxY>minY && ~any(isnan([minX maxX minY maxY]))
        axis([minX maxX minY maxY])
    else
        fprintf('\n\nWARNING: Frequency alignment failed! (optimization display)\n')
        fprintf('[minX maxX minY maxY] = [%.1f %.1f %.1f %.1f]\n\n',minX,maxX,minY,maxY)
    end
    ylabel('Difference Integral [a.u.]')
    xlabel('Frequency Shift [Hz]')
    
    % original, shifted and reference spectrum
    subplot(3,1,3)
    hold on
    plot(ppmZoomDisplay,specOrigZoomDisplay)
    plot(ppmZoomDisplay,specRefZoomDisplay,'r')
    plot(ppmZoomDisplay,specShiftZoomDisplay,'g')
    [minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmZoomDisplay,specOrigZoomDisplay);
    [minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmZoomDisplay,specRefZoomDisplay);
    [minX maxX minY(3) maxY(3)] = SP2_IdealAxisValues(ppmZoomDisplay,specShiftZoomDisplay);
    minY = min(minY);
    maxY = max(maxY);
    for winCnt = 1:frAlignPpmN
        plot([frAlignPpmMin(winCnt) frAlignPpmMin(winCnt)],[minY maxY],'Color',[1 0.25 1])
        plot([frAlignPpmMax(winCnt) frAlignPpmMax(winCnt)],[minY maxY],'Color',[1 0.25 1])
    end
    if maxX>minX && maxY>minY && ~any(isnan([minX maxX minY maxY]))
        axis([minX maxX minY maxY])
    else
        fprintf('\n\nWARNING: Frequency alignment failed! (zoomed display)\n')
        fprintf('[minX maxX minY maxY] = [%.1f %.1f %.1f %.1f]\n\n',minX,maxX,minY,maxY)
    end
    hold off
    ylabel('Amplitude [a.u.]')
    xlabel('Frequency [ppm]')
    set(gca,'XDir','reverse')
    legend('orig','ref','shifted')

    %--- info printout ---
    % fprintf('%s done.\n',FCTNAME)
end

%--- update success flag ---
f_succ = 1;
