%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotFid1Single( f_new )
%%
%%  Plot raw FID of data set 1.
%% 
%%  01-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotFid1Single';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec1,'fid')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME);
    return
end
if length(size(data.spec1.fid))~=3 && ~(length(size(data.spec1.fid))==2 && data.scrollRep==1)
    fprintf('%s ->\nSpectral data set 1 does not have 3 dimensions nor\n',FCTNAME);
    fprintf('is it 2D with repetition #1 selected.\n');
    return
end
if data.scrollRep>data.spec1.nr
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,data.scrollRep,data.spec1.nr)
    return
end
if data.scrollRcvr>data.spec1.nRcvrs
    fprintf('%s ->\nSelected receiver number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,data.scrollRcvr,data.spec1.nRcvrs)
    return
end

%--- check consistency of data dimension and display selection ---
fidSize = size(data.spec1.fid);
if length(fidSize)==2
    if fidSize(2)<data.scrollRcvr
        fprintf('FID 1 data size does not allow multi-receiver display\n(Hint: Make sure receivers haven''t been combined yet).\n\n');
        return
    end
end
if length(fidSize)==3
    if fidSize(2)<data.scrollRcvr
        fprintf('FID 1 data size does not allow multi-receiver display\n(Hint: Make sure receivers haven''t been combined yet)\n\n');
        return
    end
    if fidSize(3)<data.scrollRep
        fprintf('FID 1 data size does not allow selected NR display\n(Hint: Make sure repetitions haven''t been combined yet)\n\n');
        return
    end
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhFid1Single') && ~flag.procKeepFig
    if ishandle(data.fhFid1Single)
        delete(data.fhFid1Single)
    end
    data = rmfield(data,'fhFid1Single');
end
% create figure if necessary
if ~isfield(data,'fhFid1Single') || ~ishandle(data.fhFid1Single)
    data.fhFid1Single = figure('IntegerHandle','off');
    set(data.fhFid1Single,'NumberTitle','off','Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhFid1Single)
    if flag.procKeepFig
        if ~SP2_KeepFigure(proc.fhFid1Single)
            return
        end
    end
end
set(data.fhFid1Single,'Name',sprintf(' FID 1: Receiver %.0f, Repetition %.0f',data.scrollRcvr,data.scrollRep))
clf(data.fhFid1Single)

%--- FID apodization handling ---
if data.spec1.nspecC<data.fidCut        % no apodization
    nspecC = data.spec1.nspecC;
else
    nspecC = data.fidCut;
end

%--- acquistion time vector ---
timeVec = data.spec1.dwell*(0:nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- FID visualization ---
if flag.dataFormat==1           % real
    plot(real(data.spec1.fid(:,data.scrollRcvr,data.scrollRep)))
    [minX maxX minY maxY] = SP2_IdealAxisValues(real(data.spec1.fid(1:nspecC,data.scrollRcvr,data.scrollRep)));
elseif flag.dataFormat==2       % imaginary
    plot(imag(data.spec1.fid(:,data.scrollRcvr,data.scrollRep)))
    [minX maxX minY maxY] = SP2_IdealAxisValues(imag(data.spec1.fid(1:nspecC,data.scrollRcvr,data.scrollRep)));
elseif flag.dataFormat==3       % magnitude
    plot(abs(data.spec1.fid(:,data.scrollRcvr,data.scrollRep)))
    [minX maxX minY maxY] = SP2_IdealAxisValues(abs(data.spec1.fid(1:nspecC,data.scrollRcvr,data.scrollRep)));
else                            % phase
    datFid = angle(data.spec1.fid(1:nspecC,data.scrollRcvr,data.scrollRep));
    
    %--- linear detrend (i.e. frequency correction) ---
    if flag.dataPhaseLinCorr
        datFid = unwrap(datFid);
        coeff  = polyfit(1:length(datFid),datFid',1);         % 1st order fit
        datFid = datFid - polyval(coeff,1:length(datFid))';   % 1st order correction             
    end
    
    plot(datFid)
    [minX maxX minY maxY] = SP2_IdealAxisValues(datFid);
end 
if flag.dataFormat<4
    ylabel('FID 1 [a.u.]')
else
    ylabel('FID 1 [rad]')
end
if flag.dataFormat==1
    legend('real')
elseif flag.dataFormat==2
    legend('imag')
elseif flag.dataFormat==3
    legend('magn')
else
    legend('phase')
end
if flag.dataAmpl        % direct assignment
    minY = data.amplMin;
    maxY = data.amplMax;
end
axis([minX maxX minY maxY])
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


%--- update success flag ---
f_succ = 1;

end
