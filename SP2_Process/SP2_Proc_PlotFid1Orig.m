%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Proc_PlotFid1Orig( f_new )
%%
%%  Plot original (i.e. unprocessed) FID of data set 1
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile proc flag

FCTNAME = 'SP2_Proc_PlotFid1Orig';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(proc.spec1,'fidOrig')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(proc,'fhFid1Orig') && ishandle(proc.fhFid1Orig)
    proc.fig.fid1Orig = get(proc.fhFid1Orig,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(proc,'fhFid1Orig') && ~flag.procKeepFig
    if ishandle(proc.fhFid1Orig)
        delete(proc.fhFid1Orig)
    end
    proc = rmfield(proc,'fhFid1Orig');
end
% create figure if necessary
if ~isfield(proc,'fhFid1Orig') || ~ishandle(proc.fhFid1Orig)
    proc.fhFid1Orig = figure('IntegerHandle','off');
    if flag.procData==2                  % processing data page
        if flag.procDataFormat==1        % .mat
            nameStr = sprintf(' Original FID 1: %s',proc.spec1.dataFileMat);
        elseif flag.procDataFormat==2    % .txt
            nameStr = sprintf(' Original FID 1: %s',proc.spec1.dataFileTxt);
        elseif flag.procDataFormat==3    % .par
            nameStr = sprintf(' Original FID 1: %s',proc.spec1.dataFilePar);
        else                             % .raw
            nameStr = sprintf(' Original FID 1: %s',proc.spec1.dataFileRaw);
        end
    else
        nameStr = ' Original FID 1';
    end
    set(proc.fhFid1Orig,'NumberTitle','off','Name',nameStr,'Position',...
        proc.fig.fid1Orig,'Color',[1 1 1],'Tag','Proc');
else
    set(0,'CurrentFigure',proc.fhFid1Orig)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhFid1Orig)
            return
        end
    end
end
clf(proc.fhFid1Orig)
timeVec = proc.spec1.dwell*(0:proc.spec1.nspecCOrig-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.procFormat<4
    plot(real(proc.spec1.fidOrig),'r')
    hold on
        plot(imag(proc.spec1.fidOrig),'g')
        plot(abs(proc.spec1.fidOrig))   % blue
    hold off
    ylabel('Original FID 1 [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(proc.spec1.fidOrig));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(proc.spec1.fidOrig))
    ylabel('Original FID 1 [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(proc.spec1.fidOrig));
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
proc.expt.fid    = proc.spec1.fidOrig;
proc.expt.sf     = proc.spec1.sf;
proc.expt.sw_h   = proc.spec1.sw_h;
proc.expt.nspecC = proc.spec1.nspecC;

%--- update success flag ---
f_succ = 1;

