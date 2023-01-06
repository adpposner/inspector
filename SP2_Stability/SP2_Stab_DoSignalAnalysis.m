%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Stab_DoSignalAnalysis
%%
%%  Stability analysis of spectral signals:
%% 
%% (1) check for base line offset and maximum ratio
%% (2) check global noise standard deviation
%% (3) check for frequency range dependence of noise
%%
%%  01-2011, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global stab flag

FCTNAME = 'SP2_Stab_DoSignalAnalysis';


%--- output parameters ---
f_plotMean    = 1;                  % horizontal red line to assign mean values of the window based analysis
nPtsVertBar   = 100;                % number of points to be used to plot the green vertical bars
f_setPlotLims = 0;                  % direct assignment of plotting limits
specLims      = [-5e6 5e6];         % amplitude limits of noise spectrum
stdLims       = [5e5 2e7];          % amplitude limits of std. deviations
meanLims      = [-2e5 1e7];         % amplitude limits of means
f_debug       = 1;


%--- init success flag ---
f_done = 0;

% %--- check data existence ---
% if ~isfield(data.spec1,'fid')
%     if ~SP2_Data_Dat1FidFileLoad(0)
%         fprintf('%s ->\nData loading failed. Program aborted.\n\n',FCTNAME);
%         return
%     end
% end

