%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotFid1Orig( f_new )
%%
%%  Plot original (i.e. unprocessed) FID of data set 1
%% 
%%  11-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mrsi flag

FCTNAME = 'SP2_MRSI_PlotFid1Orig';


%--- check data existence ---
if ~isfield(mrsi.spec1,'fidimg_orig')
    fprintf('%s ->\nFID image 1 does not exist. Reconstruct first.\n',FCTNAME)
    return
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFid1Orig') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFid1Orig)
        delete(mrsi.fhFid1Orig)
    end
    mrsi = rmfield(mrsi,'fhFid1Orig');
end
% create figure if necessary
if ~isfield(mrsi,'fhFid1Orig') || ~ishandle(mrsi.fhFid1Orig)
    mrsi.fhFid1Orig = figure('IntegerHandle','off');
    titleStrFid = sprintf(' Original FID 1');
    set(mrsi.fhFid1Orig,'NumberTitle','off','Name',titleStrFid,'Position',[650 45 560 550],...
        'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFid1Orig)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFid1Orig)
            return
        end
    end
end
clf(mrsi.fhFid1Orig)
timeVec = mrsi.spec1.dwell*(0:mrsi.spec1.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.mrsiFormat<4
    plot(real(mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA)),'r')
    hold on
        plot(imag(mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA)),'g')
        plot(abs(mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA)))   % blue
    hold off
    ylabel(sprintf('Original FID 1 [a.u.], L/R %.0f, P/A %.0f',mrsi.selectLR,mrsi.selectPA))
    legend('real','imag','magn')
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA)));
    axis([minX maxX -maxY maxY])        % symmetric amplitude range
else
    plot(angle(mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA)))
    ylabel(sprintf('Original FID 1 [rad], L/R %.0f, P/A %.0f',mrsi.selectLR,mrsi.selectPA))
    [minX maxX minY maxY] = SP2_IdealAxisValues(angle(mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA)));
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
mrsi.expt.fid    = mrsi.spec1.fidimg_orig(:,mrsi.selectLR,mrsi.selectPA);
mrsi.expt.sf     = mrsi.spec1.sf;
mrsi.expt.sw_h   = mrsi.spec1.sw_h;
mrsi.expt.nspecC = mrsi.spec1.nspecC;


