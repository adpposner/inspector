%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotFid2Orig( f_new )
%%
%%  Plot original (i.e. unprocessed)  FID of data set 2
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotFid2Orig';


%--- check data existence ---
if ~isfield(mrsi.spec2,'fidOrig')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end

% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFid2Orig') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFid2Orig)
        delete(mrsi.fhFid2Orig)
    end
    mrsi = rmfield(mrsi,'fhFid2Orig');
end
% create figure if necessary
if ~isfield(mrsi,'fhFid2Orig') || ~ishandle(mrsi.fhFid2Orig)
    mrsi.fhFid2Orig = figure('IntegerHandle','off');
    titleStrFid = sprintf(' Original FID 2');
    set(mrsi.fhFid2Orig,'NumberTitle','off','Name',titleStrFid,'Position',[650 45 560 550],...
        'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFid2Orig)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFid2Orig)
            return
        end
    end
end
clf(mrsi.fhFid2Orig)
timeVec = mrsi.spec2.dwell*(0:mrsi.spec2.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.mrsiFormat<4
    plot(real(mrsi.spec2.fidOrig),'r')
    hold on
        plot(imag(mrsi.spec2.fidOrig),'g')
        plot(abs(mrsi.spec2.fidOrig))   % blue
    hold off
    xlabel('time [pts]')
    ylabel('Original FID 2 [a.u.]')
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(mrsi.spec2.fidOrig));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(mrsi.spec2.fidOrig))
    ylabel('Original FID 2 [rad]')
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(mrsi.spec2.fidOrig));
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
mrsi.expt.fid    = mrsi.spec2.fidOrig;
mrsi.expt.sf     = mrsi.spec2.sf;
mrsi.expt.sw_h   = mrsi.spec2.sw_h;
mrsi.expt.nspecC = mrsi.spec2.nspecC;


