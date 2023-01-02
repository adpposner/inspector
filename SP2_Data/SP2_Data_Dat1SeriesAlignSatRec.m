%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_Dat1SeriesAlignSatRec
%% 
%%  Phase and frequency alignment of saturation-recovery MRS experiment series.
%%
%%  data format:
%%  data.spec1.fidArr:       1) series, 2) nspecC, 3) rcvr, 4) phase cycl (nv), 5) sat. rec. delay
%%  data.spec1.fidArrRxComb: 1) series, 2) nspecC, 3) phase cycl (nv), 4) sat. rec. delay
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_Dat1SeriesAlignSatRec';


%--- init success flag ---
f_done = 0;

%--- consistency check: aligment methods ---
if ~flag.dataAlignPhase && ~flag.dataAlignFrequ
    fprintf('%s ->\nAt least one alignment target (phase, frequency) has to be selected.\nProgram aborted.\n',FCTNAME);
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
if ndims(data.spec1.fid)~=4
    fprintf('%s ->\nSpectral FID 1 must have 4 dimensions (spectral + receivers + phase cycle + sat-rec. delays),\n',FCTNAME);
    fprintf('but only %i dimensions found (%s). Program aborted.\n',ndims(data.spec1.fid),SP2_Vec2PrintStr(size(data.spec1.fid),0));
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
if ndims(data.spec2.fid)~=4
    fprintf('%s ->\nSpectral FID 2 must have 3 dimensions (spectral + receivers + sat-rec delays),\n',FCTNAME);
    fprintf('but %i dimensions found %s. Program aborted.\n',ndims(data.spec2.fid),SP2_Vec2PrintStr(size(data.spec2.fid),0));
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

%--- min. TI scan ---
% note that all indices refer to overall vector of TI delays
if ~SP2_Data_SatRecMinTiIndexCalc(1)
    return
end

