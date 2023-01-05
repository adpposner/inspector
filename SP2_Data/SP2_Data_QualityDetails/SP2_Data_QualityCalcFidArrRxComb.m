%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_QualityCalcFidArrRxComb
%%
%%  Calculation of Rx-combined FID array if not part of alignment
%%  processing stream (i.e. if data are to be visualized without any
%%  correction applied.
%% 
%%  12-2013, Christoph Juchem
%%
%%  10-2019, Christoph Juchem, Martin Gajdosik - data.spec1.fidArr problem 
%%  which caused changing with wrong channel combination of the raw data
%%  by using QA fixed by using dataSpec1FidArr as local data structure.
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data flag

FCTNAME = 'SP2_Data_QualityCalcFidArrRxComb';


%--- init success flag ---
f_succ = 0;

%--- init Rx-combined FID array ---
% note the unchanged data dimension which will be collapsed lateron 
data.spec1.fidArrRxComb = data.spec1.fidArr;    

%--- phase correction and Rx combination based on experiment type ---
if flag.dataExpType==3 || flag.dataExpType==7      % single JDE experiment OR JDE array

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
                            % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,min(length(data.select)/2,data.nPhCycle))+1+data.ds)));
                            if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                return
                            else
                                %--- info printout ---
                                if rCnt==1          % 1st receiver only
                                    if nrCnt==1
                                        fprintf('Phase cycle: %.0f steps\n',data.nPhCycle);
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
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,min(length(data.select)/2,data.nPhCycle))+1)));
                                if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                    fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                    return
                                else
                                    %--- info printout ---
                                    if rCnt==1          % 1st receiver only
                                        if nrCnt==1
                                            fprintf('Phase cycle: %.0f steps\n',data.nPhCycle);
                                            fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        elseif nrCnt==data.spec1.nr
                                            fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        else
                                            fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        end
                                    end

                                    %--- extract correction phase ---
                                    phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
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
        if length(size(data.spec2.fid))==3
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
        else
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
        end
        weightVec         = weightVec/sum(weightVec);
        weightMat         = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
        data.spec1.fidArrRxComb = data.spec1.fidArrRxComb(:,:,data.rcvrInd,:) .* weightMat;
        data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));
    else
        data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArrRxComb(:,:,data.rcvrInd,:),3));
    end
elseif flag.dataExpType==2              % saturation-recovery
    
    % copied from SP2_Data_Dat1SeriesAlignSatRec.m
    %--- Rx combination ---
    if flag.dataPhaseCorr==1        % Klose method
        %--- phase correction ---
        % current format: single phase cycle water reference for every 
        % sat-rec delay applied to all phase cycle steps of metabolite acquisition
        for seriesCnt = 1:data.spec1.seriesN
            for rCnt = 1:data.spec1.nRcvrs
                for srCnt = 1:data.spec1.nSatRec
                    for nvCnt = 1:data.spec1.nv
                        if data.spec2.nv==1         % single phase cycle step
                            phaseCorr = permute(unwrap(angle(data.spec2.fid(:,rCnt,1,srCnt))),[2 1]);
                        else                        % full phase cycle
                            phaseCorr = permute(unwrap(angle(data.spec2.fid(:,rCnt,nvCnt,srCnt))),[2 1]);
                        end
                        data.spec1.fidArrRxComb(seriesCnt,:,rCnt,nvCnt,srCnt) = squeeze(data.spec1.fidArrRxComb(seriesCnt,:,rCnt,nvCnt,srCnt)) .* exp(-1i*phaseCorr);
                    end
                end
            end
        end

        %--- info printout ---
        fprintf('(Combined phase-cycle) Klose phase correction applied.\n');
    elseif flag.dataPhaseCorr==2
        fprintf('%s ->\nOnly the Klose method is currently supported for phase/ECC correction. Program aborted.\n',FCTNAME);
        return
    else
        %--- info printout ---
        fprintf('No phase/ECC correction applied.\n');
    end

    %--- Rx summation ---
    if flag.dataRcvrWeight
        if length(size(data.spec2.fid))==4
            weightVec      = mean(abs(data.spec2.fid(1:5,:,1,2)),1);
            % note that the 2nd sat-recovery scan is used here due to the resorting
        else
            weightVec      = mean(abs(data.spec2.fid(1:5,:,2)),1);
            % note that the 2nd sat-recovery scan is used here due to the resorting
        end
        weightVec = weightVec/sum(weightVec);
        weightMat = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nv data.spec1.nSatRec data.spec1.seriesN]),[5 1 2 3 4]);
        data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb(:,:,data.rcvrInd,:,:).*weightMat(:,:,data.rcvrInd,:,:),3));

        %--- info printout ---
        fprintf('Amplitude-weighted summation of Rx channels applied:\n');
        fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec,3));
    else
        data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:,:),3));

        %--- info printout ---
        fprintf('Non-weighted summation of Rx channels applied:\n');
    end
