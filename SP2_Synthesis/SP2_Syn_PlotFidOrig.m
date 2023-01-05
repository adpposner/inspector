%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Syn_PlotFidOrig( f_new )
%%
%%  Plot original (i.e. unprocessed) FID.
%% 
%%  10-2015, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global syn flag

FCTNAME = 'SP2_Syn_PlotFidOrig';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(syn,'fidOrig')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- keep current figure position ---
if isfield(syn,'fhSynFidOrig') && ishandle(syn.fhSynFidOrig)
    syn.fig.fhSynFidOrig = get(syn.fhSynFidOrig,'Position');
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(syn,'fhSynFidOrig') && ~flag.synKeepFig
    if ishandle(syn.fhSynFidOrig)
        delete(syn.fhSynFidOrig)
    end
    syn = rmfield(syn,'fhSynFidOrig');
end
% create figure if necessary
if ~isfield(syn,'fhSynFidOrig') || ~ishandle(syn.fhSynFidOrig)
    syn.fhSynFidOrig = figure('IntegerHandle','off');
    set(syn.fhSynFidOrig,'NumberTitle','off','Name',' Original FID','Position',...
        syn.fig.fhSynFidOrig,'Color',[1 1 1]);
else
    set(0,'CurrentFigure',syn.fhSynFidOrig)
    if flag.synKeepFig
        if ~SP2_KeepFigure(syn.fhSynFidOrig)
            return
        end
    end
end
clf(syn.fhSynFidOrig)
timeVec = syn.dwell*(0:syn.nspecCOrig-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.synFormat<4
    plot(real(syn.fidOrig),'r')
    hold on
        plot(imag(syn.fidOrig),'g')
        plot(abs(syn.fidOrig))   % blue
    hold off
    ylabel('Original FID [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(syn.fidOrig));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(syn.fidOrig))
    ylabel('Original FID [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(syn.fidOrig));
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
syn.expt.fid    = syn.fidOrig;
syn.expt.sf     = syn.sf;
syn.expt.sw_h   = syn.sw_h;
syn.expt.nspecC = syn.nspecC;

%--- update success flag ---
f_succ = 1;



