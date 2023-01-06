%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_Dat1SeriesAlignJdeArray
%% 
%%  Phase and frequency alignment of arrayed JDE experiment.
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_Dat1SeriesAlignJdeArray';


%--- init success flag ---
f_done = 0;

%--- consistency check: aligment methods ---
if ~flag.dataAlignPhase && ~flag.dataAlignFrequ
    fprintf('%s ->\nAt least one alignment target (phase, frequency) has to be selected.\nProgram aborted.\n',FCTNAME);
    return
end

%--- check data existence and consistency: metabolite scans ---
if ~isfield(data,'spec1')
    fprintf('%s ->\nSpectral data series 1 does not exist.\nLoaded automatically...\n',FCTNAME);
    if ~SP2_Data_Dat1SeriesLoad
        return
    end
elseif ~isfield(data.spec1,'fidArr')
    fprintf('%s ->\nSpectral FID series 1 does not exist.\nLoaded automatically...\n',FCTNAME);
    if ~SP2_Data_Dat1SeriesLoad
        return
    end
end
if ndims(data.spec1.fid)~=3
    fprintf('%s ->\nSpectral FID 1 must have 3 dimensions (spectral + receivers + JDE*array*repetitions),\n',FCTNAME);
    fprintf('but %i dimensions were found (%s). Program aborted.\n',ndims(data.spec1.fid),SP2_Vec2PrintStr(size(data.spec1.fid),0));
    return
end
if size(data.spec1.fid,3)~=data.spec1.nr || ...
   size(data.spec1.fid,3)~=data.spec1.njde*data.spec1.nv*data.spec1.t2TeN     
    fprintf('%s ->\nDimension discrepancy detected for FID 1. Program aborted.\n',FCTNAME);
    return
end
if data.spec1.njde~=2
    fprintf('%s ->\nThe arrayed JDE mode currently supports only two-condition experiments. Program aborted.\n',FCNTAME);
    return
end 
    
%--- check data existence: water reference ---
if ~isfield(data,'spec2')
    fprintf('%s ->\nSpectral data series 1 does not exist.\nLoaded automatically...\n',FCTNAME);
    if ~SP2_Data_Dat2FidFileLoad
        return
    end
end
if ~isfield(data.spec2,'fid')
    fprintf('%s ->\nSpectral FID 2 does not exist.\nLoaded automatically...\n',FCTNAME);
    if ~SP2_Data_Dat2FidFileLoad
        return
    end
end
if ndims(data.spec2.fid)~=3
    fprintf('%s ->\nSpectral FID 2 must have 3 dimensions (spectral + receivers + array),\n',FCTNAME);
    fprintf('but %i dimensions were found %s. Program aborted.\n',ndims(data.spec2.fidSel),SP2_Vec2PrintStr(size(data.spec2.fidSel),0));
    return
end
if data.spec2.nv~=1 && data.spec2.nv~=data.spec1.nv
    fprintf('%s ->\nSpectral FID 2 must be nv=1 or match the metabolite phase cycle\n',FCTNAME);
    fprintf('Program aborted.\n');
    return
end

%--- reference validity of reference receiver for frequency alignment ---
% note that the FID from the 1st active (ie. selected) receiver is used for reference 
if ~any(data.rcvrInd)
    fprintf('%s ->\nAt least one receiver must be selected (for frequency alignment).\nProgram aborted.\n',FCTNAME);
    return
end

%--- selection check for single array element ---
if flag.dataAllSelect           % all
    fprintf('%s ->\nOne repetition must be selected (for frequency alignment).\nProgram aborted.\n',FCTNAME);
    return
end
if data.selectN>1
    fprintf('%s ->\nMore than one array element has been selected.\nProgram aborted.\n',FCTNAME);
    return
end
if data.select<0 || data.select>data.spec1.t2TeN
    fprintf('%s ->\nSelected array element is outside the valid range 1..%.0f.\n',FCTNAME,data.spec1.t2TeN);
    return
end

%--- info printout ---
fprintf('\nSelected extra TE delay: %.3f ms\n\n',data.spec1.t2TeExtra(data.select));

