%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_DoSumRcvrsMRSI
%% 
%%  (Weighted) combination of multi-receiver spectra.
%%
%%  04-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile flag data

FCTNAME = 'SP2_Data_DoSumRcvrsMRSI';


%--- init success flag ---
f_done = 0;

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
    if length(size(data.spec1.fid))<2
        fprintf('%s -> Data set dimension is too small.\nThis is not a multi-receiver experiment or might have been summed already.\n',FCTNAME);
        return
    end
end

% %--- FID summation ---
% % note: no NR selection is applied
% if flag.dataRcvrWeight      % weighted summation
%     if length(size(data.spec2.fid))==3
%         weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
%     else
%         weightVec = mean(abs(data.spec2.fid(1:5,data.rcvrInd)));
%     end
%     weightVec      = weightVec/sum(weightVec);
%     weightMat      = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);
%     data.spec1.fid = squeeze(sum(data.spec1.fid(:,data.rcvrInd,:).*weightMat,2));
% else
%     data.spec1.fid = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:),2));
% end


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
        data.spec1.fid = sum(data.spec1.fid(:,data.rcvrInd,:).*weightMat,2);
    else
        data.spec1.fid = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:),2));
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
        data.spec1.fid = sum(data.spec1.fid(:,data.rcvrInd,data.select).*weightMat,2);
    else
        data.spec1.fid = squeeze(mean(data.spec1.fid(:,data.rcvrInd,data.select),2));
    end
end

%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update success flag ---
f_done = 1;

