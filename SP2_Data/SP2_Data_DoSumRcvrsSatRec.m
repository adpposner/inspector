%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_DoSumRcvrsSatRec
%% 
%%  Separation and summation of interleaved (e.g.) JDE spectra from multiple
%%  receivers.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_DoSumRcvrsSatRec';


%--- init success flag ---
f_done = 0;

%--- consistency checks ---
if ~flag.dataAllSelect && any(data.select>data.spec1.nr)
    fprintf('%s ->\nSelected FID range exceeds number of repetitions (NR=%.0f).\n',...
            FCTNAME,data.spec1.nr)
    return
end
if length(size(data.spec1.fid))<4
    fprintf('%s -> Data set dimension is too small.\nThis is not a saturation-recovery experiment or might have been summed already.\n',FCTNAME);
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
    if length(data.spec2.fid)==3
        weightVec  = mean(abs(data.spec2.fid(1:5,data.rcvrInd,2)));
        % note that the 2nd sat-recovery scan is used here due to the resorting
    else    
        weightVec  = mean(abs(data.spec2.fid(1:5,data.rcvrInd,1,2)));
        % note that the 2nd sat-recovery scan is used here due to the resorting
    end
    weightVec      = weightVec/sum(weightVec);
    weightMat      = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nv data.spec1.nSatRec]);
    data.spec1.fid = squeeze(sum(data.spec1.fid(:,data.rcvrInd,:,:).*weightMat,2));
    
    %--- info printout ---
    fprintf('Amplitude-weighted summation of Rx channels applied:\n');
    fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
else
    data.spec1.fid = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:),2));

    %--- info printout ---
    fprintf('Non-weighted summation of Rx channels applied:\n');
end
fprintf('Receive cannels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));


% %--- phase cycle summation ---
% if flag.dataAllSelect           % all sat-rec. delays
%     %--- data summation ---
%     data.spec1.fid = mean(data.spec1.fid,2);
% 
%     %--- info printout ---
%     fprintf('All phase cycle steps summed, i.e. no selection applied\n');
% else                            % selected sat-rec. range
%     %--- data summation ---
%     data.spec1.fid = mean(data.spec1.fid(:,data.select,:),2);
% 
%     %--- info printout ---
%     fprintf('Selection of phase cycle steps:\n%s\n',SP2_Vec2PrintStr(data.select,0));
% end

%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update success flag ---
f_done = 1;


end