%--- extraction of selected single TE (index) experiment ---
% data order: series, temporal, receiver, (serial) NR
% dataSpec1FidSelON  = permute(data.spec1.fidArr(:,:,:,2*data.select-1:2*data.spec1.t2TeN:end),[4 1 2 3]);
% dataSpec1FidSelOFF = permute(data.spec1.fidArr(:,:,:,2*data.select:2*data.spec1.t2TeN:end),[4 1 2 3]);
% data.spec1.fidArrSel = permute(reshape([dataSpec1FidSelON dataSpec1FidSelOFF],2*data.spec1.nv,data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs),[2 3 4 1]);
% data.spec2.fidSel    = data.spec2.fid(:,:,data.select);
dataSpec1FidSelON  = data.spec1.fidArr(:,:,:,2*data.select-1:2*data.spec1.t2TeN:end);
dataSpec1FidSelOFF = data.spec1.fidArr(:,:,:,2*data.select:2*data.spec1.t2TeN:end);
% data.spec1.fidArrSel = permute(reshape([dataSpec1FidSelON dataSpec1FidSelOFF],data.spec1.seriesN,2*data.spec1.nv,data.spec1.nspecC,data.spec1.nRcvrs),[1 3 4 2]);
data.spec1.fidArrSel = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,data.spec1.nRcvrs,2*data.spec1.nv));
data.spec1.fidArrSel(:,:,:,1:2:end) = dataSpec1FidSelON;
data.spec1.fidArrSel(:,:,:,2:2:end) = dataSpec1FidSelOFF;
data.spec2.fidSel = squeeze(data.spec2.fid(:,:,data.select));

%--- corrections ---
amplMat  = zeros(data.spec1.seriesN,2*data.spec1.nv);                         % optimal amplitude scalings
phaseMat = zeros(data.spec1.seriesN,2*data.spec1.nv,data.phAlignIter);        % optimal phasings
frequMat = zeros(data.spec1.seriesN,2*data.spec1.nv,data.frAlignIter);        % optimal frequency corrections
for iterCnt = 1:max(data.phAlignIter,data.frAlignIter)
    %--- serial phase/frequency alignment ---
