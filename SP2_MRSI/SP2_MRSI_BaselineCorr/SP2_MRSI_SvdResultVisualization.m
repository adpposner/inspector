%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SvdResultVisualization
% %% 
%%  Result visualization of SVD-based peak removal.
%%
%%  06-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

FCTNAME = 'SP2_MRSI_SvdResultVisualization';


%--- consistency check ---
if ~isfield(proc,'svd')
    fprintf('%s ->\nNo peak removal (SVD) result available. Program aborted.\n',FCTNAME);
    return
end

%--- check whether valid peaks were found ---
if mrsi.svd.nValid==0
    fprintf('%s ->\nNone of the SVD peaks falls in the assigned ppm window.\nNo result available.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.mrsiPpmShow     % direct
    ppmMin = mrsi.ppmShowMin;
    ppmMax = mrsi.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -mrsi.svd.sw/2 + mrsi.ppmCalib;
    ppmMax = mrsi.svd.sw/2  + mrsi.ppmCalib;
end

%--- data extraction ---
if flag.mrsiFormat==1           % real part
    for peakCnt = 1:mrsi.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                   mrsi.svd.sw,real(mrsi.svd.specPeak(:,peakCnt)));
    end
    if mrsi.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,real(mrsi.spec1.spec));
    elseif mrsi.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,real(mrsi.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,real(mrsi.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,real(mrsi.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,real(mrsi.svd.specDiff));
elseif flag.mrsiFormat==2       % imaginary part
    for peakCnt = 1:mrsi.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                   mrsi.svd.sw,imag(mrsi.svd.specPeak(:,peakCnt)));
    end
    if mrsi.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,imag(mrsi.spec1.spec));
    elseif mrsi.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,imag(mrsi.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,imag(mrsi.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,imag(mrsi.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,imag(mrsi.svd.specDiff));
else                            % magnitude
    for peakCnt = 1:mrsi.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                                   mrsi.svd.sw,abs(mrsi.svd.specPeak(:,peakCnt)));
    end
    if mrsi.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,abs(mrsi.spec1.spec));
    elseif mrsi.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,abs(mrsi.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,abs(mrsi.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,abs(mrsi.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_MRSI_ExtractPpmRange(ppmMin,ppmMax,mrsi.ppmCalib,...
                                                               mrsi.svd.sw,abs(mrsi.svd.specDiff));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- result visualization ---
mrsi.svdFh = figure;
if mrsi.svd.specNumber==1
    set(mrsi.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Spectrum 1'),...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
elseif mrsi.svd.specNumber==2
    set(mrsi.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Spectrum 2'),...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
else
    set(mrsi.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Export/result spectrum'),...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
end
subplot(3,1,1)
hold on
plot(ppmZoom,origSpecZoom)
plot(ppmZoom,svdSpecZoom,'r')
%plot(ppmZoom(mrsi.svd.indVec),svdSpecZoom(mrsi.svd.indVec),'g')
[minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmZoom,origSpecZoom);
[minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmZoom,svdSpecZoom);
axis([minX maxX min(minY) max(maxY)])
for winCnt = 1:mrsi.baseSvdPpmN
    plot([mrsi.baseSvdPpmMin(winCnt) mrsi.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([mrsi.baseSvdPpmMax(winCnt) mrsi.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
end
hold off
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
set(gca,'XDir','reverse')
legend('orig','SVD')
subplot(3,1,2)
hold on
plot(ppmZoom,svdSpecZoom,'r')
[minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmZoom,svdSpecZoom);
for peakCnt = 1:mrsi.svd.nValid
    plot(ppmZoom,peakSpecZoom{peakCnt}')
    [minX maxX minY(peakCnt+1) maxY(peakCnt+1)] = SP2_IdealAxisValues(ppmZoom,peakSpecZoom{peakCnt}');
end
axis([minX maxX min(minY) max(maxY)])
for winCnt = 1:mrsi.baseSvdPpmN
    plot([mrsi.baseSvdPpmMin(winCnt) mrsi.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([mrsi.baseSvdPpmMax(winCnt) mrsi.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
end
hold off
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
set(gca,'XDir','reverse')
legend('SVD')
subplot(3,1,3)
hold on
plot(ppmZoom,diffSpecZoom)
[minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,diffSpecZoom);
axis([minX maxX minY maxY])
for winCnt = 1:mrsi.baseSvdPpmN
    plot([mrsi.baseSvdPpmMin(winCnt) mrsi.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([mrsi.baseSvdPpmMax(winCnt) mrsi.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
end
hold off
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
set(gca,'XDir','reverse')
legend('orig - SVD')

%--- export handling ---
% note that no data transfer is required for specNumber==3 (expt)
if mrsi.svd.specNumber==1            % spectrum 1
    mrsi.expt.fid    = mrsi.spec1.fid;
    mrsi.expt.sf     = mrsi.spec1.sf;
    mrsi.expt.sw_h   = mrsi.spec1.sw_h;
    mrsi.expt.nspecC = mrsi.spec1.nspecC;
elseif mrsi.svd.specNumber==2
    mrsi.expt.fid    = mrsi.spec2.fid;
    mrsi.expt.sf     = mrsi.spec2.sf;
    mrsi.expt.sw_h   = mrsi.spec2.sw_h;
    mrsi.expt.nspecC = mrsi.spec2.nspecC;
end
