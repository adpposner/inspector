%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_QualityArrayShow( f_new )
%%
%%  Plot array of spectra from data set 1.
%% 
%%  12-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_QualityArrayShow';


%--- init success flag ---
f_done = 0;

%--- figure handling: part 1 ---
% potentially open new figure only if requested
% (not if parameters are changed before a figure has been created)
if ~f_new && ~isfield(data,'fhQualityArray')
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
if f_new && isfield(data,'fhQualityArray') && ~flag.dataKeepFig
    if ishandle(data.fhQualityArray)
        delete(data.fhQualityArray)
    end
    data = rmfield(data,'fhQualityArray');
end
% create figure if necessary
if ~isfield(data,'fhQualityArray') || ~ishandle(data.fhQualityArray)
    data.fhQualityArray = figure('IntegerHandle','off');
    set(data.fhQualityArray,'NumberTitle','off','Name',sprintf(' Q-A: Array'),...
        'Position',[314 114 893 550],'Color',[1 1 1]);
else
    set(0,'CurrentFigure',data.fhQualityArray)
    if flag.dataKeepFig
        if ~SP2_KeepFigure(data.fhQualityArray)
            return
        end
    end
end
clf(data.fhQualityArray)

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
for plCnt = 1:data.quality.cols*data.quality.rows
    if selectIndAppl+plCnt-1<=data.quality.selectN
        %--- NR index determination ---
        nrCnt = data.quality.select(selectIndAppl+plCnt-1);

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
        subplot(data.quality.rows,data.quality.cols,plCnt);
        if flag.dataQualityCMap>0
            plot(ppmZoom,specZoom,'Color',colorMat(cCnt,:))
            cCnt = cCnt + 1;    % update serial/color counter
        else
            plot(ppmZoom,specZoom)
        end
        set(gca,'XDir','reverse')
        if ~flag.dataQualityAmplMode        % direct
            [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
            minY = data.quality.amplMin;
            maxY = data.quality.amplMax;
        else                                % automatic
            [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
        end
        axis([minX maxX minY maxY])
        title(sprintf('NR %.0f',nrCnt))
        if plCnt==data.quality.cols*data.quality.rows
            xlabel('frequency [ppm]')
        end
    end
end
    
%--- update success flag ---
f_done = 1;

end