%--- separate processing stream based on data dimension ---
% if data.spec1.nr>1      % here NR: phase cycle * sat-rec delays
amplMat  = zeros(data.spec1.seriesN,data.spec1.nv,data.spec1.nSatRec);                         % optimal amplitude scalings
phaseMat = zeros(data.spec1.seriesN,data.spec1.nv,data.spec1.nSatRec,data.phAlignIter);        % optimal phasings
frequMat = zeros(data.spec1.seriesN,data.spec1.nv,data.spec1.nSatRec,data.frAlignIter);        % optimal frequency corrections
for iterCnt = 1:max(data.phAlignIter,data.frAlignIter)
    %--- phase/ECC correction, Rx combination ---
    if iterCnt==1       
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
                            data.spec1.fidArr(seriesCnt,:,rCnt,nvCnt,srCnt) = squeeze(data.spec1.fidArr(seriesCnt,:,rCnt,nvCnt,srCnt)) .* exp(-1i*phaseCorr);
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
            data.spec1.fidArrRxComb = squeeze(sum(data.spec1.fidArr(:,:,data.rcvrInd,:,:).*weightMat(:,:,data.rcvrInd,:,:),3));

            %--- info printout ---
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec,3));
        else
            data.spec1.fidArrRxComb = squeeze(mean(data.spec1.fidArr(:,:,data.rcvrInd,:,:),3));

            %--- info printout ---
            fprintf('Non-weighted summation of Rx channels applied:\n');
        end
        fprintf('Receive cannels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));
    end
    
    %--- 1) frequency shift determination and alignment ---
    if flag.dataAlignFrequ && iterCnt<=data.frAlignIter
        %--- extract reference FID ---
        if iterCnt==1
            if data.frAlignRefFid>data.spec1.nr
                fprintf('%s ->\nThe reference FID must be within the first experiment series, i.e. <=NR.\nProgram aborted\n',FCTNAME);
                return
            end
            refFid = squeeze(data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(1),:));
        else
            refFid = squeeze(mean(mean(data.spec1.fidArrRxComb,3),1));
        end
        SP2_Data_AutoFrequDetPrep(data.spec1)
        totCnt = 0;         % overall counter
        for seriesCnt = 1:data.spec1.seriesN
            for srCnt = 1:data.spec1.nSatRec
                for nvCnt = 1:data.spec1.nv
                    %--- overall counter ---
                    totCnt = totCnt + 1;
                    
                    %--- info string ---
                    infoStr = sprintf('Series %.0f, SatRec %.0f, nv %.0f',seriesCnt,srCnt,nvCnt);
                    
                    %--- shift determination ---
                    if srCnt<3 && seriesCnt==1 && nvCnt<2           % verbose only for the first 2 FIDs per SR delay
                        % [frequMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',refFid(:,data.satRec.indexMinTI(srCnt)),data.spec1,flag.dataAlignVerbose);
                        [frequMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',refFid(:,data.satRec.indexMinTI(srCnt)),data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                        if ~f_succ
                            fprintf('%s ->\nAutomated frequency determination failed for FID #i (scan %i).\n',...
                                    FCTNAME,seriesCnt,data.spec1.seriesVec(seriesCnt))
                            return
                        end
                    else                                            % no display for nrCnt>10 (independent of verbose setting)
                        % [frequMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',refFid(:,data.satRec.indexMinTI(srCnt)),data.spec1,0);
                        [frequMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoFrequDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',refFid(:,data.satRec.indexMinTI(srCnt)),data.spec1,data.frAlignPpm1Min,data.frAlignPpm1Max,infoStr,0);
                        if ~f_succ
                            fprintf('%s ->\nAutomated frequency determination failed for FID #i (scan %i).\n',...
                                    FCTNAME,seriesCnt,data.spec1.seriesVec(seriesCnt))
                            return
                        end
                    end

                    %--- frequency correction ---
                    % 1 frequency for all receivers of the same FID
                    phPerPt = frequMat(seriesCnt,nvCnt,srCnt,iterCnt)*data.spec1.dwell*data.spec1.nspecC*(pi/180)/(2*pi);    % corr phase per point
                    data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt) = exp(-1i*phPerPt*(0:data.spec1.nspecC-1)) .* ...
                                                                       squeeze(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt));    

                    %--- info printout ---
                    if ~mod(totCnt,10)
                        fprintf('Frequency alignment #%i of %i done (iter %i, scan %i, NR %i)\n',totCnt,...
                                data.spec1.nr*data.spec1.seriesN,iterCnt,data.spec1.seriesVec(seriesCnt),...
                                mod(totCnt-1,data.spec1.nr)+1)
                    end
                end
            end
        end
    end

    %--- 2) phase determination and alignment ---
    if flag.dataAlignPhase && iterCnt<=data.phAlignIter
        %--- extract reference FID ---
        if iterCnt==1
            if data.phAlignRefFid>data.spec1.nr
                fprintf('%s ->\nThe reference FID must be within the first experiment series, i.e. <=NR.\nProgram aborted\n',FCTNAME);
                return
            end
            refFid = squeeze(data.spec1.fidArrRxComb(1,:,data.phAlignRefFid(1),:));
        else
            refFid = squeeze(mean(mean(data.spec1.fidArrRxComb,3),1));
        end
        totCnt = 0;         % overall counter
        for seriesCnt = 1:data.spec1.seriesN
            for srCnt = 1:data.spec1.nSatRec
                for nvCnt = 1:data.spec1.nv
                    %--- overall counter ---
                    totCnt = totCnt + 1;
                    
                    %--- info string ---
                    infoStr = sprintf('Series %.0f, SatRec %.0f, nv %.0f',seriesCnt,srCnt,nvCnt);
                    
                    %--- phase determination ---
                    if srCnt<3 && seriesCnt==1 && nvCnt<2              % verbose only for the first 2 FIDs per SR delay
                        % [phaseMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',data.spec1,flag.dataAlignVerbose,refFid(:,data.satRec.indexMinTI(srCnt)));
                        [phaseMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',refFid(:,data.satRec.indexMinTI(srCnt)),data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,infoStr,flag.dataAlignVerbose);
                        if ~f_succ
                            fprintf('%s ->\nAutomated phase determination failed for FID #i (scan %i).\n',...
                                    FCTNAME,seriesCnt,data.spec1.seriesVec(seriesCnt))
                            return
                        end
                    else                    % no display for nrCnt>2 (independent of verbose setting)
                        % [phaseMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',data.spec1,0,refFid(:,data.satRec.indexMinTI(srCnt)));
                        [phaseMat(seriesCnt,nvCnt,srCnt,iterCnt),f_succ] = SP2_Data_AutoPhaseDet(conj(data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt))',refFid(:,data.satRec.indexMinTI(srCnt)),data.spec1,data.phAlignPpm1Min,data.phAlignPpm1Max,infoStr,0);
                        if ~f_succ
                            fprintf('%s ->\nAutomated phase determination failed for FID #i (scan %i).\n',...
                                    FCTNAME,seriesCnt,data.spec1.seriesVec(seriesCnt))
                            return
                        end
                    end

                    %--- apply (relative) phase alignment ---
                    % 1 phase for all receivers of the same FID
                    data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt) = exp(1i*phaseMat(seriesCnt,nvCnt,srCnt,iterCnt)*pi/180) * ...
                                                                       data.spec1.fidArrRxComb(seriesCnt,:,nvCnt,srCnt);

                    %--- info printout ---
                    if ~mod(totCnt,10)
                        fprintf('Phase alignment #%i of %i done (iter %i, scan %i, NR %i)\n',totCnt,...
                                data.spec1.nr*data.spec1.seriesN,iterCnt,data.spec1.seriesVec(seriesCnt),...
                                mod(totCnt-1,data.spec1.nr)+1)
                    end
                end
            end
        end
    end
end

%--- 3) amplitude determination and correction ---
if flag.dataAlignAmpl
    lbProc    = 3;     % 3 Hz line broadening to reduce dependency on late data points
    lbWeight  = exp(-lbProc*data.spec1.dwell*(0:data.spec1.nspecC-1)*pi);
    refFid    = squeeze(data.spec1.fidArrRxComb(1,:,data.frAlignRefFid(1)));
    refSpec   = fftshift(fft(refFid.*lbWeight,[],2),2);
    % note that the reversed spectral order
    [minI,maxI,ppmZoom,refSpecZoom,f_succ] = SP2_Data_ExtractPpmRange(data.frAlignPpmMin,data.frAlignPpmMax,...
                                                                      data.ppmCalib,data.spec1.sw,abs(rot90(refSpec)));
    maxAbsRef = max(abs(refSpec(minI:maxI)));
    for seriesCnt = 1:data.spec1.seriesN
        for nrCnt = 1:data.spec1.nr
            specTmp   = fftshift(fft(squeeze(data.spec1.fidArrRxComb(seriesCnt,:,nrCnt)).*lbWeight,[],2),2);
            maxAbsTmp = max(abs(specTmp(minI:maxI)));
%                     fprintf('ratio %.2f\n',maxAbsRef/maxAbsTmp);
            amplMat(seriesCnt,nrCnt) = maxAbsRef/maxAbsTmp;
            data.spec1.fidArrRxComb(seriesCnt,:,nrCnt) = amplMat(seriesCnt,nrCnt) * data.spec1.fidArrRxComb(seriesCnt,:,nrCnt);

            %--- info printout ---
            currNum = nrCnt+(seriesCnt-1)*data.spec1.nr;
            if mod(currNum,10)==0 || currNum==data.spec1.nr*data.spec1.seriesN
                fprintf('Amplitude alignment #%i of %i done (scan %i, NR %i)\n',currNum,...
                        data.spec1.nr*data.spec1.seriesN,data.spec1.seriesVec(seriesCnt),nrCnt)
            end
        end
    end
end

%--- info printout ---
if flag.dataAlignFrequ
    for iterCnt = 1:data.frAlignIter
        fprintf('\nFREQUENCY ALIGNMENT (iteration %i):\n',iterCnt);
        for seriesCnt = 1:data.spec1.seriesN
            %--- detailed display ---
            fprintf('Scan #%i (%i of %i):\n',...
                    data.spec1.seriesVec(seriesCnt),seriesCnt,data.spec1.seriesN)
            for srCnt = 1:data.spec1.nSatRec
                %--- saturation-delay-specific ---
                fprintf('Delay %.0f (%.3f ms): %s Hz\n',...
                        srCnt,data.spec1.inv.ti{srCnt},...
                        SP2_Vec2PrintStr(frequMat(seriesCnt,:,srCnt,iterCnt),2))
        
                frequVec = frequMat(seriesCnt,:,srCnt,iterCnt);
                fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',...
                        min(frequVec),max(frequVec),median(frequVec),...
                        mean(frequVec),std(frequVec))
            end
            fprintf('\n');
        end
    end
    
    %--- iteration-combined statistics ---
    frequMatTmp  = squeeze(mean(mean(frequMat,1),2));
    for iterCnt = 1:data.frAlignIter
        frequVec = frequMatTmp(:,iterCnt);
        fprintf('Iteration %.0f, overall:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f Hz\n',...
                iterCnt,min(frequVec),max(frequVec),median(frequVec),...
                mean(frequVec),std(frequVec))
    end
end
if flag.dataAlignPhase
    for iterCnt = 1:data.phAlignIter
        fprintf('\nPHASE ALIGNMENT (iteration %i):\n',iterCnt);
        for seriesCnt = 1:data.spec1.seriesN
            %--- detailed display ---
            fprintf('Scan #%i (%i of %i):\n',...
                    data.spec1.seriesVec(seriesCnt),seriesCnt,data.spec1.seriesN)
            for srCnt = 1:data.spec1.nSatRec
                %--- saturation-delay-specific ---
                fprintf('Delay %.0f (%.3f ms): %s deg\n',...
                        srCnt,data.spec1.inv.ti{srCnt},...
                        SP2_Vec2PrintStr(phaseMat(seriesCnt,:,srCnt,iterCnt)))
                    
                phaseVec = phaseMat(seriesCnt,:,srCnt,iterCnt);
                fprintf('min/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',...
                        min(phaseVec),max(phaseVec),median(phaseVec),...
                        mean(phaseVec),std(phaseVec))
            end
            fprintf('\n');
        end
    end
    
    %--- iteration-combined statistics ---
    phaseMatTmp = mod(phaseMat+180,360)-180;    % 180 deg shift to move away from 0 deg wrap
    phaseMatTmp = squeeze(mean(mean(phaseMatTmp,1),2));
    for iterCnt = 1:data.phAlignIter
        phaseVec = phaseMatTmp(:,iterCnt);
        fprintf('Iteration %.0f, overall:\nmin/max/median/mean/SD = %.1f/%.1f/%.1f/%.1f/%.1f deg\n',...
                iterCnt,min(phaseVec),max(phaseVec),median(phaseVec),...
                mean(phaseVec),std(phaseVec))
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
    amplVec = reshape(amplMat,1,data.spec1.seriesN*data.spec1.nr);
    fprintf('Total min/max/median/mean/SD = %.2f/%.2f/%.2f/%.2f/%.2f\n',min(amplVec),...
            max(amplVec),median(amplVec),mean(amplVec),std(amplVec))
end

%--- data reformating ---
% 
% series,nspecC,phaseCyc,nSatRec -> series,nspecC,nr (=nv*nSatRec)
% the order within nr is sat-rec delays (inner loop) then nv
% (outer loop) -> FID is a good choice as initial reference
% fidArrRxCombTmp1 = permute(data.spec1.fidArrRxComb,[4 3 1 2]);
% fidArrRxCombTmp2 = reshape(fidArrRxCombTmp1,data.spec1.nr,data.spec1.seriesN,data.spec1.nspecC);
% data.spec1.fidArrRxComb = permute(fidArrRxCombTmp2,[2 3 1]);

% series,nspecC,phaseCyc,nSatRec -> series,nspecC,nr (=nv*nSatRec)
% the order within nr is sat-rec delays (inner loop) then nv
% (outer loop) -> FID is a good choice as initial reference
fidArrRxCombTmp1 = permute(data.spec1.fidArrRxComb,[4 3 1 2]);
fidArrRxCombTmp2 = reshape(fidArrRxCombTmp1,data.spec1.nr,data.spec1.seriesN,data.spec1.nspecC);
data.spec1.fidArrRxComb = permute(fidArrRxCombTmp2,[2 3 1]);



%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update correction flag ---
flag.dataCorrAppl = 1;

%--- update success flag ---
f_done = 1;



