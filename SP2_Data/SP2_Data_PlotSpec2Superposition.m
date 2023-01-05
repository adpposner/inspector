%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotSpec2Superposition( f_new )
%%
%%  Plot superposition of raw spectra from data set 2.
%% 
%%  01-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotSpec2Superposition';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec2,'fid')
    fprintf('%s ->\nData of spectrum 2 does not exist. Load first.\n',FCTNAME);
    return
end
if length(size(data.spec2.fid))~=3 && ~(length(size(data.spec2.fid))==2 && data.selectN==1 && data.select==1)
    fprintf('%s ->\nSpectral data set 2 does not have 3 dimensions nor\n',FCTNAME);
    fprintf('is it 2D with repetition #1 selected.\n');
    return
end
if any(data.select>data.spec2.nr)
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.select),data.spec2.nr)
    return
end
if any(data.rcvrInd>data.spec2.nRcvrs)
    fprintf('%s ->\nSelected receiver number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.rcvrInd),data.spec2.nRcvrs)
    return
end

%--- ppm limit handling ---
if flag.dataPpmShow     % direct
    ppmMin = data.ppmShowMin;
    ppmMax = data.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -data.spec2.sw/2 + data.ppmCalib;
    ppmMax = data.spec2.sw/2  + data.ppmCalib;
end

%--- figure handling ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhSpec2Super') && ~flag.procKeepFig
    if ishandle(data.fhSpec2Super)
        delete(data.fhSpec2Super)
    end
    data = rmfield(data,'fhSpec2Super');
end
% create figure if necessary
if ~isfield(data,'fhSpec2Super') || ~ishandle(data.fhSpec2Super)
    data.fhSpec2Super = figure('IntegerHandle','off');
    set(data.fhSpec2Super,'NumberTitle','off','Name',sprintf(' Spectrum 2: Superposition'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhSpec2Super)
end
clf(data.fhSpec2Super)

%--- definition of color matrix ---
if flag.colormap==0
    colorMat = colormap(jet(data.rcvrN*data.selectN));
elseif flag.colormap==1
    colorMat = colormap(hsv(data.rcvrN*data.selectN));
else
    colorMat = colormap(hot(data.rcvrN*data.selectN));
end
cCnt = 1;       % init total/color counter

% init plot limits
minX = 1e20;
maxX = -1e20;
minY = 1e20;
maxY = -1e20;

%--- receiver and repetition loops ---
hold on
if data.rcvrN*data.selectN<10
    legCell = {};
end
for rcvrCnt = 1:data.rcvrN            % number of selected receivers
    for repCnt = 1:data.selectN       % number of selected spectra
        %--- data processing ---
        if data.spec2.nspecC<data.fidCut        % no apodization
            datSpec = fftshift(fft(data.spec2.fid(:,data.rcvrInd(rcvrCnt),data.select(repCnt))));
        else                                    % apodization
            datSpec = fftshift(fft(data.spec2.fid(1:data.fidCut,data.rcvrInd(rcvrCnt),data.select(repCnt))));
            if rcvrCnt==1 && repCnt==1
                fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
            end
        end

        %--- data extraction: spectrum 2 ---
        if flag.dataFormat==1           % real part
            [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec2.sw,real(datSpec));
        elseif flag.dataFormat==2       % imaginary part
            [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec2.sw,imag(datSpec));
        elseif flag.dataFormat==3       % magnitude
            [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec2.sw,abs(datSpec));
        else                            % phase
            [minI,maxI,ppmZoom,specZoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec2.sw,angle(datSpec));
        end                                             
        if ~f_done
            fprintf('%s ->\nppm extraction of spectrum 2 failed. Program aborted.\n\n',FCTNAME);
            return
        end

        %--- data visualization ---
        plot(ppmZoom,specZoom,'Color',colorMat(cCnt,:))
        cCnt = cCnt + 1;    % update serial/color counter

        %--- axis handling ---
        if ~flag.dataAmpl        % automatic
            [minXind maxXind minYind maxYind] = SP2_IdealAxisValues(ppmZoom,specZoom);
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
        
        %--- legend handling ---
        if data.rcvrN*data.selectN<10
            legCell{(rcvrCnt-1)*data.selectN+repCnt} = sprintf('rcvr %.0f, NR %.0f',data.rcvrInd(rcvrCnt),data.select(repCnt));
        end
    end
end
hold off
set(gca,'XDir','reverse')
[minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
if flag.dataAmpl        % direct
    minY = data.amplMin;
    maxY = data.amplMax;
end
axis([minX maxX minY maxY])
if data.rcvrN*data.selectN<10
    legend(legCell)
end
if flag.dataFormat<4
    ylabel('Amplitude [a.u.]')
else
    ylabel('Angle [rad]')
end
xlabel('Frequency [ppm]')

%--- update success flag ---
f_succ = 1;
