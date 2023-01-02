%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PlotFidSuperpos( f_new )
%%
%%  Plot superposition of FIDs from data sets 1 and 2.
%% 
%%  12-2011, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile mrsi flag

FCTNAME = 'SP2_MRSI_PlotFidSuperpos';


%--- check data existence ---
if flag.mrsiNumSpec==0      % single spectrum
    fprintf('%s ->\nFunction not supported in single spectrum mode.\n',FCTNAME);
    return
else                        % 2 spectra
    if ~isfield(mrsi.spec1,'fid')
        fprintf('%s ->\nData of spectrum 1 does not exist. Load/analyze first.\n',FCTNAME);
        return
    end
    if ~isfield(mrsi.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load/analyze first.\n',FCTNAME);
        return
    end
end

% remove existing figure if new figure is forced
if f_new && isfield(mrsi,'fhFidSuper') && ~flag.mrsiKeepFig
    if ishandle(mrsi.fhFidSuper)
        delete(mrsi.fhFidSuper)
    end
    mrsi = rmfield(mrsi,'fhFidSuper');
end
% create figure if necessary
if ~isfield(mrsi,'fhFidSuper') || ~ishandle(mrsi.fhFidSuper)
    mrsi.fhFidSuper = figure('IntegerHandle','off');
    set(mrsi.fhFidSuper,'NumberTitle','off','Name',sprintf(' FID 1'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',mrsi.fhFidSuper)
    if flag.mrsiKeepFig
        if ~SP2_KeepFigure(mrsi.fhFidSuper)
            return
        end
    end
end
clf(mrsi.fhFidSuper)
timeVec1 = mrsi.spec1.dwell*(0:mrsi.spec1.nspecC-1);       % acquisition time [s]
timeVec2 = mrsi.spec2.dwell*(0:mrsi.spec2.nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
hold on
if flag.mrsiFormat==1           % real part
    plot(timeVec1,real(mrsi.spec1.fid))
    plot(timeVec2,real(mrsi.spec2.fid),'r')
elseif flag.mrsiFormat==2       % imaginary part
    plot(timeVec1,imag(mrsi.spec1.fid))
    plot(timeVec2,imag(mrsi.spec2.fid),'r')
elseif flag.mrsiFormat==3       % magnitude
    plot(timeVec1,abs(mrsi.spec1.fid))
    plot(timeVec2,abs(mrsi.spec2.fid),'r')
else                            % phase
    plot(timeVec1,angle(mrsi.spec1.fid))
    plot(timeVec2,angle(mrsi.spec2.fid),'r')
end   
hold off
xlabel('time [s]')
if flag.mrsiFormat<4
    ylabel('FID Superposition [a.u.]')
else
    ylabel('FID Superposition [rad]')
end
legend('FID 1','FID 2')
if flag.mrsiFormat==1           % real part
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(timeVec1,real(mrsi.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(timeVec2,real(mrsi.spec2.fid));
elseif flag.mrsiFormat==2       % imaginary part
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(timeVec1,imag(mrsi.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(timeVec2,imag(mrsi.spec2.fid));
elseif flag.mrsiFormat==3       % magnitude
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(timeVec1,abs(mrsi.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(timeVec2,abs(mrsi.spec2.fid));
else                            % phase
    [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValues(timeVec1,angle(mrsi.spec1.fid));
    [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValues(timeVec2,angle(mrsi.spec2.fid));
end
minX = min(minX1,minX2);
maxX = max(maxX1,maxX2);
minY = min(minY1,minY2);
maxY = max(maxY1,maxY2);
axis([minX maxX minY maxY])        % symmetric amplitude range
set(gca,'XGrid','on','YGrid','On')
%--- add time axis ---
maxLenPts = max(mrsi.spec1.nspecC,mrsi.spec2.nspecC);
ptsStep   = 100*round(maxLenPts/(8*100));       % ~8 labels in full 100 steps
timeAxis = axes('Position',get(gca,'Position'),'XAxisLocation','top',...
                'Color','none','XLim',[1 maxLenPts],...
                'XTick',1:ptsStep:maxLenPts,'YTick',[]);
xlabel('time [pts of spec1]')
