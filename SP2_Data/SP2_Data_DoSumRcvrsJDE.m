%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_DoSumRcvrsJDE
%% 
%%  Separation and summation of interleaved (e.g.) JDE spectra from multiple
%%  receivers.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_DoSumRcvrsJDE';


%--- init success flag ---
f_succ = 0;

%--- consistency checks ---
if ~flag.dataAllSelect && any(data.select>data.spec1.nr)
    fprintf('%s ->\nSelected FID range exceeds number of repetitions (NR=%.0f).\n',...
            FCTNAME,data.spec1.nr)
    return
end
if length(size(data.spec1.fid))<3
    fprintf('%s -> Data set dimension is too small.\nThis is not a JDE experiment or might have been summed already.\n',FCTNAME);
    return
end
if flag.dataRcvrWeight          % weighted summation
    if ~isfield(data.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load first for weighted summation.\n',FCTNAME);
        return
    end
end

%--- Rx summation ---
if flag.dataRcvrWeight
    if length(size(data.spec2.fid))==3
        weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
    else
        weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
    end
    weightVec      = weightVec/sum(weightVec);
    weightMat      = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);
    data.spec1.fid = sum(data.spec1.fid(:,data.rcvrInd,:).*weightMat,2);

    %--- info printout ---
    fprintf('Amplitude-weighted summation of Rx channels applied:\n');
    fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
else
    data.spec1.fid = mean(data.spec1.fid(:,data.rcvrInd,:),2);

    %--- info printout ---
    fprintf('Non-weighted summation of Rx channels applied:\n');
end
fprintf('Channels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));


%--- FID summation ---
if flag.dataAllSelect           % all FIDs (NR)
    %--- data order: experiment series, FID, NR (with alternating edited/non-edited) ---
    data.spec2.fid = mean(data.spec1.fid(:,2:2:data.spec1.nr),2);
    data.spec1.fid = mean(data.spec1.fid(:,1:2:data.spec1.nr),2);

    %--- info printout ---
    fprintf('All FID''s summed, i.e. no selection applied\n');
else                            % selected FID range
    %--- spectrum 2, even NR (non-edited) ---
    indVecTot  = 2:2:data.spec1.nr;         % even repetition numbers
    indVecAppl = 0;                         % indices of selected even NR
    indCnt     = 0;                         % index counter
    for sCnt = 1:length(data.select)
        if any(data.select(sCnt)==indVecTot)
            indCnt = indCnt + 1;
            indVecAppl(indCnt) = indVecTot(data.select(sCnt)==indVecTot);
        end
    end
    data.spec2.fid = mean(data.spec1.fid(:,indVecAppl),2);
    
    %--- info printout ---
    fprintf('FID selection, non-edited (spec2):\n%s\n',SP2_Vec2PrintStr(indVecAppl,0));
    
    %--- spectrum 1, odd NR (edited) ---
    indVecTot  = 1:2:data.spec1.nr;         % odd repetition numbers
    indVecAppl = 0;                         % indices of selected even NR
    indCnt     = 0;                         % index counter
    for sCnt = 1:length(data.select)
        if any(data.select(sCnt)==indVecTot)
            indCnt = indCnt + 1;
            indVecAppl(indCnt) = indVecTot(data.select(sCnt)==indVecTot);
        end
    end
    data.spec1.fid = mean(data.spec1.fid(:,indVecAppl),2);
    
    %--- info printout ---
    fprintf('FID selection, edited (spec1):\n%s\n',SP2_Vec2PrintStr(indVecAppl,0));
end

%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update success flag ---
f_succ = 1;