%         data.spec1.fidArrRxComb = complex(zeros(data.spec1.seriesN,data.spec1.nspecC,2*data.spec1.nv));     % matrix of all Rx-summed FIDs

    %--- phase/ECC correction, Rx combination ---
    if iterCnt==1       
        if flag.dataPhaseCorr==1        % Klose method
            if flag.dataKloseMode==1            % summation of phase cycling steps before Klose correction with one, combined phase trace
                %--- preprocessing of water reference ---
                if ~SP2_Data_PhaseCorrKloseRxCombJdeArray
                    return
                end

                %--- Klose correction of all JDE acquisitions (phase cycle, edit
                %--- on/off, NR) with identical phase reference ---
                phaseCorr = permute(repmat(exp(-1i*data.spec2.klosePhase),[1 1 data.spec1.seriesN 2*data.spec1.nv]),[3 1 2 4]);            
                data.spec1.fidArrSel(:,:,data.rcvrInd,:) = data.spec1.fidArrSel(:,:,data.rcvrInd,:) .* phaseCorr;

                %--- info printout ---
                fprintf('(Combined phase-cycle) Klose phase correction applied.\n');
            elseif flag.dataKloseMode==2        % Klose correction with individual phase cycling steps
                for seriesCnt = 1:data.spec1.seriesN
                    for nrCnt = 1:2*data.spec1.nv
                        for rCnt = 1:data.spec1.nRcvrs
                            if ndims(data.spec2.fidSel)==2     % spectral + receivers, single reference for all
                                phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt)));
                            else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
                                % phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt,mod(nrCnt-1,data.nPhCycle)+1)));
                                if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                    fprintf('\n%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                    return
                                else
                                    %--- info printout ---
                                    if seriesCnt==1 && rCnt==1          % 1st receiver only
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
                                    phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                                end
                            end
                            phaseVec = exp(-1i*phaseCorr');
                            data.spec1.fidArrSel(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArrSel(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
                        end
                    end
                end

                %--- info printout ---
                fprintf('(Phase cycle-specific) Klose phase correction applied.\n');
            else            % Klose correction with selected/single reference (from arrayed experiment)
                %--- consistency check ---
                if ndims(data.spec2.fidSel)==2
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
                    for nrCnt = 1:2*data.spec1.nv
                        for rCnt = 1:data.spec1.nRcvrs
                            if ndims(data.spec2.fidSel)==2     % spectral + receivers, single reference for all
                                phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt)));
                            else                            % spectral + receivers + NR, NR-specific reference (single NR cycle of FID 2)
        %                         phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt,ceil(nrCnt/2))));
                                if data.spec2.nr==1         % single reference
                                    % phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt,mod(nrCnt-1,data.nPhCycle)+1)));
                                    if mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds>size(data.spec2.fid,3)
                                        fprintf('%s:\nIndexing exceeds data dimension.\nCheck NR selection and DS for consistency...\n',FCTNAME);
                                        return
                                    else
                                        %--- info printout ---
                                        if seriesCnt==1 && rCnt==1          % 1st receiver only
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
                                        phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                                    end
                                else                        % reference array (e.g. multiple JDE frequencies)
                                    phaseCorr = unwrap(angle(data.spec2.fidSel(:,rCnt,data.phaseCorrNr)));
                                end
                            end
                            phaseVec = exp(-1i*phaseCorr');
                            data.spec1.fidArrSel(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArrSel(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
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
            if length(size(data.spec2.fidSel))==3
                weightVec = mean(abs(data.spec2.fidSel(1:5,data.rcvrInd,1)));
            else
                weightVec = mean(abs(data.spec2.fidSel(1:5,data.rcvrInd)));
            end
            weightVec = weightVec/sum(weightVec);
            weightMat = permute(repmat(weightVec,[data.spec1.nspecC 1 2*data.spec1.nv data.spec1.seriesN]),[4 1 2 3]);
            data.spec1.fidArrRxComb = data.spec1.fidArrSel(:,:,data.rcvrInd,:) .* weightMat;
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));

            %--- info printout ---
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        else
            %--- non-weighted summation ---
            data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArrSel(:,:,data.rcvrInd,:),3));

            %--- info printout ---
            fprintf('Non-weighted summation of Rx channels applied:\n');
        end
    end

    %--- 1) frequency shift determination and alignment ---
    if flag.dataAlignFrequ && iterCnt<=data.frAlignIter
        %--- extract reference FID ---
        if iterCnt==1
            if data.frAlignRefFid(1)>2*data.spec1.nv || data.frAlignRefFid(2)>2*data.spec1.nv
                fprintf('%s ->\nAll reference FIDs must be within the first experiment series, i.e. <=NR.\nProgram aborted\n',FCTNAME);
                return
            end
            refFid1 = data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(1));
            refFid2 = data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(2));
        else
            minSelect = min(data.select);       % 1st selected NR
            if mod(minSelect,2)==0              % even
                minSelect1 = minSelect+1;
                minSelect2 = minSelect;
            else                                % odd
                minSelect1 = minSelect;
                minSelect2 = minSelect+1;
            end
            refFid1 = mean(data.spec1.fidArrRxComb(1,:,minSelect1:2:end),3);            % assuming a continuous vector...
            refFid2 = mean(data.spec1.fidArrRxComb(1,:,minSelect2:2:end),3);            % assuming a continuous vector...
        end
        SP2_Data_AutoFrequDetPrep(data.spec1)
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:2*data.spec1.nv
                %--- shift determination ---
                if seriesCnt==1 && nrCnt<=data.frAlignVerbMax                           % verbose only for the first 10 FIDs
                    if mod(nrCnt,2)==1                  % odd / condition 1
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit ON',iterCnt,seriesCnt,nrCnt);
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                    else                                % even / condition 2
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit OFF',iterCnt,seriesCnt,nrCnt);
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.frAlignPpm2Min,data.frAlignPpm2Max,infoStr,flag.dataAlignVerbose);
                    end
                else                                    % no display for nrCnt>10 (independent of verbose setting)
                    if mod(nrCnt,2)==1                  % odd / condition 1
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,'',0);
                    else                                % even / condition 2
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.frAlignPpm2Min,data.frAlignPpm2Max,'',0);
                    end
                end
                if ~f_succ
                    fprintf('%s ->\nAutomated frequency determination failed for FID #i (scan %i).\n',...
                            FCTNAME,seriesCnt,data.spec1.seriesVec(seriesCnt))
                    return
                end

                %--- frequency correction ---
                % 1 frequency for all receivers of the same FID
                phPerPt = frequMat(seriesCnt,nrCnt,iterCnt)*data.spec1.dwell*data.spec1.nspecC*(pi/180)/(2*pi);    % corr phase per point
                data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = exp(-1i*phPerPt*(0:data.spec1.nspecC-1)) .* ...
                                                             squeeze(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt));    

                %--- info printout ---
                currNum = nrCnt+(seriesCnt-1)*2*data.spec1.nv;
                if mod(currNum,10)==0 || currNum==2*data.spec1.nv*data.spec1.seriesN
                    fprintf('Frequency alignment #%i of %i done (iter %i, scan %i, NR %i).\n',currNum,...
                            2*data.spec1.nv*data.spec1.seriesN,iterCnt,data.spec1.seriesVec(seriesCnt),nrCnt)

                end
            end
        end
    end

    %--- 2) phase determination and alignment ---
    if flag.dataAlignPhase && iterCnt<=data.phAlignIter
        %--- extract reference FID ---
        if iterCnt==1
            if data.phAlignRefFid(1)>2*data.spec1.nv || data.phAlignRefFid(2)>2*data.spec1.nv
                fprintf('%s ->\nThe reference FID must be within the first experiment series, i.e. <=NR.\nProgram aborted\n',FCTNAME);
                return
            end
            refFid1 = data.spec1.fidArrRxComb(1,:,data.phAlignRefFid(1));
            refFid2 = data.spec1.fidArrRxComb(1,:,data.phAlignRefFid(2));
        else
            minSelect = min(data.select);       % 1st selected NR
            if mod(minSelect,2)==0              % even
                minSelect1 = minSelect+1;
                minSelect2 = minSelect;
            else                                % odd
                minSelect1 = minSelect;
                minSelect2 = minSelect+1;
            end
            refFid1 = mean(data.spec1.fidArrRxComb(1,:,minSelect1:2:end),3);
            refFid2 = mean(data.spec1.fidArrRxComb(1,:,minSelect2:2:end),3);
        end
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:2*data.spec1.nv
                %--- phase determination ---
                if seriesCnt==1 && nrCnt<=data.phAlignVerbMax                           % verbose only for the first 10 FIDs
                    if mod(nrCnt,2)==1              % odd / condition 1
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit ON',iterCnt,seriesCnt,nrCnt);
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                    else                            % even / condition 2
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit OFF',iterCnt,seriesCnt,nrCnt);
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.phAlignPpm2Min,data.phAlignPpm2Max,infoStr,flag.dataAlignVerbose);
                    end
                else                    % no display for nrCnt>10 (independent of verbose setting)
                    if mod(nrCnt,2)==1              % odd / condition 1
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,'',0);
                    else
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.phAlignPpm2Min,data.phAlignPpm2Max,'',0);
                    end
                end
                if ~f_succ
                    fprintf('%s ->\nAutomated phase determination failed for FID #i (scan %i).\n',...
                            FCTNAME,seriesCnt,data.spec1.seriesVec(seriesCnt))
                    return
                end

                %--- apply (relative) phase alignment ---
                % 1 phase for all receivers of the same FID
                data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = exp(1i*phaseMat(seriesCnt,nrCnt,iterCnt)*pi/180) * ...
                                                             data.spec1.fidArrRxComb(seriesCnt,:,nrCnt);

                %--- info printout ---
                currNum = nrCnt+(seriesCnt-1)*2*data.spec1.nv;
                if mod(currNum,10)==0 || currNum==2*data.spec1.nv*data.spec1.seriesN
                    fprintf('Phase alignment #%i of %i done (iter %i, scan %i, NR %i)\n',currNum,...
                            2*data.spec1.nv*data.spec1.seriesN,iterCnt,data.spec1.seriesVec(seriesCnt),nrCnt)
                end
            end
        end
    end
