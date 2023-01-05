%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotLcmFid( f_new )
%%
%%  Plot FID after time domain manipulations.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_PlotLcmFid';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(lcm,'fid')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(lcm,'fhLcmFid') && ishandle(lcm.fhLcmFid)
    lcm.fig.fhLcmFid = get(lcm.fhLcmFid,'Position');
end

% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmFid') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmFid)
        delete(lcm.fhLcmFid)
    end
    lcm = rmfield(lcm,'fhLcmFid');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmFid') || ~ishandle(lcm.fhLcmFid)
    lcm.fhLcmFid = figure('IntegerHandle','off');
    set(lcm.fhLcmFid,'NumberTitle','off','Name',' FID',...
        'Position',lcm.fig.fhLcmFid,'Color',[1 1 1],'Tag','LCM');
else
    set(0,'CurrentFigure',lcm.fhLcmFid)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmFid)
            return
        end
    end
end
clf(lcm.fhLcmFid)
timeVec = lcm.dwell*(0:lcm.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.lcmFormat<4
    plot(real(lcm.fid),'r')
    hold on
        plot(imag(lcm.fid),'g')
        plot(abs(lcm.fid))   % blue
    hold off
    ylabel('FID 1 [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(lcm.fid));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(lcm.fid))
    ylabel('FID 1 [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(lcm.fid));
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
lcm.expt.fid    = lcm.fid;
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- udpate success flag ---
f_succ = 1;


