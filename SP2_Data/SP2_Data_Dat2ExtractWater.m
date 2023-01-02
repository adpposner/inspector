%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_Dat2ExtractWater
%% 
%%  Extract water reference from combined water + metabolite data set.
%%
%%  08-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile data flag

FCTNAME = 'SP2_Data_Dat2ExtractWater';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(data,'spec1')
    fprintf('%s ->\nSpectral data series 1 does not exist. Load first.\n',FCTNAME);
    return
% elseif ~isfield(data.spec1,'fidArr')
%     fprintf('%s ->\nSpectral FID series 1 does not exist. Load first.\n',FCTNAME);
%     return
end
if ~isfield(data.spec1,'fid')
    fprintf('%s ->\nSpectral data series 1 does not exist. Load first.\n',FCTNAME);
    return
end

%--- consistency checks ---
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

%--- check for identical data sets 1 and 2 ---
if ~strcmp(data.spec1.fidFile,data.spec2.fidFile)
    fprintf('%s ->\nThis kind of water extraction expects identical data sets assigned to both data sets 1 and 2.\n',FCTNAME);
    return
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
    
    %--- apply correction (to water) ---
    for rCnt = 1:data.spec2.nRcvrs
        % extract correction phase from first FID
        phaseCorr = angle(data.spec2.fid(:,rCnt,1));
        phaseVec = exp(-1i*phaseCorr');
        % applied to last FID
        data.spec2.fid(:,rCnt,data.spec2.nr) = squeeze(data.spec2.fid(:,rCnt,data.spec2.nr)) .* phaseVec.';
    end
    
    %--- FID summation ---
    if flag.dataRcvrWeight      % weighted summation
        if length(size(data.spec2.fid))==3
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
        else
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
        end
        weightVec      = weightVec/sum(weightVec);
        weightMat      = repmat(weightVec,[data.spec2.nspecC 1]);
        % note the water-to-metab transfer (spec2 to spec1) along with the
        % NR selection (last one)
        data.spec1.fid = sum(data.spec2.fid(:,data.rcvrInd,data.spec2.nr).*weightMat,2);
        
        %--- info printout ---
        if data.rcvrN>1
            fprintf('Amplitude-weighted summation of Rx channels applied (water):\n');
            fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        end
    else
        data.spec1.fid = mean(data.spec2.fid(:,data.rcvrInd,data.spec2.nr),2);

        %--- info printout ---
        fprintf('Non-weighted summation of Rx channels applied:\n');
    end
    
    %--- info printout ---
    fprintf('%s done for regular MRS data.\n',FCTNAME);
elseif flag.dataExpType==2              % saturation-recovery experiment
    fprintf('%s does not support saturation-recovery experiments.\n',FCTNAME);
    fprintf('Program aborted.\n\n');
    return

elseif flag.dataExpType==3              % JDE
    
    %--- apply correction (to water) ---
    for rCnt = 1:data.spec2.nRcvrs
        % extract correction phase from first FID
        phaseCorr = angle(data.spec2.fid(:,rCnt,1));
        phaseVec = exp(-1i*phaseCorr');
        % applied to last FID
        data.spec2.fid(:,rCnt,data.spec2.nr) = squeeze(data.spec2.fid(:,rCnt,data.spec2.nr)) .* phaseVec.';
    end
    
    %--- FID summation ---
    if flag.dataRcvrWeight      % weighted summation
        if length(size(data.spec2.fid))==3
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
        else
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
        end
        weightVec      = weightVec/sum(weightVec);
        weightMat      = repmat(weightVec,[data.spec2.nspecC 1]);
        % note the water-to-metab transfer (spec2 to spec1) along with the
        % NR selection (last one)
        data.spec1.fid = sum(data.spec2.fid(:,data.rcvrInd,data.spec2.nr).*weightMat,2);
        
        %--- info printout ---
        if data.rcvrN>1
            fprintf('Amplitude-weighted summation of Rx channels applied (water):\n');
            fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        end
    else
        data.spec1.fid = mean(data.spec2.fid(:,data.rcvrInd,data.spec2.nr),2);

        %--- info printout ---
        fprintf('Non-weighted summation of Rx channels applied:\n');
    end
    
    %--- info printout ---
    fprintf('%s done with JDE sorting.\n',FCTNAME);
elseif flag.dataExpType==4
    fprintf('%s does not support stability experiments.\n',FCTNAME);
    fprintf('Program aborted.\n\n');
    return
elseif flag.dataExpType==5
    fprintf('%s does not support T1/T2 experiments.\n',FCTNAME);
    fprintf('Program aborted.\n\n');
    return
elseif flag.dataExpType==6
    fprintf('%s does not support MRSI experiments.\n',FCTNAME);
    fprintf('Program aborted.\n\n');
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