end

%--- 3) amplitude determination and correction ---
if flag.dataAlignAmpl
    lbProc    = 3;     % 3 Hz line broadening to reduce dependency on late data points
    lbWeight  = exp(-lbProc*data.spec1.dwell*(0:data.spec1.nspecC-1)*pi);
    refFid1   = squeeze(data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(1)));
    refFid2   = squeeze(data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(2)));
    refSpec1  = fftshift(fft(refFid1.*lbWeight,[],2),2);
    refSpec2  = fftshift(fft(refFid2.*lbWeight,[],2),2);
    % note that the reversed spectral order
    [minI,maxI,ppmZoom,refSpec1Zoom,f_succ] = SP2_Data_ExtractPpmRange(data.frAlignPpmMin,data.frAlignPpmMax,...
                                                                       data.ppmCalib,data.spec1.sw,abs(rot90(refSpec1)));
    [minI,maxI,ppmZoom,refSpec2Zoom,f_succ] = SP2_Data_ExtractPpmRange(data.frAlignPpmMin,data.frAlignPpmMax,...
                                                                       data.ppmCalib,data.spec1.sw,abs(rot90(refSpec2)));
    maxAbsRef1 = max(abs(refSpec1(minI:maxI)));
    maxAbsRef2 = max(abs(refSpec2(minI:maxI)));
    for seriesCnt = 1:data.spec1.seriesN
        for nrCnt = 1:2*data.spec1.nv
            specTmp   = fftshift(fft(squeeze(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt)).*lbWeight,[],2),2);
            maxAbsTmp = max(abs(specTmp(minI:maxI)));
