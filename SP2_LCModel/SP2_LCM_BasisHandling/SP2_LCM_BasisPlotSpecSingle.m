%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_BasisPlotSpecSingle( nMetab, f_verbose )
%%
%%  Function to show FID of individual metabolite.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm flag

FCTNAME = 'SP2_LCM_BasisPlotSpecSingle';


%--- init success flag ---
f_succ = 0;

%--- consistency checks ---
if ~SP2_Check4IntBigger0(nMetab)
    return
end
if nMetab>lcm.basis.n
    fprintf('%s ->\nOnly %.0f metabolites supported. Program aborted.\n',FCTNAME,nMetab);
    return
end

%--- consistency check ---
if nMetab>lcm.basis.nLim
    fprintf('Assigned basis position is outside the allowable range (0..%.0f)\n',lcm.basis.n);
    fprintf('Program aborted.\n');
    return
end

%--- check data existence ---
if ~isfield(lcm.basis,'data')
    fprintf('No FID data found. Visualization of LCM basis function aborted.\n');
    return
end

%--- data reconstruction ---
if ~SP2_LCM_BasisProcData(nMetab)
    fprintf('Spectral reconstruction of basis FID failed. Program aborted.\n');
    return
end

%--- keep index of metabolite ---
lcm.basis.currShow = nMetab;

%--- ppm limit handling ---
if flag.lcmPpmShow     % direct
    ppmMin = lcm.ppmShowMin;
    ppmMax = lcm.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -lcm.basis.sw/2 + lcm.basis.ppmCalib;
    ppmMax = lcm.basis.sw/2  + lcm.basis.ppmCalib;
end

%--- data extraction: spectrum 1 ---
[minI,maxI,ppmZoom,specZoom,f_done] = SP2_LCM_ExtractPpmRange(ppmMin,ppmMax,lcm.basis.ppmCalib,...
                                                              lcm.basis.sw,real(lcm.basis.spec));
if ~f_done
    fprintf('%s ->\nppm extraction failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(lcm,'fhBasisSpec') && ishandle(lcm.fhBasisSpec)
    lcm.fig.fhBasisSpec = get(lcm.fhBasisSpec,'Position');
end

%--- figure creation ---
% create figure if necessary
if ~isfield(lcm,'fhBasisSpec') || ~ishandle(lcm.fhBasisSpec)
    lcm.fhBasisSpec = figure('IntegerHandle','off');
    set(lcm.fhBasisSpec,'NumberTitle','off','Name',sprintf(' Spectrum <%s>',lcm.basis.data{nMetab}{1}),...
        'Position',lcm.fig.fhBasisSpec,'Color',[1 1 1],'Tag','LCM');
else
    set(0,'CurrentFigure',lcm.fhBasisSpec)
    set(lcm.fhBasisSpec,'Name',sprintf(' Spectrum <%s>',lcm.basis.data{nMetab}{1}),'visible','on')
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhBasisSpec)
            return
        end
    end
end
clf(lcm.fhBasisSpec)

%--- data visualization ---
plot(ppmZoom,specZoom,'LineWidth',lcm.lineWidth)
set(gca,'XDir','reverse')
if flag.lcmAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    plotLim(3) = lcm.amplMin;
    plotLim(4) = lcm.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
end
if flag.lcmPpmShowPos
    hold on
    plot([lcm.ppmShowPos lcm.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    hold off
end
axis(plotLim)
if flag.lcmFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')

%--- show LCModel limits as vertical lines ---
xLim = get(gca,'XLim');
yLim = get(gca,'YLim');
hold on
for winCnt = 1:lcm.anaPpmN
    plot([lcm.anaPpmMin(winCnt) lcm.anaPpmMin(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
    plot([lcm.anaPpmMax(winCnt) lcm.anaPpmMax(winCnt)],[yLim(1) yLim(2)],'Color',[0 1 0])
end
hold off

%--- spectrum analysis ---
if flag.lcmAnaSNR || flag.lcmAnaFWHM || flag.lcmAnaIntegr
    fprintf('ANALYSIS OF BASIS SPECTRUM\n');
    if ~SP2_LCM_BasisAnalysis(lcm.basis.spec,plotLim,[flag.lcmSpecLb flag.lcmSpecGb])
        return
    end
end

%--- info printout ---
if f_verbose
    fprintf('\nMetabolite info:\n');
    fprintf('1) Name:    %s\n',lcm.basis.data{nMetab}{1});
    fprintf('2) T1:      %.3f sec\n',lcm.basis.data{nMetab}{2});
    fprintf('3) T2:      %.3f sec\n',lcm.basis.data{nMetab}{3});
    fprintf('4) length:  %.0f pts\n',length(lcm.basis.data{nMetab}{4}));
    fprintf('5) Comment: ''%s''\n\n',lcm.basis.data{nMetab}{5});
%     fprintf('5) LB:      ''%.3f Hz''\n\n',lcm.basis.data{nMetab}{6});

    fprintf('First data points of processed FID:\n');
    for iCnt = 1:5
        if imag(lcm.basis.fid(iCnt))>0
            fprintf('%.0f) %.10f + i*%.10f\n',iCnt,real(lcm.basis.fid(iCnt)),imag(lcm.basis.fid(iCnt)));
        else
            fprintf('%.0f) %.10f - i*%.10f\n',iCnt,real(lcm.basis.fid(iCnt)),abs(imag(lcm.basis.fid(iCnt))));
        end
    end
    
    fprintf('\nLast data points of processed FID:\n');
    for iCnt = lcm.basis.nspecC-4:lcm.basis.nspecC
        if imag(lcm.basis.fid(iCnt))>0
            fprintf('%.0f) %.10f + i*%.10f\n',iCnt,real(lcm.basis.fid(iCnt)),imag(lcm.basis.fid(iCnt)));
        else
            fprintf('%.0f) %.10f - i*%.10f\n',iCnt,real(lcm.basis.fid(iCnt)),abs(imag(lcm.basis.fid(iCnt))));
        end
    end
    fprintf('\n');
end

%--- figure selection ---
flag.lcmFigSelect = 7;

%--- export handling ---
lcm.expt.fid    = lcm.basis.fid;
lcm.expt.sf     = lcm.basis.sf;
lcm.expt.sw_h   = lcm.basis.sw_h;
lcm.expt.nspecC = lcm.basis.nspecC;

%--- udpate success flag ---
f_succ = 1;



