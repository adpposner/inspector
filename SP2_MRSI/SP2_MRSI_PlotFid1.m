%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotFid1( f_new )
%%
%%  Plot FID of data set 1 after time domain manipulations.
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotFid1';


%--- check data existence ---
if ~isfield(mrsi.spec1,'fid')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end

% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFid1') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFid1)
        delete(mrsi.fhFid1)
    end
    mrsi = rmfield(mrsi,'fhFid1');
end
% create figure if necessary
if ~isfield(mrsi,'fhFid1') || ~ishandle(mrsi.fhFid1)
    mrsi.fhFid1 = figure('IntegerHandle','off');
    set(mrsi.fhFid1,'NumberTitle','off','Name',sprintf(' FID 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFid1)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFid1)
            return
        end
    end
end
clf(mrsi.fhFid1)
timeVec = mrsi.spec1.dwell*(0:mrsi.spec1.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.mrsiFormat<4
    plot(real(mrsi.spec1.fid),'r')
    hold on
        plot(imag(mrsi.spec1.fid),'g')
        plot(abs(mrsi.spec1.fid))   % blue
    hold off
    ylabel(sprintf('Original FID 1 [a.u.], L/R %.0f, P/A %.0f',mrsi.selectLR,mrsi.selectPA))
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(mrsi.spec1.fid));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(mrsi.spec1.fid))
    ylabel(sprintf('Original FID 1 [rad], L/R %.0f, P/A %.0f',mrsi.selectLR,mrsi.selectPA))
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(mrsi.spec1.fid));
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
mrsi.expt.fid    = mrsi.spec1.fid;
mrsi.expt.sf     = mrsi.spec1.sf;
mrsi.expt.sw_h   = mrsi.spec1.sw_h;
mrsi.expt.nspecC = mrsi.spec1.nspecC;



end
