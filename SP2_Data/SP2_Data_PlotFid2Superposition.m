%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotFid2Superposition( f_new )
%%
%%  Plot superposition of FID range
%% 
%%  01-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotFid2Superposition';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec2,'fid')
    fprintf('%s ->\nFID 2 does not exist. Load data first.\n',FCTNAME);
    return
end
if any(data.select>data.spec2.nr) && ~flag.dataAllSelect
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.select),data.spec2.nr)
    return
end
if max(data.rcvrInd)>data.spec2.nRcvrs
    fprintf('%s ->\nSelected receiver number exceeds experiment dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.rcvrInd),data.spec2.nRcvrs)
    return
end

%--- repetition selection ---
if flag.dataAllSelect       % all repetitions
    dataSelectN = data.spec2.nr;
    dataSelect  = 1:data.spec2.nr;
else                        % selected repeitions
    dataSelectN = data.selectN;
    dataSelect  = data.select;
end

%--- figure creation ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhFid2Super') && ~flag.procKeepFig
    if ishandle(data.fhFid2Super)
        delete(data.fhFid2Super)
    end
    data = rmfield(data,'fhFid2Super');
end
% create figure if necessary
titleStr = sprintf(' FID 2 Superpos: Rcvrs %s, Rep %s',...
           SP2_Vec2PrintStr(data.rcvrInd,0),SP2_Vec2PrintStr(dataSelect,0));
if ~isfield(data,'fhFid2Super') || ~ishandle(data.fhFid2Super)
    data.fhFid2Super = figure('IntegerHandle','off');
    set(data.fhFid2Super,'NumberTitle','off','Name',titleStr,...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhFid2Super)
    set(gcf,'Name',titleStr);
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhFid2Super)
            return
        end
    end
end
clf(data.fhFid2Super)

%--- FID apodization handling ---
if data.spec2.nspecC<data.fidCut        % no apodization
    nspecC = data.spec2.nspecC;
else
    nspecC = data.fidCut;
end

%--- acquistion time vector ---
timeVec = data.spec2.dwell*(0:nspecC-1);       % acquisition time [s]
% check time scaling:   1) data.time(1,1)=0 -> starting point at time zero
%                       2) (nspecC-1)*1/SW_h = total acquisition time

%--- init plot limits ---
minX = 1e20;
maxX = -1e20;
minY = 1e20;
maxY = -1e20;

%--- define color matrix ---
colorMat = colormap(jet(data.rcvrN*dataSelectN));
cCnt = 1;       % init total/color counter

%--- FID visualization ---
hold on
for rcvrCnt = 1:data.rcvrN
    for nrCnt = 1:dataSelectN
        %--- plot FIDs ---
        if flag.dataFormat==1           % real part
            datFid = real(data.spec2.fid(1:nspecC,data.rcvrInd(rcvrCnt),dataSelect(nrCnt)));
        elseif flag.dataFormat==2       % imaginary part
            datFid = imag(data.spec2.fid(1:nspecC,data.rcvrInd(rcvrCnt),dataSelect(nrCnt)));
        elseif flag.dataFormat==3       % magnitude
            datFid = abs(data.spec2.fid(1:nspecC,data.rcvrInd(rcvrCnt),dataSelect(nrCnt)));
        else
            datFid = angle(data.spec2.fid(1:nspecC,data.rcvrInd(rcvrCnt),dataSelect(nrCnt)));
            
            %--- linear detrend (i.e. frequency correction) ---
            if flag.dataPhaseLinCorr
                datFid = unwrap(datFid);
                coeff  = polyfit(1:length(datFid),datFid',1);         % 1st order fit
                datFid = datFid - polyval(coeff,1:length(datFid))';   % 1st order correction             
            end
        end
        plot(datFid)
        cCnt = cCnt + 1;                % update serial/color counter
        
        %--- axis handling ---
        [minXind maxXind minYind maxYind] = SP2_IdealAxisValues(datFid);
        if minXind<minX
            minX = minXind;
        end
        if maxXind>maxX
            maxX = maxXind;
        end
        if minYind<minY
            minY = minYind;
        end
        if maxYind>maxY
            maxY = maxYind;
        end
    end
end
hold off
if flag.dataFormat<4
    ylabel('FID 1 Superposition [a.u.]')
else
    ylabel('FID 1 Superposition [rad]')
end
axis([minX maxX minY maxY])        % symmetric amplitude range
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
