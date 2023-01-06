%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_Dat1SeriesAnalysis
%% 
%%  Basic analysis and quality control of data series 1.
%%
%%  03-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_Dat1SeriesAnalysis';


%--- init success flag ---
f_done = 0;

%--- check data existence ---
if ~isfield(data,'spec1')
    fprintf('%s ->\nSpectral data series 1 does not exist. Load first.\n',FCTNAME);
    return
elseif ~isfield(data.spec1,'fidArr')
    fprintf('%s ->\nSpectral FID series 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- consistency checks ---
if ~flag.dataAllSelect && any(data.select>data.spec1.nr)
    fprintf('%s ->\nSelected FID range exceeds number of repetitions (NR=%.0f).\n',...
            FCTNAME,data.spec1.nr)
    return
end
if length(size(data.spec1.fid))<2
    fprintf('%s -> Data set dimension is too small.\nThis is not a multi-receiver experiment or might have been summed already.\n',FCTNAME);
    return
end
if flag.dataRcvrWeight          % weighted summation
    if ~isfield(data.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load first for weighted summation.\n',FCTNAME);
        return
    end
end

%--- Rx summation ---
if flag.dataRcvrWeight
    %--- weighted summation ---
    if length(size(data.spec2.fid))==3
        weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
    else
        weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
    end
    weightVec         = weightVec/sum(weightVec);
    weightMat         = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
    data.spec1.fidArr = data.spec1.fidArr(:,:,data.rcvrInd,:) .* weightMat;
    data.spec1.fidArr = squeeze(sum(data.spec1.fidArr,3));

    %--- info printout ---
    fprintf('Amplitude-weighted summation of Rx channels applied:\n');
    fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
else
    %--- non-weighted summation ---
    data.spec1.fidArr = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:),3));

    %--- info printout ---
    fprintf('Non-weighted summation of Rx channels applied:\n');
end
fprintf('Channels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));
        
%--- FID summation ---
if flag.dataAllSelect           % all FIDs (NR)
    %--- data order: experiment series, FID, NR (with alternating edited/non-edited) ---
    data.spec1.fid = conj(mean(mean(data.spec1.fidArr(:,:,1:2:data.spec1.nr),3),1)');

    %--- info printout ---
    fprintf('All FID''s summed, i.e. no selection applied\n');
else                            % selected FID range
    %--- basis statistics ---
    if flag.verbose
        SP2_Data_Dat1SeriesStatistics(data.spec1.fidArr(:,:,data.select),data.select,flag.dataAlignVerbose)
    end
end




%--- basis statistics ---
% series of individual FIDs, 1st dim: FIDs, 2nd dim, nr and seriesN
datStatFid  = reshape(permute(fidArray,[2 3 1]),nspecC,seriesN*nr);
% 3 Hz line broadening
lbProc = 3;     % 3 Hz line broadening to reduce dependency on late data points
lbWeightMat = repmat(exp(-lbProc*data.spec1.dwell*(0:nspecC-1)*pi)',[1 nr*seriesN]);
datStatSpec = fftshift(fft(datStatFid.*lbWeightMat,[],1),1);

%--- spectral window extraction: original spectrum ---
[minI,maxI,ppmZoom,specFakeZoom,f_succ] = SP2_Data_ExtractPpmRange(data.frAlignPpmMin,data.frAlignPpmMax,...
                                                    data.ppmCalib,data.spec1.sw,abs(datStatSpec(:,1)));
maxAbsVec   = max(abs(datStatSpec(minI:maxI,:)));
maxAbsEdit  = maxAbsVec(1:2:end);         % magnitude peak of edited spectra
maxAbsNEdit = maxAbsVec(2:2:end);         % magnitude peak of non-edited spectra
maxRealVec  = max(real(datStatSpec(minI:maxI,:)));
fwhmHzVec   = zeros(1,nr*seriesN);
for fwhmCnt = 1:nr*seriesN
    [fwhmPts,minFwhmPts,maxFwhmPts,maxAmpl,maxAmplPts,msg] = SP2_FWHM(real(datStatSpec(minI:maxI,fwhmCnt)),1,0);
    fwhmHzVec(fwhmCnt) = fwhmPts*(data.frAlignPpmMax-data.frAlignPpmMin)/(maxI-minI)*data.spec1.sf - lbProc;
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

%--- update success flag ---
f_done = 1;



end
