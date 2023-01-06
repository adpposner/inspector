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

%--- phase cyclec steps ---
phCycleN = 8;

%--- figure handling ---
% remove existing figure if new figure is forced
if f_new && isfield(data,'fhQualityArray')
    if ishandle(data.fhQualityArray)
        delete(data.fhQualityArray)
    end
    data = rmfield(data,'fhQualityArray');
end
% create figure if necessary
if ~isfield(data,'fhQualityArray') || ~ishandle(data.fhQualityArray)
    data.fhQualityArray = figure('IntegerHandle','off');
    set(data.fhQualityArray,'NumberTitle','off','Name',sprintf(' Quality Assessment: Spectral Array'),...
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

%--- separate processing stream based on data dimension ---
if ~isfield(data.spec1,'fidArrRxComb')
    %--- init Rx-combined FID array ---
    % note the unchanged data dimension which will be collapsed lateron 
    data.spec1.fidArrRxComb = data.spec1.fidArr;    
    
    %--- experiment type selection ---
    if data.spec1.nr>1      % JDE experiment

        %--- phase/ECC correction ---
        if flag.dataPhaseCorr==1        % Klose method
            if flag.dataKloseMode==1            % summation of phase cycling steps before Klose correction with one, combined phase trace
                %--- preprocessing of water reference ---
                if ~SP2_Data_PhaseCorrKloseRxComb
                    return
                end

                %--- Klose correction of all JDE acquisitions (phase cycle, edit
                %--- on/off, NR) with identical phase reference ---
                phaseCorr = permute(repmat(exp(-1i*data.spec2.klosePhase),[1 1 data.spec1.seriesN data.spec1.nr]),[3 1 2 4]);            
                data.spec1.fidArrRxComb(:,:,data.rcvrInd,:) = data.spec1.fidArrRxComb(:,:,data.rcvrInd,:) .* phaseCorr;

                %--- info printout ---
                fprintf('(Combined phase-cycle) Klose phase correction applied.\n');
            elseif flag.dataKloseMode==2        % Klose correction with individual phase cycling steps
                for seriesCnt = 1:data.spec1.seriesN
                    for nrCnt = 1:data.spec1.nr
                        for rCnt = 1:data.spec1.nRcvrs
                            if ndims(data.spec2.fid)==2     % spectral + receivers, single reference for all
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
                            else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
        %                         phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,ceil(nrCnt/2))));
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,min(length(data.select)/2,nPhCycle))+1)));

                                %--- info printout ---
                                if seriesCnt==1 && nrCnt==1 && rCnt==1
                                    fprintf('Assumed phase cycle: %.0f steps\n',nPhCycle);
                                end
                            end
                            phaseVec = exp(-1i*phaseCorr');
                            data.spec1.fidArrRxComb(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArrRxComb(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
                        end
                    end
                end

                %--- info printout ---
                fprintf('(Phase cycle-specific) Klose phase correction applied.\n');
            else            % Klose correction with selected/single reference (from arrayed experiment)
                %--- consistency check ---
                if ndims(data.spec2.fid)==2
                    fprintf('Selected reference scan is not arrayed\nand does not have multiple NR''s available (NR=1 is used).\n');
                    if data.phaseCorrNr==1
                        fprintf('... just a WARNING.\n');
                    else            % selected NR does not exist
                        return
                    end
                else
                    if data.spec2.nr<data.phaseCorrNr
                        fprintf('Selected single water reference exceeds data set dimensions (%.0f>%.0f).\nProgram aborted.\n',...
                                data.phaseCorrNr,data.spec2.nr)
                       return
                    end
                end

                %--- apply correction ---
                for seriesCnt = 1:data.spec1.seriesN
                    for nrCnt = 1:data.spec1.nr
                        for rCnt = 1:data.spec1.nRcvrs
                            if ndims(data.spec2.fid)==2     % spectral + receivers, single reference for all
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
                            else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
        %                         phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,ceil(nrCnt/2))));
                                if data.spec1.nr==1         % single reference
                                    phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,min(length(data.select)/2,nPhCycle))+1)));

                                    %--- info printout ---
                                    if seriesCnt==1 && nrCnt==1 && rCnt==1
                                        fprintf('Assumed phase cycle: %.0f steps\n',nPhCycle);
                                    end
                                else                        % reference array (e.g. multiple JDE frequencies)
                                    phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,data.phaseCorrNr)));
                                end
                            end
                            phaseVec = exp(-1i*phaseCorr');
                            data.spec1.fidArrRxComb(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArrRxComb(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
                        end
                    end
                end

                %--- info printout ---
                fprintf('Single scan-specific Klose phase correction applied.\n');
            end
        elseif flag.dataPhaseCorr==2
            fprintf('%s ->\nOnly the Klose method is currently supported for phase/ECC correction. Program aborted.\n',FCTNAME);
            return
        else
            %--- info printout ---
            fprintf('No phase/ECC correction applied.\n');
        end

        %--- Rx combination ---
        if flag.dataRcvrWeight      % weighted summation
            weightVec         = abs(data.spec2.fid(1,data.rcvrInd));
            weightVec         = weightVec/max(weightVec);
            weightMat         = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
            data.spec1.fidArrRxComb = data.spec1.fidArrRxComb(:,:,data.rcvrInd,:) .* weightMat;
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));
        else
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb(:,:,data.rcvrInd,:),3));
        end
    else            % single NR (no JDE)
        %--- serial phase/frequency alignment ---
