%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_done] = SP2_MRSI_BaselineCorrInterp( specNumber, f_apply )
%%
%%  Spectral baseline correction based on spline interpolation.
%%
%%  10-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag


FCTNAME = 'SP2_MRSI_BaselineCorrInterp';


%--- init success flag ---
f_done = 0;

%--- data selection ---
if specNumber==1
    %--- check data existence ---
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME)
        return
    elseif ~isfield(mrsi.spec1,'spec')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME)
        return
    end
    
    %--- data assignment ---
    datStruct = mrsi.spec1;
elseif specNumber==2
    %--- check data existence ---
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME)
        return
    elseif ~isfield(mrsi.spec2,'spec')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME)
        return
    end
    
    %--- data assignment ---
    datStruct = mrsi.spec2;
else
    %--- check data existence ---
    if ~isfield(proc,'expt')
        fprintf('%s ->\nExport data does not exist. Load/reconstruct first.\n',FCTNAME)
        return
    end
    
    %--- data assignment ---
    datStruct = mrsi.expt;
    datStruct.spec = fftshift(fft(mrsi.expt.fid,[],1),1);
end

%--- extraction of baseline parts to be fitted ---
corrBinVec   = zeros(1,length(datStruct.spec));     % init global index vector for ppm ranges to be used
minPpmIndVec = zeros(1,mrsi.baseInterpPpmN);           % init minimum ppm index vector
maxPpmIndVec = zeros(1,mrsi.baseInterpPpmN);           % init maximum ppm index vector
for winCnt = 1:mrsi.baseInterpPpmN
    [minPpmIndVec(winCnt),maxPpmIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_MRSI_ExtractPpmRange(mrsi.baseInterpPpmMin(winCnt),mrsi.baseInterpPpmMax(winCnt),...
                                 mrsi.ppmCalib,datStruct.sw,datStruct.spec);
    corrBinVec(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)) = 1;
end

