%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotFid1( f_new )
%%
%%  Plot FID of data set 1 after time domain manipulations.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_PlotFid1';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(proc.spec1,'fid')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(proc,'fhFid1') && ishandle(proc.fhFid1)
    proc.fig.fid1 = get(proc.fhFid1,'Position');
end

% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhFid1') && ~flag.procKeepFig
    if ishandle(proc.fhFid1)
        delete(proc.fhFid1)
    end
    proc = rmfield(proc,'fhFid1');
end
% create figure if necessary
if ~isfield(proc,'fhFid1') || ~ishandle(proc.fhFid1)
    proc.fhFid1 = figure('IntegerHandle','off');
    if flag.procData==2                  % processing data page
        if flag.procDataFormat==1        % .mat
            nameStr = sprintf(' FID 1: %s',proc.spec1.dataFileMat);
        elseif flag.procDataFormat==2    % .txt
            nameStr = sprintf(' FID 1: %s',proc.spec1.dataFileTxt);
        elseif flag.procDataFormat==3    % .par
            nameStr = sprintf(' FID 1: %s',proc.spec1.dataFilePar);
        else                             % .raw
            nameStr = sprintf(' FID 1: %s',proc.spec1.dataFileRaw);
        end
    else
        nameStr = ' FID 1';
    end
    set(proc.fhFid1,'NumberTitle','off','Name',nameStr,...
        'Position',proc.fig.fid1,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhFid1)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhFid1)
            return
        end
    end
end
clf(proc.fhFid1)
timeVec = proc.spec1.dwell*(0:proc.spec1.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.procFormat<4
    plot(real(proc.spec1.fid),'r')
    hold on
        plot(imag(proc.spec1.fid),'g')
        plot(abs(proc.spec1.fid))   % blue
    hold off
    ylabel('FID 1 [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(proc.spec1.fid));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(proc.spec1.fid))
    ylabel('FID 1 [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(proc.spec1.fid));
    axis([minX maxX minY maxY])
end
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
proc.expt.fid    = proc.spec1.fid;
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;

%--- init success flag ---
f_succ = 1;

