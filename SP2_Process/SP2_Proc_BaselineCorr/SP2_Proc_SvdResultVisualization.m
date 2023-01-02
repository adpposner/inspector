%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SvdResultVisualization
% %% 
%%  Result visualization of SVD-based peak removal.
%%
%%  06-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_SvdResultVisualization';


%--- consistency check ---
if ~isfield(proc,'svd')
    fprintf('%s ->\nNo peak removal (SVD) result available. Program aborted.\n',FCTNAME);
    return
end

%--- check whether valid peaks were found ---
if proc.svd.nValid==0
    fprintf('%s ->\nNone of the SVD peaks falls in the assigned ppm window.\nNo result available.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.procPpmShow     % direct
    ppmMin = proc.ppmShowMin;
    ppmMax = proc.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -proc.svd.sw/2 + proc.ppmCalib;
    ppmMax = proc.svd.sw/2  + proc.ppmCalib;
end

%--- data extraction ---
if flag.procFormat==1           % real part
    for peakCnt = 1:proc.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                                   proc.svd.sw,real(proc.svd.specPeak(:,peakCnt)));
    end
    if proc.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,real(proc.spec1.spec));
    elseif proc.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,real(proc.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,real(proc.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,real(proc.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,real(proc.svd.specDiff));
elseif flag.procFormat==2       % imaginary part
    for peakCnt = 1:proc.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                                   proc.svd.sw,imag(proc.svd.specPeak(:,peakCnt)));
    end
    if proc.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,imag(proc.spec1.spec));
    elseif proc.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,imag(proc.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,imag(proc.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,imag(proc.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,imag(proc.svd.specDiff));
else                            % magnitude
    for peakCnt = 1:proc.svd.nValid
        [minIZoom,maxIZoom,ppmZoom,peakSpecZoom{peakCnt},f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                                   proc.svd.sw,abs(proc.svd.specPeak(:,peakCnt)));
    end
    if proc.svd.specNumber==1           % spectrum 1
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,abs(proc.spec1.spec));
    elseif proc.svd.specNumber==2       % spectrum 2
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,abs(proc.spec2.spec));
    else                                % export
        [minIZoom,maxIZoom,ppmZoom,origSpecZoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,abs(proc.expt.spec));
    end
    [minIZoom,maxIZoom,ppmZoom,svdSpecZoom,f_done]   = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,abs(proc.svd.spec));
    [minIZoom,maxIZoom,ppmZoom,diffSpecZoom,f_done]  = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.svd.sw,abs(proc.svd.specDiff));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- result visualization ---
proc.svdFh = figure;
if proc.svd.specNumber==1
    set(proc.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Spectrum 1'),...
        'Position',[378 -2 769 850],'Color',[1 1 1],'Tag','Proc');
elseif proc.svd.specNumber==2
    set(proc.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Spectrum 2'),...
        'Position',[378 -2 769 850],'Color',[1 1 1],'Tag','Proc');
else
    set(proc.svdFh,'NumberTitle','off','Name',sprintf(' SVD Peak Removal: Export/result spectrum'),...
        'Position',[378 -2 769 850],'Color',[1 1 1],'Tag','Proc');
end
subplot(3,1,1)
hold on
plot(ppmZoom,origSpecZoom)
plot(ppmZoom,svdSpecZoom,'r')
%plot(ppmZoom(proc.svd.indVec),svdSpecZoom(proc.svd.indVec),'g')
[minX maxX minY(1) maxY(1)] = SP2_IdealAxisValues(ppmZoom,origSpecZoom);
[minX maxX minY(2) maxY(2)] = SP2_IdealAxisValues(ppmZoom,svdSpecZoom);
axis([minX maxX min(minY) max(maxY)])
for winCnt = 1:proc.baseSvdPpmN
    plot([proc.baseSvdPpmMin(winCnt) proc.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([proc.baseSvdPpmMax(winCnt) proc.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
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
for peakCnt = 1:proc.svd.nValid
    plot(ppmZoom,peakSpecZoom{peakCnt}')
    [minX maxX minY(peakCnt+1) maxY(peakCnt+1)] = SP2_IdealAxisValues(ppmZoom,peakSpecZoom{peakCnt}');
end
axis([minX maxX min(minY) max(maxY)])
for winCnt = 1:proc.baseSvdPpmN
    plot([proc.baseSvdPpmMin(winCnt) proc.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([proc.baseSvdPpmMax(winCnt) proc.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
end
hold off
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
set(gca,'XDir','reverse')
legCell = {};
legCell{1} = 'total SVD';
for peakCnt = 1:proc.svd.nValid
    legCell{peakCnt+1} = sprintf('Peak %.0f',peakCnt);
end
legend(legCell)
subplot(3,1,3)
hold on
plot(ppmZoom,diffSpecZoom)
[minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,diffSpecZoom);
axis([minX maxX minY maxY])
for winCnt = 1:proc.baseSvdPpmN
    plot([proc.baseSvdPpmMin(winCnt) proc.baseSvdPpmMin(winCnt)],[min(minY) max(maxY)],'g')
    plot([proc.baseSvdPpmMax(winCnt) proc.baseSvdPpmMax(winCnt)],[min(minY) max(maxY)],'g')
end
hold off
ylabel('Amplitude [a.u.]')
xlabel('Frequency [ppm]')
set(gca,'XDir','reverse')
legend('orig - SVD')

%--- export handling ---
% note that no data transfer is required for specNumber==3 (expt)
if proc.svd.specNumber==1            % spectrum 1
    proc.expt.fid    = proc.spec1.fid;
    proc.expt.sf     = proc.spec1.sf;
    proc.expt.sw_h   = proc.spec1.sw_h;
    proc.expt.nspecC = proc.spec1.nspecC;
elseif proc.svd.specNumber==2
    proc.expt.fid    = proc.spec2.fid;
    proc.expt.sf     = proc.spec2.sf;
    proc.expt.sw_h   = proc.spec2.sw_h;
    proc.expt.nspecC = proc.spec2.nspecC;
end
