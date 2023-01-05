%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat1SeriesAlignJde
%% 
%%  Phase and frequency alignment of JDE experiment series.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_Dat1SeriesAlignJde';


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
fprintf('\nJDE ALIGNMENT\n');

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
                        fprintf('\nSelected reference scan is not arrayed\nand does not have multiple NR''s available (NR=1 is used).\nProgram aborted.\n\n');
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
                fprintf('Single scan-specific Klose phase correction applied (NR %.0f).\n',data.phaseCorrNr);
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
        if iterCnt==1
            if data.frAlignRefFid(1)>data.spec1.nr || data.frAlignRefFid(2)>data.spec1.nr
                fprintf('%s ->\nAll reference FIDs must be within the first experiment series, i.e. <=NR.\nProgram aborted\n',FCTNAME);
                return
            end
            refFid1 = data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(1));
            refFid2 = data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(2));
        else
%             minSelect = min(data.select);       % 1st selected NR
%             if mod(minSelect,2)==0              % even
%                 minSelect1 = minSelect+1;
%                 minSelect2 = minSelect;
%             else                                % odd
%                 minSelect1 = minSelect;
%                 minSelect2 = minSelect+1;
%             end
%             refFid1 = mean(data.spec1.fidArrRxComb(1,:,minSelect1:2:end),3);              % assuming a continuous vector...
%             refFid2 = mean(data.spec1.fidArrRxComb(1,:,minSelect2:2:end),3);              % assuming a continuous vector...
            if flag.dataAllSelect           % all FIDs
                nrIndOdd  = find(mod(1:data.spec1.nr,2));
                nrIndEven = find(~mod(1:data.spec1.nr,2));
            else                            % selected FIDs
                nrIndOdd  = data.select(find(mod(data.select,2)));
                nrIndEven = data.select(find(~mod(data.select,2)));
            end
            if iterCnt==2
                fprintf('Combination of NR for iterations >1:\n');
                fprintf('Odd:  %s\n',SP2_Vec2PrintStr(nrIndOdd,0));
                fprintf('Even: %s\n',SP2_Vec2PrintStr(nrIndEven,0));
            end
            refFid1 = mean(data.spec1.fidArrRxComb(1,:,nrIndOdd),3);                        % not assuming a continuous vector...
            refFid2 = mean(data.spec1.fidArrRxComb(1,:,nrIndEven),3);                       % not assuming a continuous vector...
        end
        SP2_Data_AutoFrequDetPrep(data.spec1)
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:data.spec1.nr
                %--- shift determination ---
                if seriesCnt==1 && nrCnt<=data.frAlignVerbMax                               % verbose only for the first 10 FIDs
                    if mod(nrCnt,2)==1                  % odd / condition 1
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit ON',iterCnt,seriesCnt,nrCnt);
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                    else                                % even / condition 2
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit OFF',iterCnt,seriesCnt,nrCnt);
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.frAlignPpm2Min,data.frAlignPpm2Max,infoStr,flag.dataAlignVerbose);
                    end
                else                                    % no display for nrCnt>10 (independent of verbose setting)
                    if mod(nrCnt,2)==1                  % odd / condition 1
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,'',0);
                    else                                % even / condition 2
                        [frequMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.frAlignPpm2Min,data.frAlignPpm2Max,'',0);
                    end
                end
                if ~f_done
                    fprintf('%s ->\nAutomated frequency determination failed for FID #%i (scan %i).\n',...
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
            end         % end of nrCnt
        end             % end of seriesCnt
    end                 % end of frequency alignment

    %--- 2) phase determination and alignment ---
    if flag.dataAlignPhase && iterCnt<=data.phAlignIter
        %--- extract reference FID ---
        if iterCnt==1
            if data.phAlignRefFid(1)>data.spec1.nr || data.phAlignRefFid(2)>data.spec1.nr
                fprintf('%s ->\nThe reference FID must be within the first experiment series, i.e. <=NR.\nProgram aborted\n',FCTNAME);
                return
            end
            refFid1 = data.spec1.fidArrRxComb(1,:,data.phAlignRefFid(1));
            refFid2 = data.spec1.fidArrRxComb(1,:,data.phAlignRefFid(2));
        else
%             minSelect = min(data.select);       % 1st selected NR
%             if mod(minSelect,2)==0              % even
%                 minSelect1 = minSelect+1;
%                 minSelect2 = minSelect;
%             else                                % odd
%                 minSelect1 = minSelect;
%                 minSelect2 = minSelect+1;
%             end

