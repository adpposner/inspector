%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_PlotSpec1Superposition( f_new )
%%
%%  Plot superposition of raw spectra from data set 1.
%% 
%%  01-2012, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_PlotSpec1Superposition';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data.spec1,'fid')
    fprintf('%s ->\nData of spectrum 1 does not exist. Load first.\n',FCTNAME)
    return
end
if length(size(data.spec1.fid))~=3 && ~(length(size(data.spec1.fid))==2 && data.selectN==1 && data.select==1)
    fprintf('%s ->\nSpectral data set 1 does not have 3 dimensions nor\n',FCTNAME)
    fprintf('is it 2D with repetition #1 selected.\n')
    return
end
if any(data.select>data.spec1.nr)
    fprintf('%s ->\nSelected repetition number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.select),data.spec1.nr)
    return
end
if any(data.rcvrInd>data.spec1.nRcvrs)
    fprintf('%s ->\nSelected receiver number exceeds data dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.rcvrInd),data.spec1.nRcvrs)
    return
end

%--- ppm limit handling ---
if flag.dataPpmShow     % direct
    ppmMin = data.ppmShowMin;
    ppmMax = data.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -data.spec1.sw/2 + data.ppmCalib;
    ppmMax = data.spec1.sw/2  + data.ppmCalib;
end

%--- figure handling ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhSpec1Super')
    if ishandle(data.fhSpec1Super)
        delete(data.fhSpec1Super)
    end
    data = rmfield(data,'fhSpec1Super');
end
% create figure if necessary
if ~isfield(data,'fhSpec1Super') || ~ishandle(data.fhSpec1Super)
    data.fhSpec1Super = figure('IntegerHandle','off');
    set(data.fhSpec1Super,'NumberTitle','off','Name',sprintf(' Spectrum 1: Superposition'),...
        'Position',[650 45 560 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhSpec1Super)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhSpec1Super)
            return
        end
    end
end
clf(data.fhSpec1Super)

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
        if data.spec1.nspecC<data.fidCut        % no apodization
            datSpec = fftshift(fft(data.spec1.fid(:,data.rcvrInd(rcvrCnt),data.select(repCnt))));
        else                                    % apodization
            datSpec = fftshift(fft(data.spec1.fid(1:data.fidCut,data.rcvrInd(rcvrCnt),data.select(repCnt))));
            if rcvrCnt==1 && repCnt==1
                fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut)
            end
        end
 
        %--- data extraction: spectrum 1 ---
        if flag.dataFormat==1           % real part
            [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec1.sw,real(datSpec));
        elseif flag.dataFormat==2       % imaginary part
            [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec1.sw,imag(datSpec));
        elseif flag.dataFormat==3       % magnitude
            [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec1.sw,abs(datSpec));
        else                            % phase
            [minI,maxI,ppmZoom,spec1Zoom,f_done] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                       data.spec1.sw,angle(datSpec));
        end                                             
        if ~f_done
            fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME)
            return
        end

        %--- data visualization ---
        plot(ppmZoom,spec1Zoom,'Color',colorMat(cCnt,:))
        cCnt = cCnt + 1;    % update serial/color counter

        %--- axis handling ---
        if ~flag.dataAmpl        % automatic
            [minXind maxXind minYind maxYind] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
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
[minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,spec1Zoom);
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
