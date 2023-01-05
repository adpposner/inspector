%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotSpecSuperpos( f_new )
%%
%%  Plot spectrum superposition of data sets 1 and 2.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PlotSpecSuperpos';


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
    ppmMin1 = proc.ppmShowMin;
    ppmMax1 = proc.ppmShowMax;
    ppmMin2 = proc.ppmShowMin;
    ppmMax2 = proc.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin1 = -proc.spec1.sw/2 + proc.ppmCalib;
    ppmMax1 = proc.spec1.sw/2  + proc.ppmCalib;
    ppmMin2 = -proc.spec2.sw/2 + proc.ppmCalib;
    ppmMax2 = proc.spec2.sw/2  + proc.ppmCalib;
end

%--- data extraction: spectrum 1 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin1,ppmMax1,proc.ppmCalib,...
                                                               proc.spec1.sw,real(proc.spec1.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin1,ppmMax1,proc.ppmCalib,...
                                                               proc.spec1.sw,imag(proc.spec1.spec));
elseif flag.procFormat==3       % magnitude
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin1,ppmMax1,proc.ppmCalib,...
                                                               proc.spec1.sw,abs(proc.spec1.spec));
else                            % phase
    [minI,maxI,ppm1Zoom,spec1Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin1,ppmMax1,proc.ppmCalib,...
                                                               proc.spec1.sw,angle(proc.spec1.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- data extraction: spectrum 2 ---
if flag.procFormat==1           % real part
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin2,ppmMax2,proc.ppmCalib,...
                                                               proc.spec2.sw,real(proc.spec2.spec));
elseif flag.procFormat==2       % imaginary part
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin2,ppmMax2,proc.ppmCalib,...
                                                               proc.spec2.sw,imag(proc.spec2.spec));
elseif flag.procFormat==3       % magnitude
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin2,ppmMax2,proc.ppmCalib,...
                                                               proc.spec2.sw,abs(proc.spec2.spec));
else                            % phase
    [minI,maxI,ppm2Zoom,spec2Zoom,f_done] = SP2_Proc_ExtractPpmRange(ppmMin2,ppmMax2,proc.ppmCalib,...
                                                               proc.spec2.sw,angle(proc.spec2.spec));
end                                             
if ~f_done
    fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(proc,'fhSpecSuper') && ishandle(proc.fhSpecSuper)
    proc.fig.specSuper = get(proc.fhSpecSuper,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhSpecSuper') && ~flag.procKeepFig
    if ishandle(proc.fhSpecSuper)
        delete(proc.fhSpecSuper)
    end
    proc = rmfield(proc,'fhSpecSuper');
end
% create figure if necessary
if ~isfield(proc,'fhSpecSuper') || ~ishandle(proc.fhSpecSuper)
    proc.fhSpecSuper = figure('IntegerHandle','off');
    set(proc.fhSpecSuper,'NumberTitle','off','Name',sprintf(' Spectrum Superposition'),...
        'Position',proc.fig.specSuper,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhSpecSuper)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhSpecSuper)
            return
        end
    end
end
clf(proc.fhSpecSuper)

%--- data visualization ---
plot(ppm1Zoom,spec1Zoom)
% plot(ppm1Zoom,spec1Zoom,'LineWidth',2)
hold on 
    plot(ppm2Zoom,spec2Zoom,'r')
%     plot(ppm2Zoom,spec2Zoom,'LineWidth',2,'Color',[1 0 0])
hold off
set(gca,'XDir','reverse')
if flag.procAmpl         % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppm1Zoom,spec1Zoom);
    minY = proc.amplMin;
    maxY = proc.amplMax;
else                    % automatic
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(ppm1Zoom,spec1Zoom);
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(ppm2Zoom,spec2Zoom);
    minX = min(minX1,minX2);
    maxX = max(maxX1,maxX2);
    minY = min(minY1,minY2);
    maxY = max(maxY1,maxY2);
end
if flag.procPpmShowPos
    hold on
    plot([proc.ppmShowPos proc.ppmShowPos],[minY maxY],'Color',[0 0 0],'HandleVisibility','off')
    if flag.procPpmShowPosMirr
        plot([proc.ppmShowPosMirr proc.ppmShowPosMirr],[minY maxY],'Color',[0 0 0],'HandleVisibility','off')
    end
    hold off
end
axis([minX maxX minY maxY])
if flag.verbose
    fprintf('Plot limits: %s\n',SP2_Vec2PrintStr([minX maxX minY maxY],2));
end
if flag.procFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')
lh = legend('Spec 1','Spec 2');
set(lh,'Location','Northwest')

%--- update success flag ---
f_succ = 1;

