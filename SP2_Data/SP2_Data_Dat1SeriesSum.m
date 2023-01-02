%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1SeriesSum
%% 
%%  Summation of experiment series.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data flag

FCTNAME = 'SP2_Data_Dat1SeriesSum';


%--- init success flag ---
f_succ = 0;

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

%--- consistency check ---
if isfield(data.spec1,'fid')
    if ndims(data.spec1.fid)==2 && size(data.spec1.fid,2)==1 && data.spec1.seriesN==1            % single FID
        fprintf('%s ->\nSingle FID detected. Series summation aborted.\n\n',FCTNAME);
        return
    end
end

%--- series average ---
if flag.dataExpType==1                  % regular MRS
    if flag.dataCorrAppl                % frequency/phase correction has been applied -> Rx combination done already        
        %--- FID average ---
        if length(size(data.spec1.fid))==2          % series of NR=1 spectra
            data.spec1.fid = reshape(mean(data.spec1.fidArrRxComb,1),[data.spec1.nspecC 1]);
        else                                        % series of NR>1 spectra
            if flag.dataAllSelect           % all FIDs (NR)
                data.spec1.fid = reshape(mean(mean(data.spec1.fidArrRxComb,3),1),[data.spec1.nspecC 1]);
            else                            % FID selection
                data.spec1.fid = reshape(mean(mean(data.spec1.fidArrRxComb(:,:,data.select),3),1),[data.spec1.nspecC 1]);
            end
        end
    else                                % raw data -> Klose correction and (weighted) Rx summation still to be done
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
                            if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                fprintf('\n%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
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
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,min(length(data.select)/2,data.nPhCycle))+1+data.ds)));
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                            end
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
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
                %--- weighted summation ---
                if length(size(data.spec2.fid))==3
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
                else
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
                end
                weightVec = weightVec/sum(weightVec);
                weightMat = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
                data.spec1.fidArrRxComb = data.spec1.fidArr(:,:,data.rcvrInd,:) .* weightMat;
                data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));
        
                %--- info printout ---
                fprintf('Amplitude-weighted summation of Rx channels applied:\n');
                fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
            else
                %--- non-weighted summation ---
                data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:),3));
        
                %--- info printout ---
                fprintf('Non-weighted summation of Rx channels applied:\n');
            end
            
            % data order: experiment series, FID, NR
            data.spec1.fid = conj(mean(mean(data.spec1.fidArrRxComb,3),1)');
            
            %--- info printout ---
            fprintf('All FID''s summed, i.e. no selection applied\n');
        else                            % selected FID range
            if flag.dataRcvrWeight      % weighted summation
                %--- weighted summation ---
                if length(size(data.spec2.fid))==3
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
                else
                    weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
                end
                weightVec = weightVec/sum(weightVec);
                weightMat = permute(repmat(weightVec,[data.spec1.nspecC 1 length(data.select) data.spec1.seriesN]),[4 1 2 3]);
                data.spec1.fidArrRxComb = data.spec1.fidArr(:,:,data.rcvrInd,data.select) .* weightMat;
                data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));
            
                %--- info printout ---
                fprintf('Amplitude-weighted summation of Rx channels applied:\n');
                fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
            else
                %--- non-weighted summation ---
                data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,data.select),3));
            
                %--- info printout ---
                fprintf('Non-weighted summation of Rx channels applied:\n');
            end
            
            %--- ISIS summation (if not done through receiver phase ---
%             data.spec1.fidArrRxComb = data.spec1.fidArrRxComb .* permute(repmat([1 -1 -1 -1 1 1 1 -1],[data.spec1.seriesN,1,data.spec1.nspecC]),[1 3 2]);         
            
            % data order: experiment series, FID, NR
            data.spec1.fid = conj(mean(mean(data.spec1.fidArrRxComb,3),1)');
       
            %--- info printout ---
            fprintf('FID selection: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));
        end 
    end
    
    %--- info printout ---
    fprintf('%s done for regular MRS data.\n',FCTNAME);
elseif flag.dataExpType==2              % saturation-recovery experiment
    %--- Rx summation (only if necessary, i.e. if no alignment had been applied) ---
    if ~isfield(data.spec1,'fidArrRxComb')
        %--- info printout ---
        fprintf('\nNO RX-COMBINED FID DATA FOUND (I.E. NO ALIGNMENT APPLIED!!!).\n');
        fprintf('STRAIGHT FORWARD SUMMATION APPLIED\n\n');
        
        %--- combine receivers ---
        if flag.dataRcvrWeight
            if length(size(data.spec2.fid))==4
                weightVec = mean(abs(data.spec2.fid(1:5,:,1,2)),1);
                % note that the 2nd sat-recovery scan is used here due to the resorting
            else
                weightVec = mean(abs(data.spec2.fid(1:5,:,2)),1);
                % note that the 2nd sat-recovery scan is used here due to the resorting
            end
            weightVec = weightVec/sum(weightVec);
            weightMat = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nv data.spec1.nSatRec data.spec1.seriesN]),[5 1 2 3 4]);
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArr(:,:,data.rcvrInd,:,:).*weightMat(:,:,data.rcvrInd,:,:),3));

            %--- info printout ---
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        else
            data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:,:),3));

            %--- info printout ---
            fprintf('Non-weighted summation of Rx channels applied:\n');
        end
        fprintf('Receive cannels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));
    end
    
    %--- series summation ---
    data.spec1.fidArrRxComb = mean(data.spec1.fidArrRxComb,1);       % series summation
    
    %--- data reformating: (serial) nr back to array of phase cycle *
    % saturation delay array
    data.spec1.fidArrRxComb = reshape(data.spec1.fidArrRxComb,data.spec1.nspecC,data.spec1.nSatRec,data.spec1.nv);
    
    %--- series summation (of series and phase cycle (nv)) ---
    data.spec1.fid = mean(data.spec1.fidArrRxComb,3);
    
    %--- info printout ---
    fprintf('%s done for saturation-recovery MRS data.\n',FCTNAME);
elseif flag.dataExpType==3              % JDE
    if flag.dataCorrAppl                % frequency/phase correction has been applied -> Rx combination done already
        %--- FID summation ---
        if flag.dataAllSelect           % all FIDs (NR)
            %--- basis statistics ---
            if flag.verbose
                SP2_Data_Dat1SeriesStatistics(data.spec1.fidArrRxComb,1:data.spec1.nr,flag.dataAlignVerbose)
            end
            
            %--- data order: experiment series, FID, NR (with alternating edited/non-edited) ---
            data.spec1.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,1:2:data.spec1.nr),3),1)');
            data.spec2.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,2:2:data.spec1.nr),3),1)');
                
            %--- info printout ---
            fprintf('All FID''s summed, i.e. no selection applied\n');
        else                            % selected FID range
            %--- basis statistics ---
            if flag.verbose
                SP2_Data_Dat1SeriesStatistics(data.spec1.fidArrRxComb(:,:,data.select),data.select,flag.dataAlignVerbose)
            end
            
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
            data.spec2.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,indVecAppl),3),1)');

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
            data.spec1.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,indVecAppl),3),1)');

            %--- info printout ---
            fprintf('FID selection, edited (spec1):\n%s\n',SP2_Vec2PrintStr(indVecAppl,0));
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
                            if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                fprintf('\n%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
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
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,min(length(data.select)/2,data.nPhCycle))+1+data.ds)));
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                            end
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
                    end
                end
            end
            
            %--- info printout ---
            fprintf('Klose phase correction applied.\n');
        elseif flag.dataPhaseCorr==2
            fprintf('\n%s ->\nOnly the Klose method is currently supported for phase/ECC correction. Program aborted.\n',FCTNAME);
            fprintf('Hint: Use Klose method or disable phase correction.\n');
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
            weightVec = weightVec/sum(weightVec);
            weightMat = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
            data.spec1.fidArrRxComb = data.spec1.fidArr(:,:,data.rcvrInd,:) .* weightMat;
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArr,3));
        
            %--- info printout ---
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        else
            %--- non-weighted summation ---
            data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:),3));
            
            %--- info printout ---
            fprintf('Non-weighted summation of Rx channels applied:\n');
        end
        fprintf('Channels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));
        
        %--- FID summation ---
        if flag.dataAllSelect           % all FIDs (NR)
            %--- basis statistics ---
            if flag.verbose
                SP2_Data_Dat1SeriesStatistics(data.spec1.fidArrRxComb,1:data.spec1.nr,flag.dataAlignVerbose)
            end
        
            %--- data order: experiment series, FID, NR (with alternating edited/non-edited) ---
            data.spec1.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,1:2:data.spec1.nr),3),1)');
            data.spec2.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,2:2:data.spec1.nr),3),1)');
            
            %--- info printout ---
            fprintf('All FID''s summed, i.e. no selection applied\n');
        else                            % selected FID range
            %--- basis statistics ---
            if flag.verbose
                SP2_Data_Dat1SeriesStatistics(data.spec1.fidArrRxComb(:,:,data.select),data.select,flag.dataAlignVerbose)
            end
            
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
            data.spec2.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,indVecAppl),3),1)');

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
            data.spec1.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,indVecAppl),3),1)');

            %--- info printout ---
            fprintf('FID selection, edited (spec1):\n%s\n',SP2_Vec2PrintStr(indVecAppl,0));
        end 
    end
        
    %--- info printout ---
    fprintf('%s done with JDE sorting.\n',FCTNAME);
