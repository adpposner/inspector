%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotFidSum( f_new )
%%
%%  Plot summation FID of data sets.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global proc flag

FCTNAME = 'SP2_Proc_PlotFidSum';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if flag.procNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME)
    return
else                        % 2 spectra
    if ~isfield(proc,'spec1')
        fprintf('%s ->\nSpectral data set 1 not found. Program aborted.\n',FCTNAME)
        return
    end
    if ~isfield(proc.spec1,'sw')
        fprintf('%s ->\nSpectrum 1 not found. Program aborted.\n',FCTNAME)
        return
    end
    if ~isfield(proc,'spec2')
        fprintf('%s ->\nSpectral data set 2 not found. Program aborted.\n',FCTNAME)
        return
    end
    if ~isfield(proc.spec2,'sw')
        fprintf('%s ->\nSpectrum 2 not found. Program aborted.\n',FCTNAME)
        return
    end
    %--- SW (and dwell time) ---
    if SP2_RoundToNthDigit(proc.spec1.sw,4)~=SP2_RoundToNthDigit(proc.spec2.sw,4)
        fprintf('%s -> SW mismatch detected (%.4fMHz ~= %.4fMHz)\n',FCTNAME,...
                proc.spec1.sw,proc.spec2.sw)
        return
    end
    %--- number of points ---
    if proc.spec1.nspecC~=proc.spec2.nspecC
        fprintf('%s -> Spectral size mismatch: %.0fpts ~= %.0fpts\n',FCTNAME,...
                proc.spec1.nspecC,proc.spec2.nspecC)
    end
end

%--- consistency checks ---
% dwell time (and SW) check
if proc.spec1.dwell~=proc.spec2.dwell
    fprintf('%s -> Dwell time mismatch detected (%.6fHz ~= %.6fHz)\n',FCTNAME,...
            proc.spec1.dwell,proc.spec2.dwell)
    return
end
% number of points check
if proc.spec1.nspecC~=proc.spec2.nspecC
    fprintf('%s -> Mismatch between number of points detected (%.0f ~= %.0f)\n',FCTNAME,...
            proc.spec1.nspecC,proc.spec2.nspecC)
    return
end

%--- keep current figure position ---
if isfield(proc,'fhFidSum') && ishandle(proc.fhFidSum)
    proc.fig.fidSum = get(proc.fhFidSum,'Position');
end

% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhFidSum') && ~flag.procKeepFig
    if ishandle(proc.fhFidSum)
        delete(proc.fhFidSum)
    end
    proc = rmfield(proc,'fhFidSum');
end
% create figure if necessary
if ~isfield(proc,'fhFidSum') || ~ishandle(proc.fhFidSum)
    proc.fhFidSum = figure('IntegerHandle','off');
    set(proc.fhFidSum,'NumberTitle','off','Name',sprintf(' FID Sum'),...
        'Position',proc.fig.fidSum,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhFidSum)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhFidSum)
            return
        end
    end
end
clf(proc.fhFidSum)
timeVec = proc.spec1.dwell*(0:proc.spec1.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.procFormat==1           % real part
    plot(real(proc.fidSum))
elseif flag.procFormat==2       % imaginary part
    plot(imag(proc.fidSum))
elseif flag.procFormat==3       % magnitude
    plot(abs(proc.fidSum))
else                            % phase
    plot(angle(proc.fidSum))
end   
if flag.procFormat<4
    ylabel('FID 1 [a.u.]')
else
    ylabel('FID 1 [rad]')
end
if flag.procFormat==1           % real
    [minX maxX minY maxY] = SP2_IdealAxisValues(real(proc.fidSum));
elseif flag.procFormat==2       % imag
    [minX maxX minY maxY] = SP2_IdealAxisValues(imag(proc.fidSum));
elseif flag.procFormat==3       % magnitude
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(proc.fidSum));
else                            % phase
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(proc.fidSum));
end
axis([minX maxX minY maxY])
xlabel('time [pts]')
set(gca,'XGrid','on','YGrid','On')
%--- add time axis ---
if timeVec(end)>0.5
    timeStep = 0.1*round(timeVec(end)/(8*0.1));         % eight 0.1s steps
elseif timeVec(end)>0.2
    timeStep = 0.05*round(timeVec(end)/(8*0.05));       % eight 0.05s steps
elseif timeVec(end)>0.05
    timeStep = 0.01*round(timeVec(end)/(8*0.01));       % eight 0.01s steps
elseif timeVec(end)>0.01
    timeStep = 0.002*round(timeVec(end)/(8*0.002));     % eight 0.002s steps
else
    timeStep = 0.0005*round(timeVec(end)/(8*0.0005));   % eight 0.0005s steps
end
timeAxis = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
                'Color','none','XLim',[min(timeVec) max(timeVec)],...
                'XTick',min(timeVec):timeStep:max(timeVec),...
                'YTick',[]);
xlabel('time [s]')

%--- export handling ---
proc.expt.fid    = proc.fidSum;
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;

%--- update success flag ---
f_succ = 1;

