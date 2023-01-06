%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_Dat1SeriesOverview
%% 
%%  Plot overview of all repetitions.
%%  1) Rx channels are summed together, NR are not.
%%  2) note that all calculations are local, no result is kept. The actual
%%  summation is done in SP2_Data_Dat1SeriesSum.m
%%
%%  03-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_Dat1SeriesOverview';


%--- init success flag ---
f_done = 0;

%--- check data existence ---
if ~isfield(data,'spec1')
    fprintf('%s ->\nSpectral data series 1 does not exist. Load first.\n',FCTNAME);
    return
elseif ~isfield(data.spec1,'fidArr')
    fprintf('%s ->\nSpectral FID series 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- consistency checks ---
if ~flag.dataAllSelect && any(data.select>data.spec1.nr)
    fprintf('%s ->\nSelected FID range exceeds number of repetitions (NR=%.0f).\n',...
            FCTNAME,data.spec1.nr)
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

%--- series summation ---
if flag.dataExpType<3                   % regular MRS
    if flag.dataCorrAppl                % frequency/phase correction has been applied -> Rx combination done already        
        %--- FID summation ---
        if length(size(data.spec1.fid))==2          % series of NR=1 spectra
            dataSpec1Fid = reshape(sum(data.spec1.fidArr,1),[data.spec1.nspecC 1]);
        else                                        % series of NR>1 spectra
            dataSpec1Fid = reshape(sum(sum(data.spec1.fidArr,3),1),[data.spec1.nspecC 1]);
        end
    else                                % raw data -> Klose correction and (weighted) Rx summation still to be done
        %--- Klose correction ---
        dataSpec1FidArr = data.spec1.fidArr;        % init
        if flag.dataPhaseCorr==1        % Klose correction on/off
            for seriesCnt = 1:data.spec1.seriesN
                for nrCnt = 1:data.spec1.nr
                    for rCnt = 1:data.spec1.nRcvrs
                        if ndims(data.spec2.fid)==2     % spectral + receivers, single reference for all
                            if size(data.spec2.fid,2)==1
                                fprintf('%s ->\nSingleton dimension detected for Rx. Repetitive combination of Rx channels requires reloading.\nProgram aborted.\n',FCTNAME);
                                return
                            end
                            phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
                        else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
                            if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                return
                            else
                                %--- info printout ---
                                if rCnt==1          % 1st receiver only
                                    if nrCnt==1
                                        fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    elseif nrCnt==data.spec1.nr
                                        fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    else
                                        fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    end
                                end

                                %--- extract correction phase ---
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,ceil(nrCnt/2))));
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,min(length(data.select)/2,data.nPhCycle))+1+data.ds)));
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                            end
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        dataSpec1FidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
                    end
                end
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
        
        %--- FID summation ---
        if flag.dataAllSelect           % all FIDs (NR)
            if flag.dataRcvrWeight      % weighted summation
                if length(size(data.spec2.fid))==3
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
                else
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
                end
                weightVec       = weightVec/sum(weightVec);
                weightMat       = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
                dataSpec1FidArr = dataSpec1FidArr(:,:,data.rcvrInd,:) .* weightMat;
                dataSpec1FidArr = squeeze(sum(dataSpec1FidArr,3));
            else
                dataSpec1FidArr = squeeze(mean(dataSpec1FidArr(:,:,data.rcvrInd,:),3));
            end
            
            % data order: experiment series, FID, NR
            dataSpec1Fid = conj(sum(sum(dataSpec1FidArr,3),1)');
        else                            % selected FID range
            %--- break condition ---
            fprintf('%s ->\nNR selection has not been implemented yet for JDE data!!!\nProgram aborted.\n',FCTNAME);
            return
        end
    end
    
    %--- info printout ---
    fprintf('%s done for regular MRS data.\n',FCTNAME);
elseif flag.dataExpType==3              % JDE
    if flag.dataCorrAppl                % frequency/phase correction has been applied -> Rx combination done already
        %--- FID summation ---
        if flag.dataAllSelect           % all FIDs (NR)
            %--- data order: experiment series, FID, NR (with alternating edited/non-edited) ---
            dataSpec1Fid = data.spec1.fidArr;
                
            %--- info printout ---
            fprintf('All FID''s summed, i.e. no selection applied\n');
        else                            % selected FID range
            %--- spectrum 2, even NR ---
            dataSpec1Fid = data.spec1.fidArr(:,:,data.select);
        end
   else         % summation of raw JDE data -> Klose correction and (weighted) Rx summation still to be done
        %--- Klose correction ---
        if flag.dataPhaseCorr==1        % Klose correction on/off
            for seriesCnt = 1:data.spec1.seriesN
                for nrCnt = 1:data.spec1.nr
                    for rCnt = 1:data.spec1.nRcvrs
                        if ndims(data.spec2.fid)==2     % spectral + receivers, single reference for all
                            if size(data.spec2.fid,2)==1
                                fprintf('%s ->\nSingleton dimension detected for Rx. Repetitive combination of Rx channels requires reloading.\nProgram aborted.\n',FCTNAME);
                                return
                            end
                            phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
                        else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
%                             phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,ceil(nrCnt/2))));
                            % indexing:
                            % 1,1,2,2,3,3,4,4,5,5,...,15,15,16,16,1,1,2,2,3,3,...
                            % note that the maximum phase cycling contains 16 steps
                            % data.select has to be chosen carefully to
                            % cover the applied phase cycle properly/completely
                            % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,min(length(data.select)/2,data.nPhCycle))+1+data.ds)));
                            phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        dataSpec1FidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
                    end
                end
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
        
        %--- Rx summation ---
        if flag.dataRcvrWeight
            %--- weighted summation ---
            if length(size(data.spec2.fid))==3
                weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
            else
                weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
            end
            weightVec       = weightVec/sum(weightVec);
            weightMat       = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
            dataSpec1FidArr = dataSpec1FidArr(:,:,data.rcvrInd,:) .* weightMat;
            dataSpec1FidArr = squeeze(sum(dataSpec1FidArr,3));
        
            %--- info printout ---
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        else
            %--- non-weighted summation ---
            dataSpec1FidArr = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:),3));
            
            %--- info printout ---
            fprintf('Non-weighted summation of Rx channels applied:\n');
        end
        fprintf('Channels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));
        
        %--- FID summation ---
        if flag.dataAllSelect           % all FIDs (NR)
            %--- data order: experiment series, FID, NR (with alternating edited/non-edited) ---
            dataSpec1Fid = conj(sum(sum(data.spec1.fidArr(:,:,1:2:data.spec1.nr),3),1)');
            dataSpec2Fid = conj(sum(sum(data.spec1.fidArr(:,:,2:2:data.spec1.nr),3),1)');
            
            %--- info printout ---
            fprintf('All FID''s summed, i.e. no selection applied\n');
        else                            % selected FID range
            %--- spectrum 2, even NR ---
            indVecTot  = 2:2:data.spec1.nr;         % even repetition numbers
            indVecAppl = 0;                         % indices of selected even NR
            indCnt     = 0;                         % index counter
            for sCnt = 1:length(data.select)
                if any(data.select(sCnt)==indVecTot)
                    indCnt = indCnt + 1;
                    indVecAppl(indCnt) = indVecTot(data.select(sCnt)==indVecTot);
                end
            end
            dataSpec2Fid = conj(sum(sum(data.spec1.fidArr(:,:,indVecAppl),3),1)');

            %--- info printout ---
            fprintf('FID selection, non-edited (spec2):\n%s\n',SP2_Vec2PrintStr(indVecAppl,0));

            %--- spectrum 1, odd NR ---
            indVecTot  = 1:2:data.spec1.nr;         % odd repetition numbers
            indVecAppl = 0;                         % indices of selected even NR
            indCnt     = 0;                         % index counter
            for sCnt = 1:length(data.select)
                if any(data.select(sCnt)==indVecTot)
                    indCnt = indCnt + 1;
                    indVecAppl(indCnt) = indVecTot(data.select(sCnt)==indVecTot);
                end
            end
            dataSpec1Fid = conj(sum(sum(dataSpec1FidArr(:,:,indVecAppl),3),1)');

            %--- info printout ---
            fprintf('FID selection, edited (spec1):\n%s\n',SP2_Vec2PrintStr(indVecAppl,0));
        end 
    end
        
    %--- info printout ---
    fprintf('%s done with JDE sorting.\n',FCTNAME);
else
    fprintf('%s does not support stability experiments.\n',FCTNAME);
    fprintf('Program aborted.\n');
    return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     S P E C T R A    V I S U A L I Z A T I O N                      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- ppm limit handling ---
if flag.dataPpmShow     % direct
    ppmMin = data.ppmShowMin;
    ppmMax = data.ppmShowMax;
else                    % full sweep width (symmetry assumed)
    ppmMin = -data.spec1.sw/2 + data.ppmCalib;
    ppmMax = data.spec1.sw/2  + data.ppmCalib;
end

%--- subplot handling ---
spline = ceil(sqrt(data.spec1.nr));         % spectra per line
NoResidD = mod(data.spec1.nr,spline);
NoRowsD  = (data.spec1.nr-NoResidD)/spline;
if NoRowsD*spline<data.spec1.nr             % in rare cases an additional increase by one is required...
    NoRowsD = NoRowsD + 1;
end

%--- scan acquisition series ---
for seriesCnt = 1:data.spec1.seriesN
    %--- figure creation ---
    eval(['fh_' num2str(seriesCnt) ' = figure;'])
    eval(['set(fh_' num2str(seriesCnt) ',''NumberTitle'',''off'',''Position'',[41 59 989 760],''Color'',[1 1 1],''Name'',sprintf('' Scan #%.0f, NR %.0f..%.0f'',seriesCnt,1,data.spec1.nr));'])

    %--- NR series ---
%     for nrCnt = 1:data.spec1.nr
    for nrCnt = 1:length(data.select)
        %--- data processing ---
        if data.spec1.nspecC<data.fidCut        % no apodization
            datSpec = conj(fftshift(fft(dataSpec1Fid(seriesCnt,:,nrCnt))))';
        else                                    % apodization
            datSpec = conj(fftshift(fft(dataSpec1Fid(seriesCnt,1:data.fidCut,nrCnt))))';
            if seriesCnt==1 && nrCnt==1
                fprintf('%s ->\nApodization of FID 1 to %.0f points applied.\n',FCTNAME,data.fidCut);
            end
        end
        
        %--- data extraction: spectrum 1 ---
        if flag.dataFormat==1           % real part
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec1.sw,real(datSpec));
        elseif flag.dataFormat==2       % imaginary part
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec1.sw,imag(datSpec));
        else                            % magnitude
            [minI,maxI,ppmZoom,specZoom,f_succ] = SP2_Data_ExtractPpmRange(ppmMin,ppmMax,data.ppmCalib,...
                                                                           data.spec1.sw,abs(datSpec));
        end                                             
        if ~f_succ
            fprintf('%s ->\nppm extraction of spectrum 1 failed. Program aborted.\n\n',FCTNAME);
            return
        end

        %--- data visualization ---
        subplot(NoRowsD,spline,nrCnt);
        plot(ppmZoom,specZoom)
        set(gca,'XDir','reverse')
        if flag.dataAmpl        % direct
            [minX maxX fake1 fake2] = SP2_IdealAxisValues(ppmZoom,specZoom);
            minY = data.amplMin;
            maxY = data.amplMax;
        else                    % automatic
            [minX maxX minY maxY] = SP2_IdealAxisValues(ppmZoom,specZoom);
        end
        axis([minX maxX minY maxY])
        title(sprintf('NR %.0f',nrCnt))
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%     S P E C T R A    A N A L Y S I S                                %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lbProc    = 3;     % 3 Hz line broadening to reduce dependency on late data points
if data.spec1.nspecC<data.fidCut        % no apodization
    lbWeight = exp(-lbProc*data.spec1.dwell*(0:data.spec1.nspecC-1)*pi);
    refFid   = squeeze(dataSpec1Fid(1,:,data.frAlignRefFid(1)));
else                                    % apodization
    lbWeight = exp(-lbProc*data.spec1.dwell*(0:data.fidCut-1)*pi);
    refFid   = squeeze(dataSpec1Fid(1,1:data.fidCut,data.frAlignRefFid(1)));
end

refSpec = fftshift(fft(refFid.*lbWeight,[],2),2);
% note that the reversed spectral order
[minI,maxI,ppmZoom,refSpecZoom,f_succ] = SP2_Data_ExtractPpmRange(data.frAlignPpmMin,data.frAlignPpmMax,...
                                                                  data.ppmCalib,data.spec1.sw,abs(rot90(refSpec)));
maxAbsRef = max(abs(refSpec(minI:maxI)));
for seriesCnt = 1:data.spec1.seriesN
    for nrCnt = 1:length(data.select)
        if data.spec1.nspecC<data.fidCut        % no apodization
            specTmp = fftshift(fft(squeeze(dataSpec1Fid(seriesCnt,:,data.select(nrCnt))).*lbWeight,[],2),2);
        else                                    % apodization
            specTmp = fftshift(fft(squeeze(dataSpec1Fid(seriesCnt,1:data.fidCut,data.select(nrCnt))).*lbWeight,[],2),2);
        end
        maxAbsTmp = max(abs(specTmp(minI:maxI)));
        
        %--- info printout ---
%         fprintf('Amplitude ratio %.2f (#%i of %i, scan %i, NR %i)\n',maxAbsRef/maxAbsTmp,...
%                 nrCnt+(seriesCnt-1)*data.spec1.nr,data.spec1.nr*data.spec1.seriesN,...
%                 data.spec1.seriesVec(seriesCnt),nrCnt)
        fprintf('Amplitude ratio %.2f (#%i of %i, scan %i, NR %i)\n',maxAbsRef/maxAbsTmp,...
                nrCnt+(seriesCnt-1)*data.spec1.nr,length(data.select)*data.spec1.seriesN,...
                data.spec1.seriesVec(seriesCnt),data.select(nrCnt))
    end
end

%--- update success flag ---
f_done = 1;

end
