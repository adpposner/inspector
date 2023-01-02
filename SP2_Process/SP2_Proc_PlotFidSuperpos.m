%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotFidSuperpos( f_new )
%%
%%  Plot superposition of FIDs from data sets 1 and 2.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_PlotFidSuperpos';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if flag.procNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME);
    return
else                        % 2 spectra
    if ~isfield(proc.spec1,'fid')
        fprintf('%s ->\nData of spectrum 1 does not exist. Load/analyze first.\n',FCTNAME);
        return
    end
    if ~isfield(proc.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load/analyze first.\n',FCTNAME);
        return
    end
end

%--- keep current figure position ---
if isfield(proc,'fhFidSuper') && ishandle(proc.fhFidSuper)
    proc.fig.fidSuper = get(proc.fhFidSuper,'Position');
end

% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhFidSuper') && ~flag.procKeepFig
    if ishandle(proc.fhFidSuper)
        delete(proc.fhFidSuper)
    end
    proc = rmfield(proc,'fhFidSuper');
end
% create figure if necessary
if ~isfield(proc,'fhFidSuper') || ~ishandle(proc.fhFidSuper)
    proc.fhFidSuper = figure('IntegerHandle','off');
    set(proc.fhFidSuper,'NumberTitle','off','Name',sprintf(' FID 1'),...
        'Position',proc.fig.fidSuper,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhFidSuper)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhFidSuper)
            return
        end
    end
end
clf(proc.fhFidSuper)
timeVec1 = proc.spec1.dwell*(0:proc.spec1.nspecC-1);       % acquisition time [s]
timeVec2 = proc.spec2.dwell*(0:proc.spec2.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
hold on
if flag.procFormat==1           % real part
    plot(real(proc.spec1.fid))
    plot(real(proc.spec2.fid),'r')
elseif flag.procFormat==2       % imaginary part
    plot(imag(proc.spec1.fid))
    plot(imag(proc.spec2.fid),'r')
elseif flag.procFormat==3       % magnitude
    plot(abs(proc.spec1.fid))
    plot(abs(proc.spec2.fid),'r')
else                            % phase
    plot(angle(proc.spec1.fid))
    plot(angle(proc.spec2.fid),'r')
end   
hold off
xlabel('time [s]')
if flag.procFormat<4
    ylabel('FID Superposition [a.u.]')
else
    ylabel('FID Superposition [rad]')
end
legend('FID 1','FID 2')
if flag.procFormat==1           % real part
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(real(proc.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(real(proc.spec2.fid));
elseif flag.procFormat==2       % imaginary part
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(imag(proc.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(imag(proc.spec2.fid));
elseif flag.procFormat==3       % magnitude
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(abs(proc.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(abs(proc.spec2.fid));
else                            % phase
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(angle(proc.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(angle(proc.spec2.fid));
end
minX = min(minX1,minX2);
maxX = max(maxX1,maxX2);
minY = min(minY1,minY2);
maxY = max(maxY1,maxY2);
axis([minX maxX minY maxY])        % symmetric amplitude range
xlabel('time [pts]')
set(gca,'XGrid','on','YGrid','On')
%--- add time axis ---
timeMax = max(timeVec1(end),timeVec2(end));
if timeMax>0.5
    timeStep = 0.1*round(timeMax/(8*0.1));         % eight 0.1s steps
elseif timeMax>0.2
    timeStep = 0.05*round(timeMax/(8*0.05));       % eight 0.05s steps
elseif timeMax>0.05
    timeStep = 0.01*round(timeMax/(8*0.01));       % eight 0.01s steps
elseif timeMax>0.01
    timeStep = 0.002*round(timeMax/(8*0.002));     % eight 0.002s steps
else
    timeStep = 0.0005*round(timeMax/(8*0.0005));   % eight 0.0005s steps
end
timeAxis = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
                'Color','none','XLim',[min(timeVec1) max(timeVec1)],...
                'XTick',min(timeVec1(1),timeVec2(1)):timeStep:timeMax,...
                'YTick',[]);
xlabel('time [s]')


%--- udpate success flag ---
f_succ = 1;

