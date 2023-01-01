%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_SatRecShowFidSingle( f_new )
%%
%%  Plot FID of selected saturation-recovery time point.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_SatRecShowFidSingle';


%--- break condition ---
if ~f_new && (~isfield(mm,'fhSatRecFidSingle') || ~ishandle(mm.fhSatRecFidSingle))
    return
end

%--- check data existence ---
if ~isfield(mm,'spec')
    fprintf('%s ->\nNo saturation-recovery data set found.\nLoad/simulate first. Program aborted.\n',FCTNAME)
    return
end    

% remove existing figure if new figure is forced
if f_new && isfield(mm,'fhSatRecFidSingle') && ~flag.mmKeepFig
    if ishandle(mm.fhSatRecFidSingle)
        delete(mm.fhSatRecFidSingle)
    end
    mm = rmfield(mm,'fhSatRecFidSingle');
end
% create figure if necessary
if ~isfield(mm,'fhSatRecFidSingle') || ~ishandle(mm.fhSatRecFidSingle)
    mm.fhSatRecFidSingle = figure('IntegerHandle','off');
    set(mm.fhSatRecFidSingle,'NumberTitle','off','Name',sprintf(' FID of Selected Saturation-Recovery Delay'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhSatRecFidSingle)
    if flag.mmKeepFig
        if ~SP2_KeepFigure(mm.fhSatRecFidSingle)
            return
        end
    end
end
clf(mm.fhSatRecFidSingle)
timeVec = mm.dwell*(0:mm.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.mmFormat<4
    plot(real(mm.fid(:,mm.satRecSelect)),'r')
    hold on
        plot(imag(mm.fid(:,mm.satRecSelect)),'g')
        plot(abs(mm.fid(:,mm.satRecSelect)))   % blue
    hold off
    ylabel(sprintf('FID %.0f (%.3f s) [a.u.]',mm.satRecSelect,mm.satRecVec(mm.satRecSelect)))
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(mm.fid(:,mm.satRecSelect)));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(mm.fid(:,mm.satRecSelect)))
    ylabel(sprintf('FID %.0f (%.3f s) [rad]',mm.satRecSelect,mm.satRecVec(mm.satRecSelect))')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(mm.fid(:,mm.satRecSelect)));
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
mm.expt.fid    = mm.fid(:,mm.satRecSelect);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;

