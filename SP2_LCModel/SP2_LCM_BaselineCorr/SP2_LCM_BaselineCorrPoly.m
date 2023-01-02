%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_done] = SP2_LCM_BaselineCorrPoly( specNumber, f_apply )
%%
%%  Spectral baseline correction based on polynomial fit.
%%
%%  02-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm flag


FCTNAME = 'SP2_LCM_BaselineCorrPoly';


%--- init success flag ---
f_done = 0;

%--- data selection ---
if specNumber==1
    %--- check data existence ---
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    elseif ~isfield(lcm.spec1,'spec')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    
    %--- data assignment ---
    datStruct = lcm.spec1;
elseif specNumber==2
    %--- check data existence ---
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    elseif ~isfield(lcm.spec2,'spec')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    
    %--- data assignment ---
    datStruct = lcm.spec2;
else
    %--- check data existence ---
    if ~isfield(proc,'expt')
        fprintf('%s ->\nExport data does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    
    %--- data assignment ---
    datStruct = lcm.expt;
    datStruct.spec = fftshift(fft(lcm.expt.fid,[],1),1);
end

%--- extraction of baseline parts to be fitted ---
corrBinVec   = zeros(1,length(datStruct.spec));      % init global loggingfile index vector for ppm ranges to be used
minPpmIndVec = zeros(1,lcm.basePolyPpmN);           % init minimum ppm index vector
maxPpmIndVec = zeros(1,lcm.basePolyPpmN);           % init maximum ppm index vector
for winCnt = 1:lcm.basePolyPpmN
    [minPpmIndVec(winCnt),maxPpmIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_LCM_ExtractPpmRange(lcm.basePolyPpmMin(winCnt),lcm.basePolyPpmMax(winCnt),...
                                 lcm.ppmCalib,datStruct.sw,datStruct.spec);
    corrBinVec(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)) = 1;
end

%--- polynomial fit ---
corrIndVec  = find(corrBinVec);                                                          % index vector
realCoeff   = polyfit(corrIndVec,real(datStruct.spec(corrIndVec))',lcm.basePolyOrder);   % polynomial fit of real part
imagCoeff   = polyfit(corrIndVec,imag(datStruct.spec(corrIndVec))',lcm.basePolyOrder);   % polynomial fit of imaginary part
specFitTot  = complex(polyval(realCoeff,1:length(datStruct.spec),polyval(imagCoeff,1:length(datStruct.spec))))';
specCorrTot = datStruct.spec - specFitTot;                   % global loggingfile baseline correction

%--- ppm limit handling ---
if flag.lcmPpmShow     % direct
    ppmMin = lcm.ppmShowMin;
    ppmMax = lcm.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -datStruct.sw/2 + lcm.ppmCalib;
    ppmMax = datStruct.sw/2  + lcm.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.lcmFormat==1           % real part
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               datStruct.sw,real(datStruct.spec));
elseif flag.lcmFormat==2       % imaginary part
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               datStruct.sw,imag(datStruct.spec));
else                            % magnitude
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               datStruct.sw,abs(datStruct.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- apply baseline correction ---
% note that the correction is applied to the entire spectrum independent of
% the chosen ppm (zoom) range for visualization.
if f_apply
    %--- data selection ---
    if specNumber==1
        %--- data correction ---
        lcm.spec1.spec = specCorrTot;
        
        %--- export assignment ---
        lcm.expt.fid    = ifft(ifftshift(lcm.spec1.spec,1),[],1);
        lcm.expt.sf     = lcm.spec1.sf;
        lcm.expt.sw_h   = lcm.spec1.sw_h;
        lcm.expt.nspecC = lcm.spec1.nspecC;
    elseif specNumber==2
        %--- data correction ---
        lcm.spec2.spec = specCorrTot;
        
        %--- export assignment ---
        lcm.expt.fid    = ifft(ifftshift(lcm.spec2.spec,1),[],1);
        lcm.expt.sf     = lcm.spec2.sf;
        lcm.expt.sw_h   = lcm.spec2.sw_h;
        lcm.expt.nspecC = lcm.spec2.nspecC;
    else
        %--- data correction ---
        % note that all other export parameters remain untouched
        lcm.expt.spec = specCorrTot;
        lcm.expt.fid  = ifft(ifftshift(lcm.expt.spec,1),[],1);
    end
end

%--- point-to-ppm conversion ---
% of entire spectrum
[minIFull,maxIFull,ppmFull,specFull,f_done] = SP2_LCM_ExtractPpmRange(-1e9,1e9,lcm.ppmCalib,...
                                                           datStruct.sw,real(datStruct.spec));
if minIFull~=1 || maxIFull~=length(datStruct.spec)
    fprintf('%s ->\nppm range of full spectrum exceeds assumed limits. Program aborted.\n',FCTNAME);
    return
end

%--- figure creation ---
if isfield(proc,'fhBCorr')
    if ishandle(lcm.fhBCorr)
        delete(lcm.fhBCorr)
    end
    proc = rmfield(proc,'fhBCorr');
end
% create figure if necessary
if ~isfield(proc,'fhBCorr') || ~ishandle(lcm.fhBaseCorr)
    lcm.fhBCorr = figure;
    if f_apply
        nameStr = sprintf(' Spectrum %.0f: Baseline Correction',specNumber);
    else
        nameStr = sprintf(' Spectrum %.0f: Baseline Modeling',specNumber);
    end
    set(lcm.fhBCorr,'NumberTitle','off','Name',nameStr,...
        'Position',[650 45 704 765],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',lcm.fhBCorr)
end
clf(lcm.fhBCorr)

%--- data visualization: baseline fit ---
subplot(2,1,1)
hold on
% entire, original spectrum
plot(ppmZoom,specZoom)
% series of ppm windows used for baseline fit
for winCnt = 1:lcm.basePolyPpmN
    plot(ppmFull(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)),...
         specFull(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)),'g');
end
% polynomial baseline fit
if flag.lcmFormat==1           % real part
    plot(ppmZoom,real(specFitTot(minIZoom:maxIZoom)),'r')
elseif flag.lcmFormat==2       % imaginary part
    plot(ppmZoom,imag(specFitTot(minIZoom:maxIZoom)),'r')
else                            % magnitude
    plot(ppmZoom,abs(specFitTot(minIZoom:maxIZoom)),'r')
end    
hold off

%--- axis handling ---
set(gca,'XDir','reverse')
[plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
if flag.lcmAmpl        % direct
    plotLim(3) = lcm.amplMin;
    plotLim(4) = lcm.amplMax;
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')


%--- data visualization: baseline fit ---
subplot(2,1,2)
hold on
% zero reference line
plot(ppmZoom,zeros(1,maxIZoom-minIZoom+1),'g')
% baseline corrected spectrum
if flag.lcmFormat==1           % real part
    plot(ppmZoom,real(specCorrTot(minIZoom:maxIZoom)))
elseif flag.lcmFormat==2       % imaginary part
    plot(ppmZoom,imag(specCorrTot(minIZoom:maxIZoom)))
else                            % magnitude
    plot(ppmZoom,abs(specCorrTot(minIZoom:maxIZoom)))
end
hold off

%--- axis handling ---
set(gca,'XDir','reverse')
if flag.lcmFormat==1           % real part
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,real(specCorrTot(minIZoom:maxIZoom)));
elseif flag.lcmFormat==2       % imaginary part
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,imag(specCorrTot(minIZoom:maxIZoom)));
else                            % magnitude
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,abs(specCorrTot(minIZoom:maxIZoom)));
end
if flag.lcmAmpl        % direct
    plotLim(3) = lcm.amplMin;
    plotLim(4) = lcm.amplMax;
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- update success flag ---
f_done = 1;
