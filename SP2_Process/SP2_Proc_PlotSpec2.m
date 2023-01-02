%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotSpec2( f_new )
%%
%%  Plot processed spectrum of data set 2.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_PlotSpec2';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(proc.spec2,'spec')
    fprintf('%s ->\nSpectrum 2 does not exist. Load/analyze first.\n',FCTNAME);
    return
end

%--- ppm limit handling ---
if flag.procPpmShow     % direct
    ppmMin = proc.ppmShowMin;
    ppmMax = proc.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -proc.spec2.sw/2 + proc.ppmCalib;
    ppmMax = proc.spec2.sw/2  + proc.ppmCalib;
end

%--- data extraction: spectrum 2 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec2.sw,real(proc.spec2.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec2.sw,imag(proc.spec2.spec));
elseif flag.procFormat==3       % magnitude
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec2.sw,abs(proc.spec2.spec));
else                            % phase
    [minI,maxI,ppmZoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec2.sw,angle(proc.spec2.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(proc,'fhSpec2') && ishandle(proc.fhSpec2)
    proc.fig.spec2 = get(proc.fhSpec2,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhSpec2') && ~flag.procKeepFig
    if ishandle(proc.fhSpec2)
        delete(proc.fhSpec2)
    end
    proc = rmfield(proc,'fhSpec2');
end
% create figure if necessary
if ~isfield(proc,'fhSpec2') || ~ishandle(proc.fhSpec2)
    proc.fhSpec2 = figure('IntegerHandle','off');
    if flag.procData==2                 % processing data page
        if flag.procDataFormat==1        % .mat
            nameStr = sprintf(' Spectrum 2: %s',proc.spec2.dataFileMat);
        elseif flag.procDataFormat==2    % .txt
            nameStr = sprintf(' Spectrum 2: %s',proc.spec2.dataFileTxt);
        elseif flag.procDataFormat==3    % .par
            nameStr = sprintf(' Spectrum 2: %s',proc.spec2.dataFilePar);
        else                             % .raw
            nameStr = sprintf(' Spectrum 2: %s',proc.spec2.dataFileRaw);
        end
    else
        nameStr = ' Spectrum 2';
    end
    set(proc.fhSpec2,'NumberTitle','off','Name',nameStr,...
        'Position',proc.fig.spec2,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhSpec2)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhSpec2)
            return
        end
    end
end
clf(proc.fhSpec2)

%--- data visualization ---
plot(ppmZoom,spec2Zoom)
set(gca,'XDir','reverse')
if flag.procAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
    plotLim(3) = proc.amplMin;
    plotLim(4) = proc.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,spec2Zoom);
end
if flag.procPpmShowPos
    hold on
    plot([proc.ppmShowPos proc.ppmShowPos],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    if flag.procPpmShowPosMirr
        plot([proc.ppmShowPosMirr proc.ppmShowPosMirr],[plotLim(3) plotLim(4)],'Color',[0 0 0])
    end
    hold off
end
axis(plotLim)
if flag.verbose
    fprintf('Plot limits: %s\n',SP2_Vec2PrintStr(plotLim,2));
end
if flag.procFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')

%--- export handling ---
proc.expt.fid    = ifft(ifftshift(proc.spec2.spec,1),[],1);
proc.expt.sf     = proc.spec2.sf;
proc.expt.sw_h   = proc.spec2.sw_h;
proc.expt.nspecC = proc.spec2.nspecC;

%--- spectrum analysis ---
if flag.procAnaSNR || flag.procAnaFWHM || flag.procAnaIntegr
    fprintf('ANALYSIS OF SPECTRUM 2\n');
    if ~SP2_Proc_Analysis(proc.spec2.spec,proc.spec2,plotLim,double([flag.procSpec2Lb flag.procSpec2Gb]))
        return
    end
end

%--- udpate success flag ---
f_succ = 1;