%                     fprintf('ratio %.2f\n',maxAbsRef/maxAbsTmp);
            if mod(nrCnt,2)==1              % odd / condition 1
                amplMat(seriesCnt,nrCnt) = maxAbsRef1/maxAbsTmp;
            else                            % even / condition 2
                amplMat(seriesCnt,nrCnt) = maxAbsRef2/maxAbsTmp;
            end
            data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = amplMat(seriesCnt,nrCnt) * data.spec1.fidArrRxComb(seriesCnt,:,nrCnt);

            %--- info printout ---
            currNum = nrCnt+(seriesCnt-1)*2*data.spec1.nv;
            if mod(currNum,10)==0 || currNum==2*data.spec1.nv*data.spec1.seriesN
                fprintf('Amplitude alignment #%i of %i done (scan %i, NR %i)\n',currNum,...
                        2*data.spec1.nv*data.spec1.seriesN,data.spec1.seriesVec(seriesCnt),nrCnt)
            end
        end
    end
end

%--- info printout ---
if flag.dataAlignFrequ
    for iterCnt = 1:data.frAlignIter
        fprintf('\nFREQUENCY ALIGNMENT (iteration %i):\n',iterCnt);
        for seriesCnt = 1:data.spec1.seriesN
            if flag.dataExpType==3      % JDE experiment
                fprintf('Scan #%i (%i of %i), edit ON:\n%s Hz\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(frequMat(seriesCnt,1:2:end,iterCnt),2))
                fprintf('Scan #%i (%i of %i), edit OFF:\n%s Hz\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(frequMat(seriesCnt,2:2:end,iterCnt),2))
            else
                fprintf('Scan #%i (%i of %i):\n%s Hz\n',...
                        data.spec1.seriesVec(seriesCnt),seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(frequMat(seriesCnt,:,iterCnt),2))
            end
        end
        frequVec = reshape(frequMat(:,:,iterCnt),1,data.spec1.seriesN*2*data.spec1.nv);
        fprintf('Total min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVec),...
                max(frequVec),median(frequVec),mean(frequVec),std(frequVec))
    end
end
if flag.dataAlignPhase
    for iterCnt = 1:data.phAlignIter
        fprintf('\nPHASE ALIGNMENT (iteration %i):\n',iterCnt);
        for seriesCnt = 1:data.spec1.seriesN
            if flag.dataExpType==3      % JDE experiment
                fprintf('Scan #%i (%i of %i), edit ON:\n%s deg\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(phaseMat(seriesCnt,1:2:end,iterCnt)))
                fprintf('Scan #%i (%i of %i), edit OFF:\n%s deg\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(phaseMat(seriesCnt,2:2:end,iterCnt)))
            else
                fprintf('Scan #%i (%i of %i):\n%s deg\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(phaseMat(seriesCnt,:,iterCnt)))
            end
        end
        phaseVec = reshape(phaseMat(:,:,iterCnt),1,data.spec1.seriesN*2*data.spec1.nv);
        fprintf('Total min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVec),...
                max(phaseVec),median(phaseVec),mean(phaseVec),std(phaseVec))
        phaseVec = mod(phaseVec+180,360)-180;       % 180deg shift to move away from the 0deg wrap
        fprintf('mod(360deg) corrected:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVec),...
                max(phaseVec),median(phaseVec),mean(phaseVec),std(phaseVec))
    end
end
if flag.dataAlignAmpl
    fprintf('\nAMPLITUDE CORRECTION:\n');
    for seriesCnt = 1:data.spec1.seriesN
        if flag.dataExpType==3      % JDE experiment
            fprintf('Scan #%i (%i of %i), edit ON:\n%s Hz\n',...
                    data.spec1.seriesVec(seriesCnt),...
                    seriesCnt,data.spec1.seriesN,...
                    SP2_Vec2PrintStr(amplMat(seriesCnt,1:2:end),2))
            fprintf('Scan #%i (%i of %i), edit OFF:\n%s Hz\n',...
                    data.spec1.seriesVec(seriesCnt),...
                    seriesCnt,data.spec1.seriesN,...
                    SP2_Vec2PrintStr(amplMat(seriesCnt,2:2:end),2))
        else
            fprintf('Scan #%i (%i of %i):\n%s Hz\n',...
                    data.spec1.seriesVec(seriesCnt),seriesCnt,data.spec1.seriesN,...
                    SP2_Vec2PrintStr(amplMat(seriesCnt,:),2))
        end
    end
    amplVec = reshape(amplMat,1,data.spec1.seriesN*2*data.spec1.nv);
    fprintf('Total min/max/median/mean/SD = %.2f/%.2f/%.2f/%.2f/%.2f\n',min(amplVec),...
            max(amplVec),median(amplVec),mean(amplVec),std(amplVec))
end


%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update correction flag ---
flag.dataCorrAppl = 1;

%--- update success flag ---
f_done = 1;




end