%--- data assignment ---
if ~SP2_Stab_DataAssignment
    fprintf('%s ->\nData assignment failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- parameter consistency checks ---
if stab.specLast>stab.nr
    fprintf('%s ->\nLast spectrum number must not exceed the data set dimension (%.0f)!.\nProgram aborted.\n',FCTNAME,stab.nr);
    return
end
if stab.specSel>stab.specLast
    fprintf('%s ->\nSelected spectrum number must not last considered spectrum (%.0f)!.\nProgram aborted.\n',FCTNAME,stab.specLast);
    return
end

%--- exponential line broadening ---
% lb = 3;     % line broadening [Hz]
% lbWeight = exp(-lb*stab.dwell*(0:stab.nspecC-1)*pi/2);
% for fidCnt = 1:data.nr*data.nRcvrs^2
%     stab.fid(:,fidCnt) = stab.fid(:,fidCnt) .* lbWeight';
% end

%--- zero-filling ---
flag.stabZf = 1;
stab.zf = 16*1024;

%--- spectral FFT --------------------
if flag.stabRealMagn        % real part
    if flag.stabZf
        stab.ana.spec   = real(fftshift(fft(stab.fid,stab.zf,1),1));
        stab.ana.nspecC = size(stab.ana.spec,1);
    else
        stab.ana.spec   = real(fftshift(fft(stab.fid,[],1),1));
        stab.ana.nspecC = stab.nspecC;
    end
else                        % magnitude spectrum
    if flag.stabZf
        stab.ana.spec   = abs(fftshift(fft(stab.fid,stab.zf,1),1));
        stab.ana.nspecC = size(stab.ana.spec,1);
    else
        stab.ana.spec   = abs(fftshift(fft(stab.fid,[],1),1));
        stab.ana.nspecC = stab.nspecC;
    end
end

%--- data extraction ---
% if data.spec1.nRcvrs>1
%     stab.spec = squeeze(stab.spec(:,stab.rcvr:data.nRcvrs:data.nRcvrs^2,:));
% end

% %--- data extraction ---
% % inner loop: transmit
% % middle loop: receiver
% % outer loop: repetitions NR
% % i.e. the first 8 spectra represent the 8 receivers after excitation with
% % channel 1 only; the 2nd 8 spectra show the 8 receiver signals after
% % excitation with transmit channel 2 and so on.
% % note that all spectra (NR) are chosen here, since the selection of
% % particular NR's is done later in the particular plotting functions
% if data.spec1.nRcvrs>1
%     stab.spec = stab.specCompl(:,(stab.trans-1)*data.nRcvrs+stab.rcvr:data.nRcvrs^2:data.nr*data.nRcvrs^2);
% else
%     stab.spec = stab.specCompl;
% end

%----------------------------------------------------------------------------
%=== N O I S E   A N A L Y S I S ============================================
%----------------------------------------------------------------------------
%--- number of spectra to be analyzed ---
nSpec = stab.specLast - stab.specFirst +1;

%--- check for frequency range dependence of noise ---
minPpm     = zeros(1,stab.ppmBins);             % lower ppm limit of considered spectral region/bin
maxPpm     = zeros(1,stab.ppmBins);             % upper ppm limit of considered spectral region/bin
centPpm    = zeros(1,stab.ppmBins);             % center ppm value of considered spectral region/bin
minInd     = zeros(1,stab.ppmBins);             % index start for considered spectral region/bin
maxInd     = zeros(1,stab.ppmBins);             % index end for considered spectral region/bin
binMean    = zeros(stab.ppmBins,stab.nr);         % mean values from all spectral bins from all spectra
binMax     = zeros(stab.ppmBins,stab.nr);         % maximum values from all spetral bins from all spectra
binStd     = zeros(stab.ppmBins,stab.nr);         % std.deviations from all spectral bins from all spectra
binStdComp = zeros(stab.ppmBins,stab.nr);         % comparison std.deviations: local vs. global

%--- lower/upper ppm and index limits of spectral windows ---
for bCnt = 1:stab.ppmBins
    minPpm(bCnt) = -stab.sw/2 + stab.ppmCalib + (bCnt-1)*stab.sw/stab.ppmBins;      % lower ppm limit of considered noise region
    maxPpm(bCnt) = minPpm(bCnt) + stab.sw/stab.ppmBins;                             % upper ppm limit of considered noise region
    % determination of correspondind indices
    [minInd(bCnt),maxInd(bCnt),ppmVec,specVec] = SP2_Stab_ExtractPpmRange(minPpm(bCnt),maxPpm(bCnt),stab.ppmCalib,stab.sw,stab.ana.spec(:,1));
    centPpm(bCnt) = (minPpm(bCnt) + maxPpm(bCnt))/2;                                      % center frequencies [ppm] of spectral windows    
end

%--- calculation of global base line offset and global standard deviation ---
totalMean = mean(stab.ana.spec,1)';
totalMax  = max(stab.ana.spec,[],1)';
totalStd  = std(stab.ana.spec,0,1)';
stab.rangeMean = mean(stab.ana.spec(:,stab.specFirst:stab.specLast),1)';
stab.rangeMax  = max(stab.ana.spec(:,stab.specFirst:stab.specLast),[],1)';
stab.rangeStd  = std(stab.ana.spec(:,stab.specFirst:stab.specLast),0,1)';


%--- further analysis of total, i.e. spectrum statistics  ---
fprintf('Entire frequency range of selected spectra:\n');
fprintf('Series mean:     mean %.0f, SD %.0f (%.1f%%)\n',...
        mean(stab.rangeMean),std(stab.rangeMean),100*std(stab.rangeMean)/mean(stab.rangeMean))
fprintf('Series max:      mean %.0f, SD %.0f (%.1f%%)\n',...
        mean(stab.rangeMax),std(stab.rangeMax),100*std(stab.rangeMax)/mean(stab.rangeMax))
fprintf('Series std.dev.: mean %.0f, SD %.0f (%.1f%%)\n',...
        mean(stab.rangeStd),std(stab.rangeStd),100*std(stab.rangeStd)/mean(stab.rangeStd))


%--- frequency range dependence of noise ---
for bCnt = 1:stab.ppmBins
    binSpec = stab.ana.spec(minInd(bCnt):maxInd(bCnt),:);
    binMean(bCnt,:)    = mean(binSpec,1);           % average value of noise region
    binMax(bCnt,:)     = max(binSpec,[],1);         % maximum value of noise region
    binStd(bCnt,:)     = std(binSpec,0,1);          % standard deviation of noise
    binStdComp(bCnt,:) = 100*binStd(bCnt,:)./binMean(bCnt,:);  
end

%--- create printout for selected spectrum ---
if flag.stabTotSel
    fprintf('\nFrequency window analysis (scan %.0f, %i frequency bins of %.0f Hz each):\n',...
            stab.specSel,stab.ppmBins,stab.sw_h/stab.ppmBins)
    maxLenMinPpm = 0;
    maxLenMaxPpm = 0;
    maxLenMean   = 0;
    maxLenStdDev = 0;
    for bCnt = 1:stab.ppmBins
        if length(sprintf('%.1f',minPpm(bCnt)))>maxLenMinPpm;    
            maxLenMinPpm = length(sprintf('%.1f',minPpm(bCnt)));
        end
        if length(sprintf('%.1f',maxPpm(bCnt)))>maxLenMaxPpm;    
            maxLenMaxPpm = length(sprintf('%.1f',maxPpm(bCnt)));
        end
        if length(sprintf('%.0f',round(binMean(bCnt,1))))>maxLenMean;    
            maxLenMean = length(sprintf('%.0f',round(binMean(bCnt,stab.specSel))));
        end
        if length(sprintf('%.0f',round(binStd(bCnt,1))))>maxLenStdDev;    
            maxLenStdVec = length(sprintf('%.0f',round(binStd(bCnt,stab.specSel))));
        end
    end

    for bCnt = 1:stab.ppmBins
        printStr = sprintf('%.0f) ',bCnt);
        numLen = length(sprintf('%.1f',minPpm(bCnt)));
        for jcnt = 1:maxLenMinPpm-numLen
            printStr = [printStr ' '];
        end
        printStr = [printStr '%.2f to '];
        numLen = length(sprintf('%.2f',maxPpm(bCnt)));
        for jcnt = 1:maxLenMaxPpm-numLen
            printStr = [printStr ' '];
        end
        printStr = [printStr '%.2fppm  \tmean='];
        numLen = length(sprintf('%.2f',binMean(bCnt,stab.specSel)));
        for jcnt = 1:maxLenMean-numLen+2
            printStr = [printStr ' '];
        end
        
        printStr = [printStr '%.0f  \tmax='];
        numLen = length(sprintf('%.0f',binMax(bCnt,stab.specSel)));
        for jcnt = 1:maxLenMean-numLen+2
            printStr = [printStr ' '];
        end
        printStr = [printStr '%.0f (%.1f%% of max) \tSD='];
        numLen = length(sprintf('%.0f (%.1f%%) ',binMax(bCnt,stab.specSel),100*binMax(bCnt,stab.specSel)/max(stab.rangeMax)));
        for jcnt = 1:maxLenMean-numLen+2
            printStr = [printStr ' '];
        end
        
        printStr = [printStr ''];
        numLen = length(sprintf(' (%.1f%%)',binStd(bCnt,stab.specSel)));
        for jcnt = 1:maxLenStdDev-numLen+2
            printStr = [printStr ' '];
        end
        printStr = [printStr '%.0f (%.1f%% of mean)'];
        printStr = [printStr '\n'];
        iniStr   = 'fprintf(''';
        varStr   = ''',minPpm(1,bCnt),maxPpm(1,bCnt),binMean(bCnt,stab.specSel),binMax(bCnt,stab.specSel),100*binMax(bCnt,stab.specSel)/max(binMax(:,stab.specSel)),binStd(bCnt,stab.specSel),binStdComp(bCnt,stab.specSel))';
        eval([ iniStr printStr varStr ])
    end    

    %--- additional analysis calculations ---
    fprintf('global:  mean=%.0f, max=%.0f, std.=%.0f, mean/std.=%.3f, max(abs)/std.=%.3f\n',...
            stab.rangeMean(stab.specSel),stab.rangeMax(stab.specSel),...
            stab.rangeStd(stab.specSel),stab.rangeMean(stab.specSel)/stab.rangeStd(stab.specSel),...
            stab.rangeMax(stab.specSel)/stab.rangeStd(stab.specSel))
    fprintf('windows: std(mean(window)/std(global))=%.3f, std(std(window)/std(global))=%.3f\n',...
            std(binMean(:,stab.specSel)./stab.rangeStd(stab.specSel)),...
            std(binStdComp(:,stab.specSel)))
end    

%--- result figure ---
% frequency-bin analysis of selected spectrum
if flag.stabTotSel
    figh1 = figure;
    set(figh1,'NumberTitle','off','Name',sprintf('  Spectrum #%.0f: Noise & Baseline Analysis',stab.specSel),...
              'Position',[521 105 691 665]);
    subplot(3,1,1)
    ppmVec = -stab.sw/2+stab.ppmCalib:(stab.sw/(stab.ana.nspecC-1)):stab.sw/2+stab.ppmCalib;       % symmetrical case
    [minX maxX minY maxY] = SP2_IdealAxisValues(ppmVec,stab.ana.spec(:,stab.specSel));
    if f_setPlotLims
        minY = specLims(1);
        maxY = specLims(2);
    end
    hold on
        for bCnt=1:stab.ppmBins-1
            lh = line([maxPpm(1,bCnt) maxPpm(1,bCnt)],[minY maxY]);
            set(lh,'Color',[0 1 0],'LineStyle','-.')
        end
        plot(ppmVec,stab.ana.spec(:,stab.specSel))    
    hold off
    set(gca,'XDir','reverse')
    titlestr = sprintf('Spectrum #%.0f, Calibration %.2f ppm',stab.specSel,stab.ppmCalib);
    title(titlestr)
    axis([minX maxX minY maxY])
    fprintf('plotting limits: noise spectrum [%.0f %.0f]\n',minY,maxY);
    subplot(3,1,2)
    [minXfake maxXfake minY maxY] = SP2_IdealAxisValues(centPpm,binStd(:,stab.specSel));
    if f_setPlotLims
        minY = stdLims(1);
        maxY = stdLims(2);
    end    
    plot(centPpm,binStd(:,stab.specSel))
    hold on
        for bCnt=1:stab.ppmBins-1
            lh = line([maxPpm(1,bCnt) maxPpm(1,bCnt)],[minY maxY]);
            set(lh,'Color',[0 1 0],'LineStyle','-.')
        end
        if f_plotMean
            plot(minX:(maxX-minX)/nPtsVertBar:maxX,stab.rangeStd(stab.specSel):1/nPtsVertBar:stab.rangeStd(stab.specSel),'r')
        end
        plot(centPpm,binStd(:,stab.specSel),'r+')
    hold off
    set(gca,'XDir','reverse')
    axis([minX maxX minY maxY])
    text(minX+(maxX-minX)/4.6,maxY-(maxY-minY)/10,'standard deviation')
    meanstr = sprintf('global: %.0f',stab.rangeStd(stab.specSel));
    text(minX+(maxX-minX)/1.05,maxY-(maxY-minY)/10,meanstr)
    fprintf('plotting limits: std. deviation [%.0f %.0f]\n',minY,maxY);
    subplot(3,1,3)
    [minXfake maxXfake minY maxY] = SP2_IdealAxisValues(centPpm,binMean(:,stab.specSel));
    if f_setPlotLims
        minY = meanLims(1);
        maxY = meanLims(2);
    end    
    plot(centPpm,binMean(:,stab.specSel))
    hold on
        for bCnt=1:stab.ppmBins-1
            lh = line([maxPpm(1,bCnt) maxPpm(1,bCnt)],[minY maxY]);
            set(lh,'Color',[0 1 0],'LineStyle','-.')
        end
        if f_plotMean
            plot(minX:(maxX-minX)/nPtsVertBar:maxX,stab.rangeMean(stab.specSel):1/nPtsVertBar:stab.rangeMean(stab.specSel),'r')
        end
        plot(centPpm,binMean(:,stab.specSel),'r+')
    hold off
    set(gca,'XDir','reverse')
    axis([minX maxX minY maxY])
    text(minX+(maxX-minX)/8.1,maxY-(maxY-minY)/10,'baseline')
    meanstr = sprintf('mean: %.0f',stab.rangeMean(stab.specSel));
    text(minX+(maxX-minX)/1.05,maxY-(maxY-minY)/10,meanstr)
    xlabel('frequency [ppm]')
    fprintf('plotting limits: mean [%.0f %.0f]\n',minY,maxY);
end

%--- range analysis statistics ---
if flag.stabTotAll && nSpec>1
    figh1 = figure;
    set(figh1,'NumberTitle','off','Name',sprintf(' Non-Frequency Selective Analysis of Spectrum Range NR %.0f..%.0f',stab.specFirst,stab.specLast),...
              'Position',[521 105 691 665]);
    subplot(3,1,1)
    plot(1:nSpec,stab.rangeStd)
    [minX maxX minY maxY] = SP2_IdealAxisValuesXGap(1:nSpec,stab.rangeStd);
    axis([minX maxX minY maxY])
    set(gca,'XTickLabel',get(gca,'XTick')+stab.specFirst-1)
    text(minX+(maxX-minX)/40,maxY-(maxY-minY)/8,'Std.Dev.')
    subplot(3,1,2)
    plot(1:nSpec,stab.rangeMean)
    [minX maxX minY maxY] = SP2_IdealAxisValuesXGap(1:nSpec,stab.rangeMean);
    axis([minX maxX minY maxY])
    set(gca,'XTickLabel',get(gca,'XTick')+stab.specFirst-1)
    text(minX+(maxX-minX)/40,maxY-(maxY-minY)/8,'Mean')
    subplot(3,1,3)
    plot(1:nSpec,stab.rangeMax)
    [minX maxX minY maxY] = SP2_IdealAxisValuesXGap(1:nSpec,stab.rangeMax);
    axis([minX maxX minY maxY])
    set(gca,'XTickLabel',get(gca,'XTick')+stab.specFirst-1)
    text(minX+(maxX-minX)/40,maxY-(maxY-minY)/8,'Max')
    xlabel('Scan #')
end

%--- range analysis printout ---
if flag.stabTotAll
    totFig = figure;
    set(totFig,'NumberTitle','off','Position',[199 156 801 642],...
               'Name',sprintf('  Frequency Bin Analysis of Spectra %.0f..%.0f',stab.specFirst,stab.specLast));
    subplot(3,1,1)
    img1 = imagesc(binStd(:,stab.specFirst:stab.specLast));
    set(gca,'XTickLabel',get(gca,'XTick')+stab.specFirst-1)
    colorbar
    ylabel('Std.Dev. of Bins')
    subplot(3,1,2)
    img2 = imagesc(binMean(:,stab.specFirst:stab.specLast));
    set(gca,'XTickLabel',get(gca,'XTick')+stab.specFirst-1)
    colorbar
    ylabel('Mean of Bins')
    subplot(3,1,3)
    img3 = imagesc(binMax(:,stab.specFirst:stab.specLast));
    set(gca,'XTickLabel',get(gca,'XTick')+stab.specFirst-1)
    colorbar
    ylabel('Maximum of Bins')
    xlabel('Scan #')
end

%--- bin-specific analysis statistics ---
if flag.stabBinAll
    %--- consistency check ---    
    if stab.ppmBinSel>stab.ppmBins
        fprintf('%s ->\nSelected bin must not exceed total number of bins. Program aborted.\n',FCTNAME);
        return
    end
    if stab.specFirst==stab.specLast
        fprintf('%s ->\nRange of bins must be larger than 1 for bin statistics. Program aborted.\n',FCTNAME);
        return
    end
    
    %--- further analysis of range, i.e. spectrum statistics  ---
    fprintf('Bin %.0f, %.2f..%.2fppm:\n',stab.ppmBinSel,minPpm(stab.ppmBinSel),maxPpm(stab.ppmBinSel));
    fprintf('Series mean:     mean %.0f, SD %.0f (%.1f%%)\n',...
            mean(binMean(stab.ppmBinSel,stab.specFirst:stab.specLast)),std(binMean(stab.ppmBinSel,stab.specFirst:stab.specLast)),100*std(binMean(stab.ppmBinSel,stab.specFirst:stab.specLast))/mean(binMean(stab.ppmBinSel,stab.specFirst:stab.specLast)))
    fprintf('Series max:      mean %.0f, SD %.0f (%.1f%%)\n',...
            mean(binMax(stab.ppmBinSel,stab.specFirst:stab.specLast)),std(binMax(stab.ppmBinSel,stab.specFirst:stab.specLast)),100*std(binMax(stab.ppmBinSel,stab.specFirst:stab.specLast))/mean(binMax(stab.ppmBinSel,stab.specFirst:stab.specLast)))
    fprintf('Series std.dev.: mean %.0f, SD %.0f (%.1f%%)\n',...
            mean(binStd(stab.ppmBinSel,stab.specFirst:stab.specLast)),std(binStd(stab.ppmBinSel,stab.specFirst:stab.specLast)),100*std(binStd(stab.ppmBinSel,stab.specFirst:stab.specLast))/mean(binStd(stab.ppmBinSel,stab.specFirst:stab.specLast)))
    
    %--- figure createion ---
    figh1 = figure;
    nameStr = sprintf('  Frequency Range-Specific Series Analysis of Spectra %.0f..%.0f: Bin %.0f, %.2f..%.2fppm',...
                      stab.specFirst,stab.specLast,stab.ppmBinSel,minPpm(stab.ppmBinSel),maxPpm(stab.ppmBinSel));
    set(figh1,'NumberTitle','off','Name',nameStr,'Position',[521 105 691 665]);
    subplot(3,1,1)
    plot(stab.specFirst:stab.specLast,binMean(stab.ppmBinSel,stab.specFirst:stab.specLast))
    [minX maxX minY maxY] = SP2_IdealAxisValues(stab.specFirst:stab.specLast,binMean(stab.ppmBinSel,stab.specFirst:stab.specLast));
    axis([minX maxX minY maxY])
    text(minX+(maxX-minX)/40,maxY-(maxY-minY)/8,'Mean')
    subplot(3,1,2)
    plot(stab.specFirst:stab.specLast,binMax(stab.ppmBinSel,stab.specFirst:stab.specLast))
    [minX maxX minY maxY] = SP2_IdealAxisValues(stab.specFirst:stab.specLast,binMax(stab.ppmBinSel,stab.specFirst:stab.specLast));
    axis([minX maxX minY maxY])
    text(minX+(maxX-minX)/40,maxY-(maxY-minY)/8,'Max')
    subplot(3,1,3)
    plot(stab.specFirst:stab.specLast,binStd(stab.ppmBinSel,stab.specFirst:stab.specLast))
    [minX maxX minY maxY] = SP2_IdealAxisValues(stab.specFirst:stab.specLast,binStd(stab.ppmBinSel,stab.specFirst:stab.specLast));
    axis([minX maxX minY maxY])
    text(minX+(maxX-minX)/40,maxY-(maxY-minY)/8,'Std.Dev.')
end

%--- update success flag ---
f_done = 1;

end
