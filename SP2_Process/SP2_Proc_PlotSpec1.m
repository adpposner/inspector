%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotSpec1( f_new )
%%
%%  Plot processed spectrum of data set 1.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PlotSpec1';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(proc.spec1,'spec')
    fprintf('%s ->\nSpectrum 1 does not exist. Load/analyze first.\n',FCTNAME)
    return
end

%--- ppm limit handling ---
if flag.procPpmShow     % direct
    ppmMin = proc.ppmShowMin;
    ppmMax = proc.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -proc.spec1.sw/2 + proc.ppmCalib;
    ppmMax = proc.spec1.sw/2  + proc.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec1.sw,real(proc.spec1.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec1.sw,imag(proc.spec1.spec));
elseif flag.procFormat==3       % magnitude
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec1.sw,abs(proc.spec1.spec));
else                            % phase
    [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,...
                                                               proc.spec1.sw,angle(proc.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
    return
end

%--- keep current figure position ---
if isfield(proc,'fhSpec1') && ishandle(proc.fhSpec1)
    proc.fig.spec1 = get(proc.fhSpec1,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhSpec1') && ~flag.procKeepFig
    if ishandle(proc.fhSpec1)
        delete(proc.fhSpec1)
    end
    proc = rmfield(proc,'fhSpec1');
end
% create figure if necessary
if ~isfield(proc,'fhSpec1') || ~ishandle(proc.fhSpec1)
    proc.fhSpec1 = figure('IntegerHandle','off');
    if flag.procData==2                 % processing data page
        if flag.procDataFormat==1        % .mat
            nameStr = sprintf(' Spectrum 1: %s',proc.spec1.dataFileMat);
        elseif flag.procDataFormat==2    % .txt
            nameStr = sprintf(' Spectrum 1: %s',proc.spec1.dataFileTxt);
        elseif flag.procDataFormat==3    % .par
            nameStr = sprintf(' Spectrum 1: %s',proc.spec1.dataFilePar);
        else                             % .raw
            nameStr = sprintf(' Spectrum 1: %s',proc.spec1.dataFileRaw);
        end
    else
        nameStr = ' Spectrum 1';
    end
    set(proc.fhSpec1,'NumberTitle','off','Name',nameStr,...
        'Position',proc.fig.spec1,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhSpec1)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhSpec1)
            return
        end
    end
end
clf(proc.fhSpec1)

%--- data visualization ---
% plot(ppmZoom,spec1Zoom,'LineWidth',2)
plot(ppmZoom,spec1Zoom)
set(gca,'XDir','reverse')
if flag.procAmpl        % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
    plotLim(3) = proc.amplMin;
    plotLim(4) = proc.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
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
    fprintf('Plot limits: %s\n',SP2_Vec2PrintStr(plotLim,2))
end
if flag.procFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')

%--- export handling ---
proc.expt.fid    = ifft(ifftshift(proc.spec1.spec,1),[],1);
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;

%--- spectrum analysis ---
if flag.procAnaSNR || flag.procAnaFWHM || flag.procAnaIntegr
    fprintf('ANALYSIS OF SPECTRUM 1\n')
    if ~SP2_Proc_Analysis(proc.spec1.spec,proc.spec1,plotLim,double([flag.procSpec1Lb flag.procSpec1Gb]))
        return
    end
end

%--- update success flag ---
f_succ = 1;


