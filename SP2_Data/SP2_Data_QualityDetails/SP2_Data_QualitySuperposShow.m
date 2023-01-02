%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_QualitySuperposShow( f_new )
%%
%%  Plot superposition of spectra from data set 1.
%% 
%%  12-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data flag

FCTNAME = 'SP2_Data_QualitySuperposShow';


%--- init success flag ---
f_done = 0;

%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && ~isfield(data,'fhQualitySuperpos')
    return
end

%--- check data existence ---
if ~isfield(data,'spec1')
    fprintf('%s ->\nSpectral data series 1 does not exist. Load first.\n',FCTNAME);
    return
elseif ~isfield(data.spec1,'fidArr')
    fprintf('%s ->\nSpectral FID series 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- consistency checks ---
if any(data.quality.select>data.spec1.nr*data.spec1.seriesN)
    fprintf('%s ->\nMaximum experiment exceeds number of available spectra:\n',FCTNAME);
    fprintf('NR (%.0f) x scans (%.0f) = %.0f\n',data.spec1.nr,data.spec1.seriesN,...
            data.spec1.nr*data.spec1.seriesN)
    return
end
if max(data.rcvrInd)>data.spec1.nRcvrs
    fprintf('%s ->\nSelected receiver number exceeds experiment dimension (%.0f>%.0f).\n',...
            FCTNAME,max(data.rcvrInd),data.spec1.nRcvrs)
    return
end
if length(size(data.spec1.fid))<2
    fprintf('%s -> Data set dimension is too small.\nThis is not a multi-receiver experiment or might have been summed already.\n',FCTNAME);
    return
end
if flag.dataRcvrWeight          % weighted summation
    if ~isfield(data.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load first for weighted summation.\n',FCTNAME);
        return
    end
end

%--- figure handling: part 2 ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhQualitySuperpos') && ~flag.dataKeepFig
    if ishandle(data.fhQualitySuperpos)
        delete(data.fhQualitySuperpos)
    end
    data = rmfield(data,'fhQualitySuperpos');
end

% create figure if necessary
if ~isfield(data,'fhQualitySuperpos') || ~ishandle(data.fhQualitySuperpos)
    data.fhQualitySuperpos = figure('IntegerHandle','off');
    set(data.fhQualitySuperpos,'NumberTitle','off','Name',sprintf(' Q-A: Superposition'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhQualitySuperpos)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhQualitySuperpos)
            return
        end
    end
end
clf(data.fhQualitySuperpos)

%--- renew Rx summation when new figure is forced (to update the data) ---
if f_new
    if isfield(data.spec1,'fidArrSerial')
        data.spec1 = rmfield(data.spec1,'fidArrSerial');
    end
end

%--- separate processing stream based on data dimension ---
if ~isfield(data.spec1,'fidArrRxComb')
    if ~SP2_Data_QualityCalcFidArrRxComb
        return
    end
end 
if ~isfield(data.spec1,'fidArrSerial')
    if ~SP2_Data_QualityCalcFidArrSerial
        return
    end
end
   
% %--- data reformating: merge series ---
% % from fid(series,nspecC,individual NR) to fid(nspecC, total NR)
% % note that this step is outside the above processing module in case
% % further corrections have been applied, ie. to make sure the
% % latest/current data is used.
% % fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 1 3]),data.spec1.nspecC,...
% %                        data.spec1.seriesN*data.spec1.nr);
% fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 3 1]),data.spec1.nspecC,...
%                        data.spec1.seriesN*data.spec1.nr);

%--- ppm limit handling ---
if ~flag.dataQualityFrequMode       % direct
    ppmMin = data.quality.frequMin;
    ppmMax = data.quality.frequMax;
else                                % full sweep width (symmetry assumed)
    ppmMin = -data.spec1.sw/2 + data.ppmCalib;
    ppmMax = data.spec1.sw/2  + data.ppmCalib;
end

%--- selection of first spectrum to be displayed ---
% note that the display value is not necessarily applied in the end
if data.quality.selectN>0
    [val,selectIndAppl] = min(abs(data.quality.select-data.quality.selectNr));
else
    fprintf('%s ->\nEmpty NR selection detected. Program aborted.\n',FCTNAME);
    return
end

%--- definition of color matrix ---
if flag.dataQualityCMap==1
    colorMat = colormap(jet(data.quality.cols*data.quality.rows));
elseif flag.dataQualityCMap==2
    colorMat = colormap(hsv(data.quality.cols*data.quality.rows));
elseif flag.dataQualityCMap==3
    colorMat = colormap(hot(data.quality.cols*data.quality.rows));
end
cCnt = 1;       % init total/color counter

