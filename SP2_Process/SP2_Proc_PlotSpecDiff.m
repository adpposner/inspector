%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotSpecDiff( f_new )
%%
%%  Plot spectrum summation.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PlotSpecDiff';


%--- init success flag ---
f_succ = 0;

%--- check data existence and parameter consistency ---
if flag.procNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME);
    return
else                        % 2 spectra
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nSpectral data set 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec2,'sw')
        fprintf('%s ->\nSpectrum 2 not found. Program aborted.\n',FCTNAME);
        return
    end
    %--- SW (and dwell time) ---
    if SP2_RoundToNthDigit(proc.spec1.sw,2)~=SP2_RoundToNthDigit(proc.spec2.sw,2)
        fprintf('%s -> SW mismatch detected (%.2f kHz ~= %.2f kHz)\n',FCTNAME,...
                proc.spec1.sw,proc.spec2.sw)
        return
    end
    %--- number of points ---
    if proc.spec1.nspecC~=proc.spec2.nspecC
        fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
                proc.spec1.nspecC,proc.spec2.nspecC)
    end
end

%--- ppm limit handling ---
if flag.procPpmShow     % direct
    ppmMin = proc.ppmShowMin;
    ppmMax = proc.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -proc.spec1.sw/2 + proc.ppmCalib;
    ppmMax = proc.spec1.sw/2  + proc.ppmCalib;
end

%--- check data existence ---
if ~isfield(proc,'specDiff')
    if flag.procUpdateCalc
        if ~SP2_Proc_ProcComplete
            fprintf('%s ->\nData processing failed. Program aborted.\n\n',FCTNAME);
            return
        end
    else
        fprintf('%s ->\nSpectral difference signal does not exist.\nCalculate first or enable automated processing via ''Update'' flag.\n\n',FCTNAME);
        return
    end
end

%--- data extraction: spectrum 1 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,proc.spec1.sw,real(proc.specDiff));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,proc.spec1.sw,imag(proc.specDiff));
elseif flag.procFormat==3       % magnitude
    [minI,maxI,ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,proc.spec1.sw,abs(proc.specDiff));
else                            % phase
    [minI,maxI,ppmZoom,specZoom,f_done] = ...
        SP2_Proc_ExtractPpmRange(ppmMin,ppmMax,proc.ppmCalib,proc.spec1.sw,angle(proc.specDiff));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(proc,'fhSpecDiff') && ishandle(proc.fhSpecDiff)
    proc.fig.specDiff = get(proc.fhSpecDiff,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhSpecDiff') && ~flag.procKeepFig
    if ishandle(proc.fhSpecDiff)
        delete(proc.fhSpecDiff)
    end
    proc = rmfield(proc,'fhSpecDiff');
end
% create figure if necessary
if ~isfield(proc,'fhSpecDiff') || ~ishandle(proc.fhSpecDiff)
    proc.fhSpecDiff = figure('IntegerHandle','off');
    set(proc.fhSpecDiff,'NumberTitle','off','Name',sprintf(' Difference Spectrum'),...
        'Position',proc.fig.specDiff,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhSpecDiff)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhSpecDiff)
            return
        end
    end
end
clf(proc.fhSpecDiff)

%--- data visualization ---
plot(ppmZoom,specZoom)
% plot(ppmZoom,specZoom,'LineWidth',2)
set(gca,'XDir','reverse')
if flag.procAmpl         % direct
    [plotLim(1) plotLim(2) fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    plotLim(3) = proc.amplMin;
    plotLim(4) = proc.amplMax;
else                    % automatic
    [plotLim(1) plotLim(2) plotLim(3) plotLim(4)] = SP2_IdealAxisValues(ppmZoom,specZoom);
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
proc.expt.fid    = ifft(ifftshift(proc.specDiff,1),[],1);
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;

%--- spectrum analysis ---
if flag.procAnaSNR || flag.procAnaFWHM || flag.procAnaIntegr
    fprintf('ANALYSIS OF DIFFERENCE SPECTRUM\n');
    if ~SP2_Proc_Analysis(proc.specDiff,proc.spec1,plotLim)
        return
    end
end

%--- update success flag ---
f_succ = 1;