%         spec1FidRxSum = complex(zeros(data.spec1.seriesN,data.spec1.nspecC));       % matrix of all Rx-summed FIDs
        weightVec     = abs(data.spec2.fid(1,data.rcvrInd));
        weightVec     = weightVec/max(weightVec);
        weightMat     = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);

        %--- serial analysis ---
        for seriesCnt = 1:data.spec1.seriesN

            %--- phase/ECC correction ---
            if flag.dataPhaseCorr==1
                for rCnt = 1:data.spec1.nRcvrs
                    phaseCorr  = unwrap(angle(data.spec2.fid(:,rCnt)));
                    phaseKlose = permute(repmat(exp(-1i*phaseCorr),[1 data.spec1.nr]),[2 1]);
                    data.spec1.fidArrRxComb(seriesCnt,:,rCnt) = squeeze(data.spec1.fidArrRxComb(seriesCnt,:,rCnt)) .* phaseKlose;
                end

                %--- info printout ---
                fprintf('Klose phase correction applied.\n');
            elseif flag.dataPhaseCorr==2
                fprintf('%s ->\nOnly the Klose method is currently supported for phase/ECC correction. Program aborted.\n',FCTNAME);
                return
            else
                %--- info printout ---
                fprintf('No phase/ECC correction applied.\n');
            end
        end

        %--- Rx combination ---
        if flag.dataRcvrWeight      % weighted summation
            weightVec         = abs(data.spec2.fid(1,data.rcvrInd));
            weightVec         = weightVec/max(weightVec);
            weightMat         = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.seriesN]),[3 1 2]);
            data.spec1.fidArrRxComb = data.spec1.fidArrRxComb(:,:,data.rcvrInd) .* weightMat;
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));
        else
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb(:,:,data.rcvrInd),3));
        end
    end         % of iteration loop
end

%--- data reformating: merge series ---
% from fid(series,nspecC,individual NR) to fid(nspecC, total NR)
% note that this step is outside the above processing module in case
% further corrections have been applied, ie. to make sure the
% latest/current data is used.
% fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 1 3]),data.spec1.nspecC,...
%                        data.spec1.seriesN*data.spec1.nr);
fidArrSerial = reshape(permute(data.spec1.fidArrRxComb,[2 3 1]),data.spec1.nspecC,...
                       data.spec1.seriesN*data.spec1.nr);

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

%--- selected spectral series ---
for plCnt = 1:data.quality.cols*data.quality.rows
    if selectIndAppl+plCnt-1<=data.quality.selectN
        %--- NR index determination ---
        nrCnt = data.quality.select(selectIndAppl+plCnt-1);

        %--- data processing ---
        if data.spec1.nspecC<data.fidCut        % no apodization
            lbWeight = exp(-data.quality.lb*data.spec1.dwell*(0:data.spec1.nspecC-1)*pi)';
            datSpec  = fftshift(fft(fidArrSerial(:,nrCnt).*lbWeight,data.quality.zf));
        else                                    % apodization
            lbWeight = exp(-data.quality.lb*data.spec1.dwell*(0:data.quality.cut-1)*pi)';
            datSpec = fftshift(fft(fidArrSerial(1:data.quality.cut,nrCnt).*lbWeight,data.quality.zf));
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
        plot(ppmZoom,specZoom)
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