%             refFid1 = mean(data.spec1.fidArrRxComb(1,:,minSelect1:2:end),3);
%             refFid2 = mean(data.spec1.fidArrRxComb(1,:,minSelect2:2:end),3);
            nrIndOdd  = data.select(find(mod(data.select,2)));
            nrIndEven = data.select(find(~mod(data.select,2)));
            if ~flag.dataAlignFrequ
%                 nrIndOdd  = data.select(find(mod(data.select,2)));
%                 nrIndEven = data.select(find(~mod(data.select,2)));
                if iterCnt==2
                    fprintf('Combination of NR for iterations >1:\n');
                    fprintf('Odd:  %s\n',SP2_Vec2PrintStr(nrIndOdd,0));
                    fprintf('Even: %s\n',SP2_Vec2PrintStr(nrIndEven,0));
                end
            end
            refFid1 = mean(data.spec1.fidArrRxComb(1,:,nrIndOdd),3);
            refFid2 = mean(data.spec1.fidArrRxComb(1,:,nrIndEven),3);
        end
        for seriesCnt = 1:data.spec1.seriesN
            for nrCnt = 1:data.spec1.nr
                %--- phase determination ---
                if seriesCnt==1 && nrCnt<=data.phAlignVerbMax                       % verbose only for the first 10 FIDs
                    if mod(nrCnt,2)==1              % odd / condition 1
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit ON',iterCnt,seriesCnt,nrCnt);
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                    else                            % even / condition 2
                        infoStr = sprintf('Iteration %.0f, Series %.0f, NR %.0f, Edit OFF',iterCnt,seriesCnt,nrCnt);
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.phAlignPpm2Min,data.phAlignPpm2Max,infoStr,flag.dataAlignVerbose);
                    end
                else                    % no display for nrCnt>10 (independent of verbose setting)
                    if mod(nrCnt,2)==1              % odd / condition 1
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid1)',data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,infoStr,0);
                    else
                        [phaseMat(seriesCnt,nrCnt,iterCnt),f_done] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt))',conj(refFid2)',data.spec1,data.phAlignPpm2Min,data.phAlignPpm2Max,infoStr,0);
                    end
                end
                if ~f_done
                    fprintf('%s ->\nAutomated phase determination failed for FID #%i (scan %i).\n',...
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
            end         % end of nrCnt
        end             % end of seriesCnt
    end                 % end of frequency alignment
end                     % end of iterCnt

%--- 3) amplitude determination and correction ---
if flag.dataAlignAmpl
    %--- matrix spectrum analysis ---
    lbWeight = exp(-data.amAlignExpLb*data.spec1.dwell*(0:data.spec1.nspecC-1)*pi);
    datFid   = permute(data.spec1.fidArrRxComb,[2 1 3]);      % before: series/nspecC/nr, after: nspecC/series/nr
    datFid   = datFid .* repmat(lbWeight',[1 data.spec1.seriesN data.spec1.nr]);
    datSpec  = fftshift(fft(datFid(1:data.amAlignFftCut,:,:),data.amAlignFftZf,1),1);
    amplMat  = zeros(data.spec1.seriesN,data.spec1.nr);

    %--- determination of amplitude behaviour: editing ON condition ---
    if any(mod(data.amAlignRef1Vec,2)==1)               % at least one odd
        oddInd = find(mod(data.amAlignRef1Vec,2)==1);   % find odd entries
        refVec = (data.amAlignRef1Vec(oddInd)-1)/2+1;   % reference number in terms of specific editing condition
    else                                                % even only
        refVec = 0;                                     % no spectrum part of series 1 (i.e. not displayed)
    end
    refSpec = mean(datSpec(:,1,data.amAlignRef1Vec),3);
    [amplMat(:,1:2:data.spec1.nr),f_done] = SP2_Data_AutoAmplDetRegular(datSpec(:,:,1:2:data.spec1.nr),refSpec,refVec,'Edit ON',flag.dataAlignVerbose); 

    %--- amplitude correction: editin ON condition ---
    for seriesCnt = 1:data.spec1.seriesN
        for nrCnt = 1:2:data.spec1.nr
            data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = amplMat(seriesCnt,(nrCnt+1)/2)*data.spec1.fidArrRxComb(seriesCnt,:,nrCnt);
        end
    end

    %--- determination of amplitude behaviour: editing ON condition ---
    if any(mod(data.amAlignRef2Vec,2)==0)               % at least one even
        eveInd = find(mod(data.amAlignRef2Vec,2)==0);   % even entries
        refVec = data.amAlignRef2Vec(eveInd)/2;         % reference number in terms of specific editing condition
    else                                                % odd only
        refVec = 0;                                     % not part of series 1 (i.e. not displayed)
    end
    refSpec = mean(datSpec(:,1,data.amAlignRef2Vec),3);
    [amplMat(:,2:2:data.spec1.nr),f_done] = SP2_Data_AutoAmplDetRegular(datSpec(:,:,2:2:data.spec1.nr),refSpec,refVec,'Edit OFF',flag.dataAlignVerbose); 

    %--- amplitude correction: editin ON condition ---
    for seriesCnt = 1:data.spec1.seriesN
        for nrCnt = 2:2:data.spec1.nr
            data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = amplMat(seriesCnt,nrCnt/2)*data.spec1.fidArrRxComb(seriesCnt,:,nrCnt);
        end
    end 
end         % end of amplitude alignment                 

%--- info printout ---
if flag.dataAlignFrequ
    %--- iterations ---
    if flag.verbose
        for iterCnt = 1:data.frAlignIter
            fprintf('\nFREQUENCY ALIGNMENT (iteration %i):\n',iterCnt);
            for seriesCnt = 1:data.spec1.seriesN
                fprintf('Scan #%i (%i of %i), edit ON, all NR:\n%s Hz\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(frequMat(seriesCnt,1:2:end,iterCnt),2))
                fprintf('Scan #%i (%i of %i), edit OFF, all NR:\n%s Hz\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(frequMat(seriesCnt,2:2:end,iterCnt),2))
            end
            frequVecIter = reshape(frequMat(:,:,iterCnt),1,data.spec1.seriesN*data.spec1.nr);
            fprintf('All NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecIter),...
                    max(frequVecIter),median(frequVecIter),mean(frequVecIter),std(frequVecIter))
            frequVecSel = reshape(frequMat(:,data.select,iterCnt),1,data.spec1.seriesN*data.selectN);
            fprintf('Selected NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecSel),...
                    max(frequVecSel),median(frequVecSel),mean(frequVecSel),std(frequVecSel))
        end
    end
    
    %--- total ---
    fprintf('\nCOMBINED FREQUENCY ALIGNMENT (all iterations):\n');
    if flag.dataAllSelect           % all NR
        % total, edit ON
        nrVecON     = 1:2:data.spec1.nr;
        for seriesCnt = 2:data.spec1.seriesN
            nrVecON = [nrVecON (1:2:data.spec1.nr)+(seriesCnt-1)*data.spec1.nr];
        end
        frequVecON  = reshape(permute(sum(frequMat(:,1:2:end,:),3),[2 1]),1,data.spec1.seriesN*size(frequMat(:,1:2:end,:),2));
        fprintf('All NR (ON):\n%s Hz\n',SP2_Vec2PrintStr(frequVecON));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecON),...
                max(frequVecON),median(frequVecON),mean(frequVecON),std(frequVecON))
        % total, edit OFF
        nrVecOFF    = 2:2:data.spec1.nr;
        for seriesCnt = 2:data.spec1.seriesN
            nrVecOFF = [nrVecOFF (2:2:data.spec1.nr)+(seriesCnt-1)*data.spec1.nr];
        end
        frequVecOFF = reshape(permute(sum(frequMat(:,2:2:end,:),3),[2 1]),1,data.spec1.seriesN*size(frequMat(:,2:2:end,:),2));
        fprintf('\nAll NR (OFF):\n%s Hz\n',SP2_Vec2PrintStr(frequVecOFF));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecOFF),...
                max(frequVecOFF),median(frequVecOFF),mean(frequVecOFF),std(frequVecOFF))
        % total, complete
        frequVec = reshape(permute(sum(frequMat,3),[2 1]),1,data.spec1.seriesN*data.spec1.nr);
        fprintf('\nAll NR (complete):\n%s Hz\n',SP2_Vec2PrintStr(frequVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVec),...
                max(frequVec),median(frequVec),mean(frequVec),std(frequVec))
    else                            % selection applied
        % selected, edit ON
        nrVecON     = data.select(1:2:end);
        for seriesCnt = 2:data.spec1.seriesN
            nrVecON = [nrVecON data.select(1:2:end)+(seriesCnt-1)*data.spec1.nr];
        end
        frequVecON  = reshape(permute(sum(frequMat(:,data.select(1:2:end),:),3),[2 1]),1,data.spec1.seriesN*length(data.select(1:2:end)));
        fprintf('Selected NR (ON):\n%s Hz\n',SP2_Vec2PrintStr(frequVecON));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecON),...
                max(frequVecON),median(frequVecON),mean(frequVecON),std(frequVecON))
        % selected, edit OFF
        nrVecOFF    = data.select(2:2:end);
        for seriesCnt = 2:data.spec1.seriesN
            nrVecOFF = [nrVecOFF data.select(2:2:end)+(seriesCnt-1)*data.spec1.nr];
        end
        frequVecOFF = reshape(permute(sum(frequMat(:,data.select(2:2:end),:),3),[2 1]),1,data.spec1.seriesN*length(data.select(2:2:end)));
        fprintf('\nSelected NR (OFF):\n%s Hz\n',SP2_Vec2PrintStr(frequVecOFF));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVecOFF),...
                max(frequVecOFF),median(frequVecOFF),mean(frequVecOFF),std(frequVecOFF))
        % selected, complete
        frequVec = reshape(permute(sum(frequMat(:,data.select,:),3),[2 1]),1,data.spec1.seriesN*data.selectN);
        fprintf('\nSelected NR (complete):\n%s Hz\n',SP2_Vec2PrintStr(frequVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(frequVec),...
                max(frequVec),median(frequVec),mean(frequVec),std(frequVec))
    end
    
    %--- figure ---
    if flag.verbose
        frequDriftFh = figure('IntegerHandle','off');
        if flag.dataAllSelect           % all NR
            set(frequDriftFh,'NumberTitle','off','Name',sprintf(' Frequency Drift Summary of All NR (All Iterations)'),...
                'Position',[687 184 581 545],'Color',[1 1 1],'Tag','AlignQA');
        else
            set(frequDriftFh,'NumberTitle','off','Name',sprintf(' Frequency Drift Summary of Selected NR (All Iterations)'),...
                'Position',[687 184 581 545],'Color',[1 1 1],'Tag','AlignQA');
        end
        hold on
            plot(nrVecON,frequVecON,'*')
            plot(nrVecOFF,frequVecOFF,'*r')
        hold off
        [minX1 maxX1 minY1 maxY1] = SP2_IdealAxisValuesXGap(nrVecON,frequVecON);
        [minX2 maxX2 minY2 maxY2] = SP2_IdealAxisValuesXGap(nrVecOFF,frequVecOFF);
        axis([min(minX1,minX2) max(maxX1,maxX2) min(minY1,minY2) max(maxY1,maxY2)])
        xlabel('NR [1]')
        ylabel('Frequency [Hz]')
        legend('ON','OFF')
    end
end
if flag.dataAlignPhase
    %--- iterations ---
    if flag.verbose
        for iterCnt = 1:data.phAlignIter
            fprintf('\nPHASE ALIGNMENT (iteration %i):\n',iterCnt);
            for seriesCnt = 1:data.spec1.seriesN
                fprintf('Scan #%i (%i of %i), edit ON, all NR:\n%s deg\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(phaseMat(seriesCnt,1:2:end,iterCnt)))
                fprintf('Scan #%i (%i of %i), edit OFF, all NR:\n%s deg\n',...
                        data.spec1.seriesVec(seriesCnt),...
                        seriesCnt,data.spec1.seriesN,...
                        SP2_Vec2PrintStr(phaseMat(seriesCnt,2:2:end,iterCnt)))
            end
            phaseVecIter = reshape(permute(phaseMat(:,:,iterCnt),[2 1]),1,data.spec1.seriesN*data.spec1.nr);
            fprintf('All NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecIter),...
                    max(phaseVecIter),median(phaseVecIter),mean(phaseVecIter),std(phaseVecIter))
            phaseVecIter = mod(phaseVecIter+180,360)-180;       % 180deg shift to move away from the 0deg wrap
            fprintf('All NR, mod(360deg) corrected:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecIter),...
                    max(phaseVecIter),median(phaseVecIter),mean(phaseVecIter),std(phaseVecIter))
            phaseVecSel = reshape(permute(phaseMat(:,data.select,iterCnt),[2 1]),1,data.spec1.seriesN*data.selectN);
            fprintf('Selected NR:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecSel),...
                    max(phaseVecSel),median(phaseVecSel),mean(phaseVecSel),std(phaseVecSel))
            phaseVecSel = mod(phaseVecSel+180,360)-180;         % 180deg shift to move away from the 0deg wrap
            fprintf('Selected NR, mod(360deg) corrected:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phaseVecSel),...
                    max(phaseVecSel),median(phaseVecSel),mean(phaseVecSel),std(phaseVecSel))
        end
    end
    
    %--- total ---
    fprintf('\nCOMBINED PHASE ALIGNMENT (all iterations):\n');
    phaseMat = mod(phaseMat+180,360)-180;
    if flag.dataAllSelect           % all NR
        % total, edit ON
        phVecON  = reshape(permute(sum(phaseMat(:,1:2:end,:),3),[2 1]),1,data.spec1.seriesN*size(phaseMat(:,1:2:end,:),2));
        fprintf('All NR (ON):\n%s deg\n',SP2_Vec2PrintStr(phVecON));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phVecON),...
                max(phVecON),median(phVecON),mean(phVecON),std(phVecON))
        % total, edit OFF
        phVecOFF = reshape(permute(sum(phaseMat(:,2:2:end,:),3),[2 1]),1,data.spec1.seriesN*size(phaseMat(:,2:2:end,:),2));
        fprintf('\nAll NR (OFF):\n%s deg\n',SP2_Vec2PrintStr(phVecOFF));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phVecOFF),...
                max(phVecOFF),median(phVecOFF),mean(phVecOFF),std(phVecOFF))
        % total, complete
        phVec = reshape(permute(sum(phaseMat,3),[2 1]),1,data.spec1.seriesN*data.spec1.nr);
        fprintf('\nAll NR (complete):\n%s deg\n',SP2_Vec2PrintStr(phVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',min(phVec),...
                max(phVec),median(phVec),mean(phVec),std(phVec))
    else                            % selected NR
        % selected, edit ON
        phVecON  = reshape(permute(sum(phaseMat(:,data.select(1:2:end),:),3),[2 1]),1,data.spec1.seriesN*length(data.select(1:2:end)));
        fprintf('Selected NR (ON):\n%s deg\n',SP2_Vec2PrintStr(phVecON));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(phVecON),...
                max(phVecON),median(phVecON),mean(phVecON),std(phVecON))
        % selected, edit OFF
        phVecOFF = reshape(permute(sum(phaseMat(:,data.select(2:2:end),:),3),[2 1]),1,data.spec1.seriesN*length(data.select(2:2:end)));
        fprintf('\nSelected NR (OFF):\n%s deg\n',SP2_Vec2PrintStr(phVecOFF));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(phVecOFF),...
                max(phVecOFF),median(phVecOFF),mean(phVecOFF),std(phVecOFF))
        % selected, complete
        phVec = reshape(permute(sum(phaseMat(:,data.select,:),3),[2 1]),1,data.spec1.seriesN*data.selectN);
        fprintf('\nSelected NR (complete):\n%s deg\n',SP2_Vec2PrintStr(phVec));
        fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',min(phVec),...
                max(phVec),median(phVec),mean(phVec),std(phVec))
    end 