else            % regular MRS experiment (repetitions and/or series)
    %--- Rx combination ---
    if flag.dataPhaseCorr==1        % Klose method
        % dataSpec1FidArr = data.spec1.fidArr;        % init local
        if flag.dataKloseMode==1            % summation of phase cycling steps before Klose correction with one, combined phase trace
            %--- preprocessing of water reference ---
            if ~SP2_Data_PhaseCorrKloseRxComb
                return
            end

            %--- Klose correction of all JDE acquisitions (phase cycle, edit
            %--- on/off, NR) with identical phase reference ---
            phaseCorr = permute(repmat(exp(-1i*data.spec2.klosePhase),[1 1 data.spec1.seriesN data.spec1.nr]),[3 1 2 4]);  
            % dataSpec1FidArr(:,:,data.rcvrInd,:) = data.spec1.fidArr(:,:,data.rcvrInd,:) .* phaseCorr;
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
                            % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,data.nPhCycle)+1)));
                            if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                return
                            else
                                %--- info printout ---
                                if rCnt==1          % 1st receiver only
                                    if nrCnt==1
                                        fprintf('Phase cycle: %.0f steps\n',data.nPhCycle);
                                        fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    elseif nrCnt==data.spec1.nr
                                        fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    else
                                        fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                    end
                                end

                                %--- extract correction phase ---
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                            end
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        % dataSpec1FidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
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
                            if rCnt>size(data.spec2.fid,2)
                                fprintf('Requested repetition number exceeds data dimension (%.0f>%.0f). Check consistency.\n',...
                                        rCnt,data.spec2.nr)
                                return
                            else
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt)));
                            end
                        else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
                            if data.spec2.nr==1         % single reference
                                % phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1,data.nPhCycle)+1)));
                                if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                    fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                    return
                                else
                                    %--- info printout ---
                                    if rCnt==1          % 1st receiver only
                                        if nrCnt==1
                                            fprintf('Phase cycle: %.0f steps\n',data.nPhCycle);
                                            fprintf('Phase correction NR indices: [%.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        elseif nrCnt==data.spec1.nr
                                            fprintf(' %.0f]\n',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        else
                                            fprintf(' %.0f',mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds);
                                        end
                                    end

                                    %--- extract correction phase ---
                                    phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                                end
                            else                        % reference array (e.g. multiple JDE frequencies)
                                phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,data.phaseCorrNr)));
                            end
                        end
                        phaseVec = exp(-1i*phaseCorr');
                        % dataSpec1FidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
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
        if length(size(data.spec2.fid))==3
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
        else
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
        end
        weightVec = weightVec/sum(weightVec);
        weightMat = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr data.spec1.seriesN]),[4 1 2 3]);
        % from local copy
        % data.spec1.fidArrRxComb = dataSpec1FidArr(:,:,data.rcvrInd,:) .* weightMat;
        data.spec1.fidArrRxComb = data.spec1.fidArrRxComb(:,:,data.rcvrInd,:) .* weightMat;
        data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));

        %--- info printout ---
        fprintf('Amplitude-weighted summation of Rx channels applied:\n');
        fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
    else
        %--- non-weighted summation ---
        % from local copy
        % data.spec1.fidArrRxComb = squeeze(mean(dataSpec1FidArr(:,:,data.rcvrInd,:),3));
        data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArrRxComb(:,:,data.rcvrInd,:),3));

        %--- info printout ---
        fprintf('Non-weighted summation of Rx channels applied:\n');
    end
end         % of iteration loop

%--- info printout ---
fprintf('Info: Rx-combination recalculated.\n');

%--- update success flag ---
f_succ = 1;
