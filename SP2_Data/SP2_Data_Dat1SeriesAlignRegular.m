%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1SeriesAlignRegular
%% 
%%  Phase and frequency alignment of regular MRS experiment series.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_Dat1SeriesAlignRegular';


%--- init success flag ---
f_succ = 0;

%--- consistency check: aligment methods ---
if ~flag.dataAlignPhase && ~flag.dataAlignFrequ && ~flag.dataAlignAmpl
    fprintf('%s ->\nAt least one alignment target (phase, frequency or amplitude) has to be selected.\nProgram aborted.\n',FCTNAME);
    return
end

%--- check data existence: metabolite scans ---
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
if ndims(data.spec1.fid)~=2 && ndims(data.spec1.fid)~=3
    fprintf('%s ->\nSpectral FID 1 must have 2 or 3 dimensions (spectral + receivers + NR),\n',FCTNAME);
    fprintf('but %i dimensions found (%s). Program aborted.\n',ndims(data.spec1.fid),size(data.spec1.fid));
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
if ndims(data.spec2.fid)~=2 && ndims(data.spec2.fid)~=3
    fprintf('%s ->\nSpectral FID 2 must have 2 or 3 dimensions (spectral + receivers + NR),\n',FCTNAME);
    fprintf('but %i dimensions found (%s). Program aborted.\n',ndims(data.spec2.fid),size(data.spec2.fid));
    return
end

%--- reference validity of reference receiver for frequency alignment ---
% note that the FID from the 1st active (ie. selected) receiver is used for reference 
if ~any(data.rcvrInd)
    fprintf('%s ->\nAt least one receiver must be selected (for frequency alignment).\nProgram aborted.\n',FCTNAME);
    return
end

%--- separate processing stream based on data dimension ---
amplMat  = zeros(data.spec1.seriesN,data.spec1.nr);                         % optimal amplitude scalings
phaseMat = zeros(data.spec1.seriesN,data.spec1.nr,data.phAlignIter);        % optimal phasings
frequMat = zeros(data.spec1.seriesN,data.spec1.nr,data.frAlignIter);        % optimal frequency corrections
    
%--- info printout ---
fprintf('\nREGULAR MR SPECTROSCOPY ALIGNMENT\n');

