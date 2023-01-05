%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_DoSumRcvrsStability
%% 
%%  Summation of (selected) receivers for stability series.
%%
%%  06-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_DoSumRcvrsStability';


%--- init success flag ---
f_done = 0;

%--- consistency checks ---
if length(size(data.spec1.fid))<3
    fprintf('%s -> Data set dimension is too small.\nThis is not a stability experiment or might have been summed already.\n',FCTNAME);
    return
end
if flag.dataRcvrWeight          % weighted summation
    %-- data data existence ---
    if ~isfield(data.spec2,'fid')
        fprintf('%s ->\nData of spectrum 2 does not exist. Load first for weighted summation.\n',FCTNAME);
        return
    end
    
    %--- check data format ---
    if length(size(data.spec2.fid))~=2
        fprintf('%s -> Data set dimension of reference is too small/large.\nThis is not a stability experiment or might have been summed already.\n',FCTNAME);
        return
    end
end

%--- basic receiver-specific global phase correction (with itself) ---
phaseVec  = mean(angle(data.spec1.fid(1:3,data.rcvrInd,1)));        % first three points of first FID
phaseMat  = repmat(phaseVec,[data.spec1.nspecC 1 data.spec1.nr]);
data.spec1.fid(:,data.rcvrInd,:) = data.spec1.fid(:,data.rcvrInd,:) .* exp(-1i*phaseMat);

%--- Rx summation ---
if flag.dataRcvrWeight
    weightVec  = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1)));
    weightVec  = weightVec/sum(weightVec);
    weightMat  = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);
    data.spec1.fid = squeeze(sum(data.spec1.fid(:,data.rcvrInd,:).*weightMat,2));
    
    %--- info printout ---
    fprintf('Amplitude-weighted summation of Rx channels applied:\n');
    fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
else
    data.spec1.fid = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:),2));

    %--- info printout ---
    fprintf('Non-weighted summation of Rx channels applied:\n');
end
fprintf('Receive cannels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));

%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update success flag ---
f_done = 1;

