%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Syn_PlotFid( f_new )
%%
%%  Plot FID after time domain manipulations.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile syn flag

FCTNAME = 'SP2_Syn_PlotFid';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(syn,'fid')
    fprintf('%s ->\nFID does not exist. Load first.\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(syn,'fhSynFid') && ishandle(syn.fhSynFid)
    syn.fig.fhSynFid = get(syn.fhSynFid,'Position');
end

% remove existing figure if new figure is forced
if f_new && isfield(syn,'fhSynFid') && ~flag.synKeepFig
    if ishandle(syn.fhSynFid)
        delete(syn.fhSynFid)
    end
    syn = rmfield(syn,'fhSynFid');
end
% create figure if necessary
if ~isfield(syn,'fhSynFid') || ~ishandle(syn.fhSynFid)
    syn.fhSynFid = figure('IntegerHandle','off');
    set(syn.fhSynFid,'NumberTitle','off','Name',' FID',...
        'Position',syn.fig.fhSynFid,'Color',[1 1 1]);
else
    set(0,'CurrentFigure',syn.fhSynFid)
    if flag.synKeepFig
        if ~SP2_KeepFigure(syn.fhSynFid)
            return
        end
    end
end
clf(syn.fhSynFid)
timeVec = syn.dwell*(0:syn.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.synFormat<4
    plot(real(syn.fid),'r')
    hold on
        plot(imag(syn.fid),'g')
        plot(abs(syn.fid))   % blue
    hold off
    ylabel('FID [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(syn.fid));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(syn.fid))
    ylabel('FID [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(syn.fid));
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
syn.expt.fid    = syn.fid;
syn.expt.sf     = syn.sf;
syn.expt.sw_h   = syn.sw_h;
syn.expt.nspecC = syn.nspecC;

%--- update success flag ---
f_succ = 1;


