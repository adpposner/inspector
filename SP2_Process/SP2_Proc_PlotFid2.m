%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotFid2( f_new )
%%
%%  Plot FID of data set 2 after time domain manipulations.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_PlotFid2';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(proc.spec2,'fid')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(proc,'fhFid2') && ishandle(proc.fhFid2)
    proc.fig.fid2 = get(proc.fhFid2,'Position');
end

% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhFid2') && ~flag.procKeepFig
    if ishandle(proc.fhFid2)
        delete(proc.fhFid2)
    end
    proc = rmfield(proc,'fhFid2');
end
% create figure if necessary
if ~isfield(proc,'fhFid2') || ~ishandle(proc.fhFid2)
    proc.fhFid2 = figure('IntegerHandle','off');
    if flag.procData==2                 % processing data page
        if flag.procDataFormat==2        % .mat
            nameStr = sprintf(' FID 2: %s',proc.spec2.dataFileMat);
        elseif flag.procDataFormat==2    % .txt
            nameStr = sprintf(' FID 2: %s',proc.spec2.dataFileTxt);
        elseif flag.procDataFormat==3    % .par
            nameStr = sprintf(' FID 2: %s',proc.spec2.dataFilePar);
        else                             % .raw
            nameStr = sprintf(' FID 2: %s',proc.spec2.dataFileRaw);
        end
    else
        nameStr = ' FID 2';
    end
    set(proc.fhFid2,'NumberTitle','off','Name',nameStr,...
        'Position',proc.fig.fid2,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhFid2)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhFid2)
            return
        end
    end
end
clf(proc.fhFid2)
timeVec = proc.spec2.dwell*(0:proc.spec2.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.procFormat<4
    plot(real(proc.spec2.fid),'r')
    hold on
        plot(imag(proc.spec2.fid),'g')
        plot(abs(proc.spec2.fid))   % blue
    hold off
    ylabel('FID 2 [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(proc.spec2.fid));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(proc.spec2.fid),'r')
    ylabel('FID 2 [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(proc.spec2.fid));
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
proc.expt.fid    = proc.spec2.fid;
proc.expt.sf     = proc.spec2.sf;
proc.expt.sw_h   = proc.spec2.sw_h;
proc.expt.nspecC = proc.spec2.nspecC;

%--- update success flag ---
f_succ = 1;

