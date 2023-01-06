%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_SvdResultVisualization
% %% 
%%  Result visualization of SVD-based peak removal.
%%
%%  06-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_SvdResultVisualization';


%--- consistency check ---
if ~isfield(proc,'svd')
    fprintf('%s ->\nNo peak removal (SVD) result available. Program aborted.\n',FCTNAME);
    return
end

%--- check whether valid peaks were found ---
if lcm.svd.nValid==0
    fprintf('%s ->\nNone of the SVD peaks falls in the assigned ppm window.\nNo result available.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.lcmPpmShow     % direct
    ppmMin = lcm.ppmShowMin;
    ppmMax = lcm.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -lcm.svd.sw/2 + lcm.ppmCalib;
    ppmMax = lcm.svd.sw/2  + lcm.ppmCalib;
end

%--- data extraction ---
if flag.lcmFormat==1           % real part
    for peakCnt = 1:lcm.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                                   lcm.svd.sw,real(lcm.svd.specPeak(:,peakCnt)));
    end
    if lcm.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,real(lcm.spec1.spec));
    elseif lcm.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,real(lcm.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,real(lcm.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,real(lcm.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,real(lcm.svd.specDiff));
elseif flag.lcmFormat==2       % imaginary part
    for peakCnt = 1:lcm.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                                   lcm.svd.sw,imag(lcm.svd.specPeak(:,peakCnt)));
    end
    if lcm.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,imag(lcm.spec1.spec));
    elseif lcm.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,imag(lcm.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,imag(lcm.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,imag(lcm.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,imag(lcm.svd.specDiff));
else                            % magnitude
    for peakCnt = 1:lcm.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                                   lcm.svd.sw,abs(lcm.svd.specPeak(:,peakCnt)));
    end
    if lcm.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,abs(lcm.spec1.spec));
    elseif lcm.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,abs(lcm.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,abs(lcm.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,abs(lcm.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.ppmCalib,...
                                                               lcm.svd.sw,abs(lcm.svd.specDiff));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- result visualization ---
lcm.svdFh = figure;
if lcm.svd.specNumber==1
    set(lcm.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Spectrum 1'),...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
elseif lcm.svd.specNumber==2
    set(lcm.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Spectrum 2'),...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
else
    set(lcm.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Export/result spectrum'),...
        'Position',[378 -2 769 850],'Color',[1 1 1]);
end
subplot(3,1,1)
hold on
plot(ppmZoom,origSpecZoom)
plot(ppmZoom,svdSpecZoom,'r')
%plot(ppmZoom(lcm.svd.indVec),svdSpecZoom(lcm.svd.indVec),'g')
[minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmZoom,origSpecZoom);
[minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmZoom,svdSpecZoom);
axis([minX maxX min(minY) max(maxY)])
for winCnt = 1:lcm.baseSvdPpmN
    plot([lcm.baseSvdPpmMin(winCnt) lcm.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([lcm.baseSvdPpmMax(winCnt) lcm.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
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
for peakCnt = 1:lcm.svd.nValid
    plot(ppmZoom,peakSpecZoom{peakCnt}')
    [minX maxX minY(peakCnt+1) maxY(peakCnt+1)] = SP2_IdealAxisValues(ppmZoom,peakSpecZoom{peakCnt}');
end
axis([minX maxX min(minY) max(maxY)])
for winCnt = 1:lcm.baseSvdPpmN
    plot([lcm.baseSvdPpmMin(winCnt) lcm.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([lcm.baseSvdPpmMax(winCnt) lcm.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
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
for winCnt = 1:lcm.baseSvdPpmN
    plot([lcm.baseSvdPpmMin(winCnt) lcm.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([lcm.baseSvdPpmMax(winCnt) lcm.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
end
hold off
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
set(gca,'XDir','reverse')
legend('orig - SVD')

%--- export handling ---
% note that no data transfer is required for specNumber==3 (expt)
if lcm.svd.specNumber==1            % spectrum 1
    lcm.expt.fid    = lcm.spec1.fid;
    lcm.expt.sf     = lcm.spec1.sf;
    lcm.expt.sw_h   = lcm.spec1.sw_h;
    lcm.expt.nspecC = lcm.spec1.nspecC;
elseif lcm.svd.specNumber==2
    lcm.expt.fid    = lcm.spec2.fid;
    lcm.expt.sf     = lcm.spec2.sf;
    lcm.expt.sw_h   = lcm.spec2.sw_h;
    lcm.expt.nspecC = lcm.spec2.nspecC;
end

end
