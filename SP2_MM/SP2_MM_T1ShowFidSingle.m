%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_T1ShowFidSingle( f_new )
%%
%%  Plot FID of selected T1 component.
%% 
%%  01-2014, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_T1ShowFidSingle';


%--- break condition ---
if ~f_new && (~isfield(mm,'fhTOneFidSingle') || ~ishandle(mm.fhTOneFidSingle))
    return
end

%--- check data existence ---
if ~isfield(mm,'t1spec')
    fprintf('%s ->\nNo T1 decomposition found.\nCalculate first. Program aborted.\n',FCTNAME)
    return
end    

% remove existing figure if new figure is forced
if f_new && isfield(mm,'fhTOneFidSingle') && ~flag.mmKeepFig
    if ishandle(mm.fhTOneFidSingle)
        delete(mm.fhTOneFidSingle)
    end
    mm = rmfield(mm,'fhTOneFidSingle');
end
% create figure if necessary
if ~isfield(mm,'fhTOneFidSingle') || ~ishandle(mm.fhTOneFidSingle)
    mm.fhTOneFidSingle = figure('IntegerHandle','off');
    set(mm.fhTOneFidSingle,'NumberTitle','off','Name',sprintf(' FID of Selected Saturation-Recovery Delay'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mm.fhTOneFidSingle)
    if flag.mmKeepFig
        if ~SP2_KeepFigure(mm.fhTOneFidSingle)
            return
        end
    end
end
clf(mm.fhTOneFidSingle)
timeVec = mm.dwell*(0:mm.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.mmFormat<4
    plot(real(mm.t1fid(:,mm.tOneSelect)),'r')
    hold on
        plot(imag(mm.t1fid(:,mm.tOneSelect)),'g')
        plot(abs(mm.t1fid(:,mm.tOneSelect)))   % blue
    hold off
    ylabel(sprintf('FID %.0f (%.3f s) [a.u.]',mm.tOneSelect,mm.anaTOne(mm.tOneSelect)))
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(mm.t1fid(:,mm.tOneSelect)));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(mm.t1fid(:,mm.tOneSelect)))
    ylabel(sprintf('FID %.0f (%.3f s) [rad]',mm.tOneSelect,mm.anaTOne(mm.tOneSelect)))
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(mm.t1fid(:,mm.tOneSelect)));
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
mm.expt.fid    = mm.t1fid(:,mm.tOneSelect);
mm.expt.sf     = mm.sf;
mm.expt.sw_h   = mm.sw_h;
mm.expt.nspecC = mm.nspecC;

