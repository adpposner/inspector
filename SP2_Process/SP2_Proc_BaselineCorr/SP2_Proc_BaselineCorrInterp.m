%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_Proc_BaselineCorrInterp( specNumber, f_apply )
%%
%%  Spectral baseline correction based on spline interpolation.
%%
%%  10-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag


FCTNAME = 'SP2_Proc_BaselineCorrInterp';


%--- init success flag ---
f_succ = 0;

%--- data selection ---
if specNumber==1
    %--- check data existence ---
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    elseif ~isfield(proc.spec1,'spec')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    
    %--- data assignment ---
    datStruct = proc.spec1;
elseif specNumber==2
    %--- check data existence ---
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    elseif ~isfield(proc.spec2,'spec')
        fprintf('%s ->\nData does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    
    %--- data assignment ---
    datStruct = proc.spec2;
else
    %--- check data existence ---
    if ~isfield(proc,'expt')
        fprintf('%s ->\nExport data does not exist. Load/reconstruct first.\n',FCTNAME);
        return
    end
    
    %--- data assignment ---
    datStruct = proc.expt;
    datStruct.spec = fftshift(fft(proc.expt.fid,[],1),1);
end

%--- extraction of baseline parts to be fitted ---
corrBinVec   = zeros(1,length(datStruct.spec));     % init global loggingfile index vector for ppm ranges to be used
minPpmIndVec = zeros(1,proc.baseInterpPpmN);           % init minimum ppm index vector
maxPpmIndVec = zeros(1,proc.baseInterpPpmN);           % init maximum ppm index vector
for winCnt = 1:proc.baseInterpPpmN
    [minPpmIndVec(winCnt),maxPpmIndVec(winCnt),ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(proc.baseInterpPpmMin(winCnt),proc.baseInterpPpmMax(winCnt),...
                                 proc.ppmCalib,datStruct.sw,datStruct.spec);
    if ~f_done
        fprintf('\n%s ->\nFrequency window extraction failed for section #2 (%.2f-%.2f ppm). Program aborted.\n',...
                winCnt,proc.baseInterpPpmMin(winCnt),proc.baseInterpPpmMax(winCnt))
        return
    end 
    corrBinVec(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)) = 1;
end

% 
% %--- polynomial fit ---
% corrIndVec  = find(corrBinVec);                                                          % index vector
% realCoeff   = polyfit(corrIndVec,real(datStruct.spec(corrIndVec))',proc.baseInterpOrder);   % polynomial fit of real part
% imagCoeff   = polyfit(corrIndVec,imag(datStruct.spec(corrIndVec))',proc.baseInterpOrder);   % polynomial fit of imaginary part
% specFitTot  = complex(polyval(realCoeff,1:length(datStruct.spec),polyval(imagCoeff,1:length(datStruct.spec))))';
% specCorrTot = datStruct.spec - specFitTot;                   % global loggingfile baseline correction
% 

%--- polynomial fit ---
% corrIndVec  = find(corrBinVec);                                                                 % index vector
% realSpline  = spline(corrIndVec,real(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of real part
% imagSpline  = spline(corrIndVec,imag(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of imaginary part
% specFitTot  = complex(realSpline,imagSpline)';
% specCorrTot = datStruct.spec - specFitTot;                   % global loggingfile baseline correction
corrIndVec  = find(corrBinVec);                                                                 % index vector
realSpline  = spline(corrIndVec,real(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of real part
imagSpline  = spline(corrIndVec,imag(datStruct.spec(corrIndVec))',1:length(datStruct.spec));    % spline fit of imaginary part
specFitTot  = complex(realSpline,imagSpline)';
specCorrTot = datStruct.spec - specFitTot;                   % global loggingfile baseline correction

% 
%     vecLen = length(vector);
%     xx = 1:(vecLen-1)/(vecLen*splFac-1):vecLen;
%     yy = spline(1:vecLen,vector,xx);
%     [yyMaxVal,yyMaxInd] = max(yy);
%     spLimYY = find(yy>yyMaxVal/2);      % indi
% 


%--- ppm limit handling ---
if flag.procPpmShow     % direct
    ppmMin = proc.ppmShowMin;
    ppmMax = proc.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -datStruct.sw/2 + proc.ppmCalib;
    ppmMax = datStruct.sw/2  + proc.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.procFormat==1           % real part
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               datStruct.sw,real(datStruct.spec));
elseif flag.procFormat==2       % imaginary part
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               datStruct.sw,imag(datStruct.spec));
else                            % magnitude
    [minIZoom,maxIZoom,ppmZoom,specZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
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
        proc.spec1.spec = specCorrTot;
        
        %--- export assignment ---
        proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
        proc.expt.sf     = proc.spec1.sf;
        proc.expt.sw_h   = proc.spec1.sw_h;
        proc.expt.nspecC = proc.spec1.nspecC;
    elseif specNumber==2
        %--- data correction ---
        proc.spec2.spec = specCorrTot;
        
        %--- export assignment ---
        proc.expt.fid    = ifft(ifftshift(proc.spec2.spec,1),[],1);
        proc.expt.sf     = proc.spec2.sf;
        proc.expt.sw_h   = proc.spec2.sw_h;
        proc.expt.nspecC = proc.spec2.nspecC;
    else
        %--- data correction ---
        % note that all other export parameters remain untouched
        proc.expt.spec = specCorrTot;
        proc.expt.fid  = ifft(ifftshift(proc.expt.spec,1),[],1);
    end
end

%--- point-to-ppm conversion ---
% of entire spectrum
[minIFull,maxIFull,ppmFull,specFull,f_done] = SP2_Proc_ExtractPpmRange(-1e9,1e9,proc.ppmCalib,...
                                                           datStruct.sw,real(datStruct.spec));
if minIFull~=1 || maxIFull~=length(datStruct.spec)
    fprintf('%s ->\nppm range of full spectrum exceeds assumed limits. Program aborted.\n',FCTNAME);
    return
end

%--- figure creation ---
if isfield(proc,'fhBCorr')
    if ishandle(proc.fhBCorr)
        delete(proc.fhBCorr)
    end
    proc = rmfield(proc,'fhBCorr');
end
% create figure if necessary
if ~isfield(proc,'fhBCorr') || ~ishandle(proc.fhBaseCorr)
    proc.fhBCorr = figure;
    if f_apply
        nameStr = sprintf(' Spectrum %.0f: Baseline Correction',specNumber);
    else
        nameStr = sprintf(' Spectrum %.0f: Baseline Modeling',specNumber);
    end
    set(proc.fhBCorr,'NumberTitle','off','Name',nameStr,...
        'Position',[650 45 704 765],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',proc.fhBCorr)
end
clf(proc.fhBCorr)

%--- data visualization: baseline fit ---
subplot(2,1,1)
hold on
% entire, original spectrum
plot(ppmZoom,specZoom)
% series of ppm windows used for baseline fit
for winCnt = 1:proc.baseInterpPpmN
    plot(ppmFull(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)),...
         specFull(minPpmIndVec(winCnt):maxPpmIndVec(winCnt)),'g');
end
% polynomial baseline fit
if flag.procFormat==1           % real part
    plot(ppmZoom,real(specFitTot(minIZoom:maxIZoom)),'r')
elseif flag.procFormat==2       % imaginary part
    plot(ppmZoom,imag(specFitTot(minIZoom:maxIZoom)),'r')
else                            % magnitude
    plot(ppmZoom,abs(specFitTot(minIZoom:maxIZoom)),'r')
end    
hold off

%--- axis handling ---
set(gca,'XDir','reverse')
[plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
if flag.procAmpl        % direct
    plotLim(3) = proc.amplMin;
    plotLim(4) = proc.amplMax;
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
if flag.procFormat==1           % real part
    plot(ppmZoom,real(specCorrTot(minIZoom:maxIZoom)))
elseif flag.procFormat==2       % imaginary part
    plot(ppmZoom,imag(specCorrTot(minIZoom:maxIZoom)))
else                            % magnitude
    plot(ppmZoom,abs(specCorrTot(minIZoom:maxIZoom)))
end
hold off

%--- axis handling ---
set(gca,'XDir','reverse')
if flag.procFormat==1           % real part
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,real(specCorrTot(minIZoom:maxIZoom)));
elseif flag.procFormat==2       % imaginary part
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,imag(specCorrTot(minIZoom:maxIZoom)));
else                            % magnitude
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,abs(specCorrTot(minIZoom:maxIZoom)));
end
if flag.procAmpl        % direct
    plotLim(3) = proc.amplMin;
    plotLim(4) = proc.amplMax;
end
axis(plotLim)
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')

%--- update success flag ---
f_succ = 1;