end
if flag.dataAlignAmpl
    fprintf('\nAMPLITUDE CORRECTION:\n');
    for seriesCnt = 1:data.spec1.seriesN
        fprintf('Scan #%i (%i of %i), edit ON:\n%s Hz\n',...
                data.spec1.seriesVec(seriesCnt),...
                seriesCnt,data.spec1.seriesN,...
                SP2_Vec2PrintStr(amplMat(seriesCnt,1:2:end),2))
        fprintf('Scan #%i (%i of %i), edit OFF:\n%s Hz\n',...
                data.spec1.seriesVec(seriesCnt),...
                seriesCnt,data.spec1.seriesN,...
                SP2_Vec2PrintStr(amplMat(seriesCnt,2:2:end),2))
    end
    amplVecTot = reshape(amplMat,1,data.spec1.seriesN*data.spec1.nr);
    fprintf('All NR:\nmin/max/median/mean/SD = %.2f/%.2f/%.2f/%.2f/%.2f\n',min(amplVecTot),...
            max(amplVecTot),median(amplVecTot),mean(amplVecTot),std(amplVecTot))
    amplVecSel = reshape(amplMat(:,data.select),1,data.spec1.seriesN*data.selectN);
    fprintf('Selected NR:\nmin/max/median/mean/SD = %.2f/%.2f/%.2f/%.2f/%.2f\n',min(amplVecSel),...
            max(amplVecSel),median(amplVecSel),mean(amplVecSel),std(amplVecSel))
end
    
%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update correction flag ---
flag.dataCorrAppl = 1;

%--- update success flag ---
f_succ = 1;



