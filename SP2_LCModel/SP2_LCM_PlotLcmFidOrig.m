%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_LCM_PlotLcmFidOrig( f_new )
%%
%%  Plot original (i.e. unprocessed) FID.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm flag

FCTNAME = 'SP2_LCM_PlotLcmFidOrig';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(lcm,'fidOrig')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(lcm,'fhLcmFidOrig') && ishandle(lcm.fhLcmFidOrig)
    lcm.fig.fhLcmFidOrig = get(lcm.fhLcmFidOrig,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(lcm,'fhLcmFidOrig') && ~flag.lcmKeepFig
    if ishandle(lcm.fhLcmFidOrig)
        delete(lcm.fhLcmFidOrig)
    end
    lcm = rmfield(lcm,'fhLcmFidOrig');
end
% create figure if necessary
if ~isfield(lcm,'fhLcmFidOrig') || ~ishandle(lcm.fhLcmFidOrig)
    lcm.fhLcmFidOrig = figure('IntegerHandle','off');
    set(lcm.fhLcmFidOrig,'NumberTitle','off','Name',' Original FID','Position',...
        lcm.fig.fhLcmFidOrig,'Color',[1 1 1],'Tag','LCM');
else
    set(0,'CurrentFigure',lcm.fhLcmFidOrig)
    if flag.lcmKeepFig
        if ~SP2_KeepFigure(lcm.fhLcmFidOrig)
            return
        end
    end
end
clf(lcm.fhLcmFidOrig)
timeVec = lcm.dwell*(0:lcm.nspecCOrig-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.lcmFormat<4
    plot(real(lcm.fidOrig),'r')
    hold on
        plot(imag(lcm.fidOrig),'g')
        plot(abs(lcm.fidOrig))   % blue
    hold off
    ylabel('Original FID 1 [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(lcm.fidOrig));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(lcm.fidOrig))
    ylabel('Original FID 1 [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(lcm.fidOrig));
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
lcm.expt.fid    = lcm.fidOrig;
lcm.expt.sf     = lcm.sf;
lcm.expt.sw_h   = lcm.sw_h;
lcm.expt.nspecC = lcm.nspecC;

%--- update success flag ---
f_succ = 1;



end