%--- selected spectral series ---
nrFirst = 1e6;
nrLast  = -1e6;
maxPpmVec = zeros(1,data.quality.cols*data.quality.rows);
maxAmpVec = zeros(1,data.quality.cols*data.quality.rows);
validId   = zeros(1,data.quality.cols*data.quality.rows);
hold on
for plCnt = 1:data.quality.cols*data.quality.rows
    if selectIndAppl+plCnt-1<=data.quality.selectN
        %--- update of valid ID ---
        validId(plCnt) = 1;
        
        %--- NR index determination ---
        nrCnt = data.quality.select(selectIndAppl+plCnt-1);

        %--- label extraction ---
        if nrCnt<nrFirst
            nrFirst = nrCnt;
        end
        if nrCnt>nrLast
            nrLast = nrCnt;
        end
        
        %--- data processing ---
        if data.spec1.nspecC<data.fidCut        % no apodization
            lbWeight = exp(-data.quality.lb*data.spec1.dwell*(0:data.spec1.nspecC-1)*pi)';
            datSpec  = fftshift(fft(data.spec1.fidArrSerial(:,nrCnt).*lbWeight,data.quality.zf));
        else                                    % apodization
            lbWeight = exp(-data.quality.lb*data.spec1.dwell*(0:data.quality.cut-1)*pi)';
            datSpec = fftshift(fft(data.spec1.fidArrSerial(1:data.quality.cut,nrCnt).*lbWeight,data.quality.zf));
            if nrCnt==1
                fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',...
                        FCTNAME,data.quality.cut)
            end
        end
        
        %--- zero order phase correction ---
        datSpec = datSpec .* exp(1i*data.quality.phaseZero*pi/180)';

        %--- data extraction: spectrum 1 ---
        if flag.dataQualityFormat==1            % real part
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec1.sw,real(datSpec));
        elseif flag.dataQualityFormat==2        % imaginary part
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec1.sw,imag(datSpec));
        elseif flag.dataQualityFormat==3        % magnitude mode
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec1.sw,abs(datSpec));
        else                                    % phase mode                                             
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec1.sw,angle(datSpec));
        end                                             
        if ~f_succ
            fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
            return
        end

        %--- data visualization ---
        if flag.dataQualityCMap>0
            h = plot(ppmZoom,specZoom,'Color',colorMat(cCnt,:));
            cCnt = cCnt + 1;    % update serial/color counter
        else
            h = plot(ppmZoom,specZoom);
        end
        
        %--- maximum determination ---
        [maxAmpVec(plCnt),maxPpmVec(plCnt)] = max(specZoom);
        
        %--- keep min/max for automated determination of amplitude limits ---
        if flag.dataQualityAmplMode         % automatic
            if plCnt==1
                specMin4Auto = specZoom;
                specMax4Auto = specZoom;
            else
                specMin4Auto = min(specMin4Auto,specZoom);
                specMax4Auto = max(specMax4Auto,specZoom);
            end
        end        
        
        %--- preserve selected plot handles ---
        if nrCnt==nrFirst
            h1 = h;
        end
        if data.quality.selectN>=selectIndAppl+round(data.quality.cols*data.quality.rows/3)-1
            if nrCnt==data.quality.select(selectIndAppl+round(data.quality.cols*data.quality.rows/3)-1);
                h2 = h;
            end
        end
        if data.quality.selectN>=selectIndAppl+round(data.quality.cols*data.quality.rows/2)-1
            if nrCnt==data.quality.select(selectIndAppl+round(data.quality.cols*data.quality.rows/2)-1);
                h3 = h;
            end
        end
        if data.quality.selectN>=selectIndAppl+round(3*data.quality.cols*data.quality.rows/4)-1
            if nrCnt==data.quality.select(selectIndAppl+round(3*data.quality.cols*data.quality.rows/4)-1);
                h4 = h;
            end
        end
        if nrCnt==nrLast
            h5 = h;
        end
    end
end

%--- info printout ---
if ~isfield(data,'fhQualitySeries')
    fprintf('\nNR %.0f..%.0f (%.0f of total selection %s):\n',nrFirst,nrLast,...
            length(find(validId)),data.quality.selectStr)
    ampVec = maxAmpVec(find(validId));
    fprintf('Amplitude: mean %.1f, SD %.1f (%.1f%%)\n',mean(ampVec),std(ampVec),100*std(ampVec)/mean(ampVec));
    fprintf('Frequency spread: SD %.2f Hz\n',data.spec1.sw_h/data.quality.zf*std(maxPpmVec(find(validId))));
end

%--- axis definition ---
% note that this done only once here, ie. it is not spectrum-specific
if flag.dataQualityAmplMode         % automatic
    [minX maxX minY fake] = SP2_IdealAxisValues(ppmZoom,specMin4Auto);
    [minX maxX fake maxY] = SP2_IdealAxisValues(ppmZoom,specMax4Auto);
else                                % direct
    [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
    minY = data.quality.amplMin;
    maxY = data.quality.amplMax;
end
axis([minX maxX minY maxY])
set(gca,'XDir','reverse')
title(sprintf('NR %.0f..%.0f (of total selection: %s)',nrFirst,nrLast,data.quality.selectStr))
xlabel('frequency [ppm]')
hold off
   
%--- data legend ---
if flag.dataQualityLegend
    if exist('h2','var') && exist('h3','var') && exist('h4','var') && exist('h5','var')
        legend([h1, h2, h3, h4, h5],num2str(nrFirst),num2str(data.quality.select(selectIndAppl+round(data.quality.cols*data.quality.rows/4)-1)),...
                                    num2str(data.quality.select(selectIndAppl+round(data.quality.cols*data.quality.rows/2)-1)),...
                                    num2str(data.quality.select(selectIndAppl+round(3*data.quality.cols*data.quality.rows/4)-1)),num2str(nrLast))
    elseif exist('h3','var')
        legend([h1, h3, h5],num2str(nrFirst),num2str(data.quality.select(selectIndAppl+round(data.quality.cols*data.quality.rows/2)-1)),num2str(nrLast))
    else
        legend([h1, h5],num2str(nrFirst),num2str(nrLast))
    end
end
    
%--- update success flag ---
f_done = 1;