%--- phase/ECC correction, Rx combination ---
for iterCnt = 1:max(data.phAlignIter,data.frAlignIter)
    if iterCnt==1       
        if flag.dataPhaseCorr==1        % Klose method
            if flag.dataKloseMode==1            % summation of phase cycling steps before Klose correction with one, combined phase trace
                %--- preprocessing of water reference ---
                if ~SP2_Data_PhaseCorrKloseRxComb
                    return
                end

                %--- Klose correction of all JDE acquisitions (phase cycle, edit
                %--- on/off, NR) with identical phase reference ---
                phaseCorr = permute(repmat(exp(-1i*data.spec2.klosePhase),[1 1 data.spec1.seriesN data.spec1.nr]),[3 1 2 4]);            
                data.spec1.fidArr(:,:,data.rcvrInd,:) = data.spec1.fidArr(:,:,data.rcvrInd,:) .* phaseCorr;

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
                                    phaseCorr = unwrap(angle(data.spec2.fid(:,rCnt,mod(nrCnt-1-data.ds,data.nPhCycle)+1+data.ds)));
                                end
                            end
                            phaseVec = exp(-1i*phaseCorr');
                            data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
                        end
                    end
                end

                %--- info printout ---
                fprintf('(Phase cycle-specific) Klose phase correction applied.\n');
            else            % Klose correction with selected/single reference (from arrayed experiment)
                %--- consistency check ---
                if ndims(data.spec2.fid)==2
                    if data.phaseCorrNr==1
                        fprintf('\nWARNING:\nSelected reference scan is not arrayed\nand does not have multiple NR''s available (NR=1 is used).\n');
                    else            % selected NR does not exist
                        fprintf('\nSelected reference scan is not arrayed\nand does not have multiple NR''s available (NR=1 is used).\n');
                        fprintf('Program aborted.\n');
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
                            data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nrCnt)) .* phaseVec;
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
            data.spec1.fidArrRxComb = data.spec1.fidArr(:,:,data.rcvrInd,:) .* weightMat;
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArrRxComb,3));
            
            % if flag.verbose
            %     fprintf('size(data.spec1.fidArr)       = %s\n',SP2_Vec2PrintStr(size(data.spec1.fidArr),0));
            %     fprintf('size(data.spec1.fidArrRxComb) = %s\n',SP2_Vec2PrintStr(size(data.spec1.fidArrRxComb),0));
            % end
            
            %--- info printout ---
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        else
            %--- non-weighted summation ---
            data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:),3));

            %--- info printout ---
            fprintf('Non-weighted summation of Rx channels applied:\n');
        end
    end             % end of iterCnt==1

    %--- 1) frequency shift determination and alignment ---
    if flag.dataAlignFrequ && iterCnt<=data.frAlignIter
        %--- extract reference FID ---
        if iterCnt==1 && data.frAlignRefFid(1)>0
            if data.frAlignRefFid(1)>data.spec1.nr
                fprintf('\n%s ->\nAll reference FIDs must be within the first experiment series, i.e. <=NR.\nProgram aborted\n\n',FCTNAME);
                return
            end
            refFid = data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(1));
        else
            if flag.dataAllSelect           % all FIDs
                nrInd = 1:data.spec1.nr;
            else                            % selected FIDs
                % consistency check
                if any(data.select>data.spec1.nr)
                    fprintf('\n%s ->\nNR selection exceeds data dimension (NR=%.0f)\nProgram aborted\n\n',...
                            FCTNAME,data.spec1.nr)
                    return
                end
                
                % assign NR selection
                nrInd = data.select;
            end
            % info printout
            if iterCnt==2
                fprintf('Combination of NR for iterations >1:\n');
                fprintf('%s\n',SP2_Vec2PrintStr(nrInd,0));
            end
            refFid = mean(data.spec1.fidArrRxComb(1,:,nrInd),3);           
        end
        SP2_Data_AutoFrequDetPrep(data.spec1)
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:data.spec1.nr
                %--- shift determination ---
                if seriesCnt==1 && nrCnt<=data.frAlignVerbMax                     % verbose only for the first 10 FIDs
                    infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f',iterCnt,seriesCnt,nrCnt);
                    [frequMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid)',data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                else                                    % no display for nrCnt>10 (independent of verbose setting)
                    % fprintf('\nseriesCnt/nrCnt/iterCnt = %.0f/%.0f/%.0f\n',seriesCnt,nrCnt,iterCnt);
                    % fprintf('size(data.spec1.fidArrRxComb) = %s\n',SP2_Vec2PrintStr(size(data.spec1.fidArrRxComb),0));
                    % fprintf('size(data.spec1.fidArrRxComb) = %s\n',SP2_Vec2PrintStr(size(frequMat),0));
                    [frequMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid)',data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,'',0);
                end
                if ~f_done
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
                currNum = nrCnt+(seriesCnt-1)*data.spec1.nr;
                if mod(currNum,10)==0 || currNum==data.spec1.nr*data.spec1.seriesN
                    fprintf('Frequency alignment #%i of %i done (iter %i, scan %i, NR %i).\n',currNum,...
                            data.spec1.nr*data.spec1.seriesN,iterCnt,data.spec1.seriesVec(seriesCnt),nrCnt)

                end
            end                 % end of nrCnt
        end                     % end of seriesCnt
    end                         % end of frequency alignment

    %--- 2) phase determination and alignment ---
    if flag.dataAlignPhase && iterCnt<=data.phAlignIter
        %--- extract reference FID ---
        if iterCnt==1 && data.phAlignRefFid(1)>0
            if data.phAlignRefFid(1)>data.spec1.nr
                fprintf('%s ->\nThe reference FID must be within the first experiment series, i.e. <=NR.\nProgram aborted\n',FCTNAME);
                return
            end
            refFid = data.spec1.fidArrRxComb(1,:,data.phAlignRefFid(1));
        else
            if flag.dataAllSelect           % all FIDs
                nrInd = 1:data.spec1.nr;
            else                            % selected FIDs
                nrInd = data.select;
            end
            if iterCnt==2
                fprintf('Combination of NR for iterations >1:\n');
                fprintf('%s\n',SP2_Vec2PrintStr(nrInd,0));
            end
            refFid = mean(data.spec1.fidArrRxComb(1,:,nrInd),3);
        end
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:data.spec1.nr
                %--- phase determination ---
                if seriesCnt==1 && nrCnt<=data.phAlignVerbMax              % verbose only for the first 10 FIDs
                    infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f',iterCnt,seriesCnt,nrCnt);
                    [phaseMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid)',data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                else                    % no display for nrCnt>10 (independent of verbose setting)
                    [phaseMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid)',data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,'',0);
                end
                if ~f_done
                    fprintf('%s ->\nAutomated phase determination failed for FID #i (scan %i).\n',...
                            FCTNAME,seriesCnt,data.spec1.seriesVec(seriesCnt))
                    return
                end

                %--- apply (relative) phase alignment ---
                % 1 phase for all receivers of the same FID
                data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = exp(1i*phaseMat(seriesCnt,nrCnt,iterCnt)*pi/180) * ...
                                                             data.spec1.fidArrRxComb(seriesCnt,:,nrCnt);

                %--- info printout ---
                currNum = nrCnt+(seriesCnt-1)*data.spec1.nr;
                if mod(currNum,10)==0 || currNum==data.spec1.nr*data.spec1.seriesN
                    fprintf('Phase alignment #%i of %i done (iter %i, scan %i, NR %i)\n',currNum,...
                            data.spec1.nr*data.spec1.seriesN,iterCnt,data.spec1.seriesVec(seriesCnt),nrCnt)
                end
            end             % end of nrCnt
        end                 % end of seriesCnt
    end                     % end of phase alignment
