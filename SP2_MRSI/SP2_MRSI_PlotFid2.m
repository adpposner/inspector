%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotFid2( f_new )
%%
%%  Plot FID of data set 2 after time domain manipulations.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotFid2';


%--- check data existence ---
if ~isfield(mrsi.spec2,'fid')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME)
    return
end

% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFid2') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFid2)
        delete(mrsi.fhFid2)
    end
    mrsi = rmfield(mrsi,'fhFid2');
end
% create figure if necessary
if ~isfield(mrsi,'fhFid2') || ~ishandle(mrsi.fhFid2)
    mrsi.fhFid2 = figure('IntegerHandle','off');
    set(mrsi.fhFid2,'NumberTitle','off','Name',sprintf(' FID 2'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFid2)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFid2)
            return
        end
    end
end
clf(mrsi.fhFid2)
timeVec = mrsi.spec2.dwell*(0:mrsi.spec2.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.mrsiFormat<4
    plot(real(mrsi.spec2.fid),'r')
    hold on
        plot(imag(mrsi.spec2.fid),'g')
        plot(abs(mrsi.spec2.fid))   % blue
    hold off
    ylabel('FID 2 [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(mrsi.spec2.fid));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(mrsi.spec2.fid),'r')
    ylabel('FID 2 [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(mrsi.spec2.fid));
    axis([minX maxX minY maxY])
end
xlabel('time [pts]')
set(gca,'XGrid','on','YGrid','On')
%--- add time axis ---
timeStep = 0.1*round(timeVec(end)/(8*0.1));     % 8 full 0.1s steps
timeAxis = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
                'Color','none','XLim',[min(timeVec) max(timeVec)],...
                'XTick',min(timeVec):timeStep:max(timeVec),...
                'YTick',[]);
xlabel('time [s]')

%--- export handling ---
mrsi.expt.fid    = mrsi.spec2.fid;
mrsi.expt.sf     = mrsi.spec2.sf;
mrsi.expt.sw_h   = mrsi.spec2.sw_h;
mrsi.expt.nspecC = mrsi.spec2.nspecC;