elseif flag.dataExpType==4
    fprintf('%s does not support stability experiments.\n',FCTNAME);
    fprintf('Program aborted.\n');
    return
elseif flag.dataExpType==5
    fprintf('%s does not support T1/T2 experiments.\n',FCTNAME);
    fprintf('Program aborted.\n');
    return
elseif flag.dataExpType==6
    fprintf('%s does not support MRSI experiments.\n',FCTNAME);
    fprintf('Program aborted.\n');
    return
else	              % JDE array, flag.dataExpType==7
    if flag.dataCorrAppl                % frequency/phase correction has been applied -> Rx combination done already
        %--- FID summation ---
        %--- basis statistics ---
        if flag.verbose
            SP2_Data_Dat1SeriesStatistics(data.spec1.fidArrRxComb,1:data.spec1.nr,flag.dataAlignVerbose)
        end

        %--- data order: experiment series, FID, NR (with alternating edited/non-edited) ---
        data.spec1.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,1:2:2*data.spec1.nv),3),1)');
        data.spec2.fid = conj(mean(mean(data.spec1.fidArrRxComb(:,:,2:2:2*data.spec1.nv),3),1)');

        %--- info printout ---
        fprintf('All FID''s summed, i.e. no selection applied\n');
    else         % summation of raw JDE data -> Klose correction and (weighted) Rx summation still to be done
        fprintf('%s ->\nThe arrayed JDE mode requires phase/frequency aligned spectra (in its current implementation).\n',FCTNAME);
        return
    end
        
    %--- info printout ---
    fprintf('%s done with JDE sorting.\n',FCTNAME);
end
    
%--- update success flag ---
f_succ = 1;
