%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_MM_CalcFidArrRxComb
%%
%%  Calculation of Rx-combined FID array.
%% 
%%  12-2013, Christop Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global mm flag

FCTNAME = 'SP2_MM_CalcFidArrRxComb';


%--- init success flag ---
f_done = 0;

%--- phase cyclec steps ---
nPhCycle = 8;

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
else            % single NR (no JDE)
    %--- serial phase/frequency alignment ---
%         spec1FidRxSum = complex(zeros(data.spec1.seriesN,data.spec1.nspecC));       % matrix of all Rx-summed FIDs
    if length(size(data.spec2.fid))==3
        weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
    else
        weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
    end
    weightVec     = weightVec/sum(weightVec);
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
        if length(size(data.spec2.fid))==3
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
        else
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
        end
        weightVec         = weightVec/sum(weightVec);
        weightMat         = permute(repmat(weightVec,[data.spec1.nspecC 1 data.spec1.seriesN]),[3 1 2]);
        data.spec1.fidArrRxComb = data.spec1.fidArrRxComb(:,:,data.rcvrInd) .* weightMat;
        data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));
    else
        data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArrRxComb(:,:,data.rcvrInd),3));
    end
end         % of iteration loop

%--- info printout ---
fprintf('Info: Rx-combination recalculated.\n');

%--- update success flag ---
f_done = 1;