end                         % end of iterCnt

%--- 3) amplitude determination and correction ---
if flag.dataAlignAmpl
    %--- matrix spectrum analysis ---
    lbWeight = exp(-data.amAlignExpLb*data.spec1.dwell*(0:data.spec1.nspecC-1)*pi);
    datFid   = permute(data.spec1.fidArrRxComb,[2 1 3]);      % before: series/nspecC/nr, after: nspecC/series/nr
    datFid   = datFid .* repmat(lbWeight',[1 data.spec1.seriesN data.spec1.nr]);
    datSpec  = fftshift(fft(datFid(1:data.amAlignFftCut,:,:),data.amAlignFftZf,1),1);

    %--- determination of amplitude behaviour ---
    % refSpec = mean(datSpec(:,1,data.amAlignRef1Vec),3);
    refSpec = datSpec(:,1,data.amAlignRef1Vec);
    [amplMat,f_done] = SP2_Data_AutoAmplDetRegular(datSpec,refSpec,data.amAlignRef1Vec,'',flag.dataAlignVerbose); 

    %--- amplitude correction ---
    for seriesCnt = 1:data.spec1.seriesN
        for nrCnt = 1:data.spec1.nr
            data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = amplMat(seriesCnt,nrCnt)*data.spec1.fidArrRxComb(seriesCnt,:,nrCnt);
        end
    end 
end

%--- info printout ---
if flag.dataAlignFrequ
    %--- iterations ---
    if flag.verbose
        for iterCnt = 1:data.frAlignIter
            fprintf('\nFREQUENCY ALIGNMENT (iteration %i):\n',iterCnt);
            for seriesCnt = 1:data.spec1.seriesN
                fprintf('Scan #%i (%i of %i), all NR:\n%s Hz\n',...
                        data.spec1.seriesVec(seriesCnt),seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(frequMat(seriesCnt,:,iterCnt),2))
            end
            frequVecTot = reshape(frequMat(:,:,iterCnt),1,data.spec1.seriesN*data.spec1.nr);
            fprintf('All NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecTot),...
                    max(frequVecTot),median(frequVecTot),mean(frequVecTot),std(frequVecTot))
            frequVecSel = reshape(frequMat(:,data.select,iterCnt),1,data.spec1.seriesN*data.selectN);
            fprintf('Selected NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecSel),...
                    max(frequVecSel),median(frequVecSel),mean(frequVecSel),std(frequVecSel))
        end
    end
    
    %--- total ---
    fprintf('\nCOMBINED FREQUENCY ALIGNMENT (all iterations):\n');
    if flag.dataAllSelect           % all NR
        % all
        nrVec = 1:data.spec1.nr;
        for seriesCnt = 2:data.spec1.seriesN
            nrVec = [nrVec (1:data.spec1.nr)+(seriesCnt-1)*data.spec1.nr];
        end
        frequVec = reshape(permute(sum(frequMat,3),[2 1]),1,data.spec1.seriesN*data.spec1.nr);
        fprintf('All NR:\n%s Hz\n',SP2_Vec2PrintStr(frequVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVec),...
                max(frequVec),median(frequVec),mean(frequVec),std(frequVec))
    else                            % selection applied
        % selected
        nrVec = data.select;
        for seriesCnt = 2:data.spec1.seriesN
            nrVec = [nrVec data.select+(seriesCnt-1)*data.spec1.nr];
        end
        frequVec = reshape(permute(sum(frequMat(:,data.select,:),3),[2 1]),1,data.spec1.seriesN*data.selectN);
        fprintf('Selected NR:\n%s Hz\n',SP2_Vec2PrintStr(frequVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVec),...
                max(frequVec),median(frequVec),mean(frequVec),std(frequVec))
    end
    
    %--- figure ---
    if flag.verbose
        frequDriftFh = figure('IntegerHandle','off');
        set(frequDriftFh,'NumberTitle','off','Name',sprintf(' Frequency Drift Summary'),...
            'Position',[687 184 581 545],'Color',[1 1 1],'Tag','AlignQA');
        plot(nrVec,frequVec,'*')
        [minX maxX minY maxY] = SP2_IdealAxisValuesXGap(nrVec,frequVec);
        axis([minX maxX minY maxY])
        xlabel('NR [1]')
        ylabel('Frequency [Hz]')
    end
end
if flag.dataAlignPhase
    %--- iterations ---
    if flag.verbose
        for iterCnt = 1:data.phAlignIter
            fprintf('\nPHASE ALIGNMENT (iteration %i):\n',iterCnt);
            for seriesCnt = 1:data.spec1.seriesN
                fprintf('Scan #%i (%i of %i), all NR:\n%s deg\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(phaseMat(seriesCnt,:,iterCnt)))
            end
            phaseVecTot = reshape(phaseMat(:,:,iterCnt),1,data.spec1.seriesN*data.spec1.nr);
            fprintf('All NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecTot),...
                    max(phaseVecTot),median(phaseVecTot),mean(phaseVecTot),std(phaseVecTot))
            phaseVecTot = mod(phaseVecTot+180,360)-180;       % 180deg shift to move away from the 0deg wrap
            fprintf('All NR, mod(360deg) corrected:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecTot),...
                    max(phaseVecTot),median(phaseVecTot),mean(phaseVecTot),std(phaseVecTot))
            phaseVecSel = reshape(phaseMat(:,data.select,iterCnt),1,data.spec1.seriesN*data.selectN);
            fprintf('Selected NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecSel),...
                    max(phaseVecSel),median(phaseVecSel),mean(phaseVecSel),std(phaseVecSel))
            phaseVecSel = mod(phaseVecSel+180,360)-180;       % 180deg shift to move away from the 0deg wrap
            fprintf('Selected NR, mod(360deg) corrected:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecSel),...
                    max(phaseVecSel),median(phaseVecSel),mean(phaseVecSel),std(phaseVecSel))
        end
    end
    
    %--- total ---
    fprintf('\nCOMBINED PHASE ALIGNMENT (all iterations):\n');
    phaseMat = mod(phaseMat+180,360)-180;
    if flag.dataAllSelect           % all NR
        phVec = reshape(permute(sum(phaseMat,3),[2 1]),1,data.spec1.seriesN*data.spec1.nr);
        fprintf('All NR, mod(360deg) corrected:\n%s deg\n',SP2_Vec2PrintStr(phVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phVec),...
                max(phVec),median(phVec),mean(phVec),std(phVec))
    else                            % selected NR
        phVec = reshape(permute(sum(phaseMat(:,data.select,:),3),[2 1]),1,data.spec1.seriesN*data.selectN);
        fprintf('Selected NR, mod(360deg) corrected:\n%s deg\n',SP2_Vec2PrintStr(phVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phVec),...
                max(phVec),median(phVec),mean(phVec),std(phVec))
    end 
end
if flag.dataAlignAmpl
    fprintf('\nAMPLITUDE CORRECTION:\n');
    for seriesCnt = 1:data.spec1.seriesN
        fprintf('Scan #%i (%i of %i):\n%s Hz\n',...
                data.spec1.seriesVec(seriesCnt),seriesCnt,data.spec1.seriesN,...
                SP2_Vec2PrintStr(amplMat(seriesCnt,:),2))
    end
    amplVecTot = reshape(amplMat,1,data.spec1.seriesN*data.spec1.nr);
    fprintf('Total min/max/median/mean/SD = %.2f/%.2f/%.2f/%.2f/%.2f\n',min(amplVecTot),...
            max(amplVecTot),median(amplVecTot),mean(amplVecTot),std(amplVecTot))
    amplVecSel = reshape(amplMat(:,data.select),1,data.spec1.seriesN*data.selectN);
    fprintf('Selected min/max/median/mean/SD = %.2f/%.2f/%.2f/%.2f/%.2f\n',min(amplVecSel),...
            max(amplVecSel),median(amplVecSel),mean(amplVecSel),std(amplVecSel))
end
    
%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update correction flag ---
flag.dataCorrAppl = 1;

%--- update success flag ---
f_succ = 1;