% 
% %--- polynomial fit ---
% corrIndVec  = find(corrBinVec);                                                          % index vector
% realCoeff   = polyfit(corrIndVec,real(datStruct.spec(corrIndVec))',mrsi.baseInterpOrder);   % polynomial fit of real part
% imagCoeff   = polyfit(corrIndVec,imag(datStruct.spec(corrIndVec))',mrsi.baseInterpOrder);   % polynomial fit of imaginary part
% specFitTot  = complex(polyval(realCoeff,1:length(datStruct.spec),polyval(imagCoeff,1:length(datStruct.spec))))';
% specCorrTot = datStruct.spec - specFitTot;                   % global baseline correction
% 

%--- polynomial fit ---
% corrIndVec  = find(corrBinVec);                                                                 % index vector
% realSpline  = spline(corrIndVec,real(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of real part
% imagSpline  = spline(corrIndVec,imag(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of imaginary part
% specFitTot  = complex(realSpline,imagSpline)';
% specCorrTot = datStruct.spec - specFitTot;                   % global baseline correction
corrIndVec  = find(corrBinVec);                                                                 % index vector
realSpline  = spline(corrIndVec,real(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of real part
imagSpline  = spline(corrIndVec,imag(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of imaginary part
specFitTot  = complex(realSpline,imagSpline)';
specCorrTot = datStruct.spec - specFitTot;                   % global baseline correction

% 
%     vecLen = length(vector);
%     xx = 1:(vecLen-1)/(vecLen*splFac-1):vecLen;
%     yy = spline(1:vecLen,vector,xx);
%     [yyMaxVal,yyMaxInd] = max(yy);
%     spLimYY = find(yy>yyMaxVal/2);      % indi
% 


%--- ppm limit handling ---
if flag.mrsiPpmShow     % direct
    ppmMin = mrsi.ppmShowMin;
    ppmMax = mrsi.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -datStruct.sw/2 + mrsi.ppmCalib;
    ppmMax = datStruct.sw/2  + mrsi.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.mrsiFormat==1           % real part
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               datStruct.sw,real(datStruct.spec));
elseif flag.mrsiFormat==2       % imaginary part
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               datStruct.sw,imag(datStruct.spec));
else                            % magnitude
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               datStruct.sw,abs(datStruct.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- apply baseline correction ---
% note that the correction is applied to the entire spectrum independent of
% the chosen ppm (zoom) range for visualization.
if f_apply
    %--- data selection ---
    if specNumber==1
        %--- data correction ---
        mrsi.spec1.spec = specCorrTot;
        
        %--- export assignment ---
        mrsi.expt.fid    = ifft(ifftshift(mrsi.spec1.spec,1),[],1);
        mrsi.expt.sf     = mrsi.spec1.sf;
        mrsi.expt.sw_h   = mrsi.spec1.sw_h;
        mrsi.expt.nspecC = mrsi.spec1.nspecC;
    elseif specNumber==2
        %--- data correction ---
        mrsi.spec2.spec = specCorrTot;
        
        %--- export assignment ---
        mrsi.expt.fid    = ifft(ifftshift(mrsi.spec2.spec,1),[],1);
        mrsi.expt.sf     = mrsi.spec2.sf;
        mrsi.expt.sw_h   = mrsi.spec2.sw_h;
        mrsi.expt.nspecC = mrsi.spec2.nspecC;
    else
        %--- data correction ---
        % note that all other export parameters remain untouched
        mrsi.expt.spec = specCorrTot;
        mrsi.expt.fid  = ifft(ifftshift(mrsi.expt.spec,1),[],1);
    end
end

%--- point-to-ppm conversion ---
% of entire spectrum
[minIFull,maxIFull,ppmFull,specFull,f_done] = SP2_MRSI_ExtractPpmRange(-1e9,1e9,mrsi.ppmCalib,...
                                                           datStruct.sw,real(datStruct.spec));
if minIFull~=1 || maxIFull~=length(datStruct.spec)
    fprintf('%s ->\nppm range of full spectrum exceeds assumed limits. Program aborted.\n',FCTNAME)
    return
end

%--- figure creation ---
if isfield(proc,'fhBCorr')
    if ishandle(mrsi.fhBCorr)
        delete(mrsi.fhBCorr)
    end
    proc = rmfield(proc,'fhBCorr');
end
% create figure if necessary
if ~isfield(proc,'fhBCorr') || ~ishandle(mrsi.fhBaseCorr)
    mrsi.fhBCorr = figure;
    if f_apply
        nameStr = sprintf(' Spectrum %.0f: Baseline Correction',specNumber);
    else
        nameStr = sprintf(' Spectrum %.0f: Baseline Modeling',specNumber);
    end
    set(mrsi.fhBCorr,'NumberTitle','off','Name',nameStr,...
        'Position',[650 45 704 765],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhBCorr)
end
clf(mrsi.fhBCorr)

%--- data visualization: baseline fit ---
subplot(2,1,1)
hold on
% entire, original spectrum
plot(ppmZoom,specZoom)
% series of ppm windows used for baseline fit
for winCnt = 1:mrsi.baseInterpPpmN
    plot(ppmFull(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)),...
         specFull(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)),'g');
end
% polynomial baseline fit
if flag.mrsiFormat==1           % real part
    plot(ppmZoom,real(specFitTot(minIZoom:maxIZoom)),'r')
elseif flag.mrsiFormat==2       % imaginary part
    plot(ppmZoom,imag(specFitTot(minIZoom:maxIZoom)),'r')
else                            % magnitude
    plot(ppmZoom,abs(specFitTot(minIZoom:maxIZoom)),'r')
end    
hold off

%--- axis handling ---
set(gca,'XDir','reverse')
[plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
if flag.mrsiAmpl        % direct
    plotLim(3) = mrsi.amplMin;
    plotLim(4) = mrsi.amplMax;
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
if flag.mrsiFormat==1           % real part
    plot(ppmZoom,real(specCorrTot(minIZoom:maxIZoom)))
elseif flag.mrsiFormat==2       % imaginary part
    plot(ppmZoom,imag(specCorrTot(minIZoom:maxIZoom)))
else                            % magnitude
    plot(ppmZoom,abs(specCorrTot(minIZoom:maxIZoom)))
end
hold off

%--- axis handling ---
set(gca,'XDir','reverse')
if flag.mrsiFormat==1           % real part
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,real(specCorrTot(minIZoom:maxIZoom)));
elseif flag.mrsiFormat==2       % imaginary part
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,imag(specCorrTot(minIZoom:maxIZoom)));
else                            % magnitude
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,abs(specCorrTot(minIZoom:maxIZoom)));
end
if flag.mrsiAmpl        % direct
    plotLim(3) = mrsi.amplMin;
    plotLim(4) = mrsi.amplMax;
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- update success flag ---
f_done = 1;
