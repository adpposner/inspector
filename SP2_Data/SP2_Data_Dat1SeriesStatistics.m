%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_Dat1SeriesStatistics(fidArray,nrVec,f_plot)
%% 
%%  Basics statistics of FID series for quality control.
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data

FCTNAME = 'SP2_Data_Dat1SeriesStatistics';


%--- basic formating ---
datSize = size(fidArray);
seriesN = datSize(1);
nspecC  = datSize(2);
nr      = datSize(3);

%--- consistency checks ---
if length(nrVec)~=nr
    fprintf('%s ->\nInconcistency for NR assignment detected.\n',FCTNAME);
    return
end
if nspecC~=data.spec1.nspecC
    fprintf('%s ->\nInconcistency for <nspecC> assignment detected.\n',FCTNAME);
    return
end
    

%--- basis statistics ---
% series of individual FIDs, 1st dim: FIDs, 2nd dim, nr and seriesN
datStatFid  = reshape(permute(fidArray,[2 3 1]),nspecC,seriesN*nr);
% 3 Hz line broadening
lbProc = 3;     % 3 Hz line broadening to reduce dependency on late data points
lbWeightMat = repmat(exp(-lbProc*data.spec1.dwell*(0:nspecC-1)*pi)',[1 nr*seriesN]);
datStatSpec = fftshift(fft(datStatFid.*lbWeightMat,[],1),1);

%--- spectral window extraction: original spectrum ---
[minI,maxI,ppmZoom,specFakeZoom,f_succ] = SP2_Data_ExtractPpmRange(data.frAlignPpm1Min,data.frAlignPpm1Max,...
                                                    data.ppmCalib,data.spec1.sw,abs(datStatSpec(:,1)));
maxAbsVec   = max(abs(datStatSpec(minI:maxI,:)));
maxAbsEdit  = maxAbsVec(1:2:end);         % magnitude peak of edited spectra
maxAbsNEdit = maxAbsVec(2:2:end);         % magnitude peak of non-edited spectra
maxRealVec  = max(real(datStatSpec(minI:maxI,:)));
fwhmHzVec   = zeros(1,nr*seriesN);
for fwhmCnt = 1:nr*seriesN
    [fwhmPts,minFwhmPts,maxFwhmPts,maxAmpl,maxAmplPts,msg] = SP2_FWHM(real(datStatSpec(minI:maxI,fwhmCnt)),1,0);
    fwhmHzVec(fwhmCnt) = fwhmPts*(data.frAlignPpm1Max-data.frAlignPpm1Min)/(maxI-minI)*data.spec1.sf - lbProc;
end

%--- info printout ---
lastVec  = (1:seriesN)*nr;
firstVec = lastVec-(nr-1);
fprintf('Scan ranges:\n');
for sCnt = 1:seriesN
    fprintf('[%.0f %.0f]',firstVec(sCnt),lastVec(sCnt));
    if sCnt<seriesN
        fprintf(', ');
    else
        fprintf('\n');
    end
end
fprintf('Spectral range of all magnitude spectra\n');
fprintf('min/max/mean/SD = %.0f/%.0f/%.0f/%.0f(%.1f%%)\n',min(maxAbsVec),...
        max(maxAbsVec),mean(maxAbsVec),std(maxAbsVec),100*std(maxAbsVec)/mean(maxAbsVec))
fprintf('Spectral range of edited magnitude spectra\n');
fprintf('min/max/mean/SD = %.0f/%.0f/%.0f/%.0f(%.1f%%)\n',min(maxAbsEdit),...
        max(maxAbsEdit),mean(maxAbsEdit),std(maxAbsEdit),100*std(maxAbsEdit)/mean(maxAbsEdit))
fprintf('Spectral range of non-edited magnitude spectra\n');
fprintf('min/max/mean/SD = %.0f/%.0f/%.0f/%.0f(%.1f%%)\n',min(maxAbsNEdit),...
        max(maxAbsNEdit),mean(maxAbsNEdit),std(maxAbsNEdit),100*std(maxAbsNEdit)/mean(maxAbsNEdit))
fprintf('Spectral range of real spectra\n');
fprintf('min/max/mean/SD = %.0f/%.0f/%.0f/%.0f(%.1f%%)\n',min(maxRealVec),...
        max(maxRealVec),mean(maxRealVec),std(maxRealVec),100*std(maxRealVec)/mean(maxRealVec))
fprintf('FWHM of real spectra\n');
fprintf('min/max/mean/SD = %.1f/%.1f/%.1f/%.1fHz(%.1f%%)\n',min(fwhmHzVec),...
        max(fwhmHzVec),mean(fwhmHzVec),std(fwhmHzVec),100*std(fwhmHzVec)/mean(fwhmHzVec))

%--- figure creation ---
if f_plot
    figure
    subplot(4,1,1)
    plot(ppmZoom,datStatSpec(minI:maxI,:))
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,abs(datStatSpec(minI:maxI,1)));
    axis([minX maxX minY-(maxY-minY)/5 maxY+(maxY-minY)/5])
    set(gca,'XDir','reverse')
    xlabel('Frequency [ppm]')
    ylabel('Magn. Amplitude [a.u.]')

    subplot(4,1,2)
    nrVec = 1:size(maxAbsVec,2);
    hold on
    plot(nrVec,maxAbsVec)
    plot(nrVec,maxAbsVec,'r*')
    hold off
    [minX maxX minY maxY] = SP2_IdealAxisValues(nrVec,maxAbsVec);
    axis([minX maxX minY maxY])
    xlabel('FID #')
    ylabel('Magn. Amplitude [a.u.]')

    subplot(4,1,3)
    hold on
    plot(nrVec,maxRealVec)
    plot(nrVec,maxRealVec,'r*')
    hold off
    [minX maxX minY maxY] = SP2_IdealAxisValues(nrVec,maxRealVec);
    axis([minX maxX minY maxY])
    xlabel('FID #')
    ylabel('Real Amplitude [a.u.]')

    subplot(4,1,4)
    hold on
    plot(nrVec,fwhmHzVec)
    plot(nrVec,fwhmHzVec,'r*')
    hold off
    [minX maxX minY maxY] = SP2_IdealAxisValues(nrVec,fwhmHzVec);
    axis([minX maxX minY maxY])
    xlabel('FID #')
    ylabel('FWHM [Hz]')
end

end
