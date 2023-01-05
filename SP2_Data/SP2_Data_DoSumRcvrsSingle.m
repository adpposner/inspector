%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_succ = SP2_Data_DoSumRcvrsSingle
%% 
%%  (Weighted) combination of multi-receiver spectra.
%%
%%  04-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_DoSumRcvrsSingle';


%--- init success flag ---
f_succ = 0;

%--- consistency checks ---
if ~flag.dataAllSelect && any(data.select>data.spec1.nr)
    fprintf('%s ->\nSelected FID range exceeds number of repetitions (NR=%.0f).\n',...
            FCTNAME,data.spec1.nr)
    return
end
if length(size(data.spec1.fid))==2 && any(size(data.spec1.fid)==1)      % dim 2 and singleton dimension
    fprintf('%s -> WARNING:\n',FCTNAME);
    fprintf('Data set dimension is too small.\nThis is not a multi-receiver experiment or might have been summed already.\n');
    % f_succ = 1;
    return
end
if flag.dataRcvrWeight          % weighted summation
    if ~isfield(data.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load first for weighted summation.\n',FCTNAME);
        return
    end
    if length(size(data.spec1.fid))==2 && any(size(data.spec1.fid)==1)     % dim 2 and singleton dimension
        fprintf('%s -> Data set dimension is too small.\nThis is not a multi-receiver experiment or might have been summed already.\n',FCTNAME);
        return
    end
end

%--- FID summation ---
if flag.dataAllSelect           % all FIDs (NR)
    if flag.dataRcvrWeight      % weighted summation
        if length(size(data.spec2.fid))==3
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
        else
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
        end
        weightVec      = weightVec/sum(weightVec);
        weightMat      = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);
        if data.spec1.nr==1             % single repetition
            data.spec1.fid = sum(data.spec1.fid(:,data.rcvrInd).*weightMat,2);
        else                            % NR>1
            data.spec1.fid = sum(mean(data.spec1.fid(:,data.rcvrInd,:).*weightMat,3),2);
        end
        
        %--- info printout ---
        if data.rcvrN>1
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        end
    else
        data.spec1.fid = mean(mean(data.spec1.fid(:,data.rcvrInd,:),3),2);

        %--- info printout ---
        fprintf('Non-weighted summation of Rx channels applied:\n');
    end
else                            % selected FID range
    if flag.dataRcvrWeight      % weighted summation
        if length(size(data.spec2.fid))==3
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
        else
            weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
        end
        weightVec      = weightVec/sum(weightVec);
        weightMat      = repmat(weightVec,[data.spec1.nspecC 1 length(data.select)]);
        data.spec1.fid = sum(mean(data.spec1.fid(:,data.rcvrInd,data.select).*weightMat,3),2);
        
        %--- info printout ---
        if data.rcvrN>1
            fprintf('Amplitude-weighted summation of Rx channels applied:\n');
            fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
        end
    else
        data.spec1.fid = mean(mean(data.spec1.fid(:,data.rcvrInd,data.select),3),2);

        %--- info printout ---
        fprintf('Non-weighted summation of Rx channels applied:\n');
    end
end

%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update success flag ---
f_succ = 1;

