%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function f_done = SP2_Data_DoSumRcvrsT1T2
%% 
%%  Separation and summation of interleaved (e.g.) T1/T2 spectra from
%%  multiple receivers.
%%
%%  02-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag data

FCTNAME = 'SP2_Data_DoSumRcvrsT1T2';


%--- init success flag ---
f_done = 0;

%--- consistency checks ---
if ~flag.dataAllSelect && any(data.select>data.spec1.nr)
    fprintf('%s ->\nSelected FID range exceeds number of repetitions (NR=%.0f).\n',...
            FCTNAME,data.spec1.nr)
    return
end
if length(size(data.spec1.fid))<3
    fprintf('%s -> Data set dimension is too small.\nThis is not a T1/T2 experiment or might have been summed already.\n',FCTNAME);
    return
end
if length(size(data.spec1.fid))>3
    fprintf('%s -> Data set dimension is too large.\nThis is not a T1/T2 experiment.\n',FCTNAME);
    return
end

%--- Rx summation ---
if flag.dataRcvrWeight
    % note that here the data set itself is used to determine the weighting factors
    weightVec      = mean(abs(data.spec1.fid(1:5,data.rcvrInd,1)));
    % note that the 2nd sat-recovery scan is used here due to the resorting
    weightVec      = weightVec/sum(weightVec);

    %--- all NR vs. selected NR range ---
    if data.spec1.t2Series          % T2 series
        if flag.dataAllSelect
            weightMat         = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:).*weightMat,2));
            data.spec1.teUsed = data.spec1.te + data.spec1.t2TeExtra;
            fprintf('Summation of all NR applied\n');
        else
            weightMat         = repmat(weightVec,[data.spec1.nspecC 1 data.selectN]);
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,data.select).*weightMat,2));
            data.spec1.teUsed = data.spec1.te + data.spec1.t2TeExtra(data.select);
            fprintf('Summation of selected NR range applied: %s (%.0f out of %.0f)\n',...
                    data.selectStr,data.selectN,data.spec1.nr)
        end
    else
        if flag.dataAllSelect
            weightMat         = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:).*weightMat,2));
            data.spec1.teUsed = data.spec1.te;
            fprintf('Summation of all NR applied\n');
        else
            weightMat         = repmat(weightVec,[data.spec1.nspecC 1 data.selectN]);
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,data.select).*weightMat,2));
            data.spec1.teUsed = data.spec1.te(data.select);
            fprintf('Summation of selected NR range applied: %s (%.0f out of %.0f)\n',...
                    data.selectStr,data.selectN,data.spec1.nr)
        end
    end
    
    %--- info printout ---
    fprintf('Amplitude-weighted summation of Rx channels applied:\n');
    fprintf('Rel. scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
else
    %--- all NR vs. selected NR range ---
    if data.spec1.t2Series          % T2 series
        if flag.dataAllSelect
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:),2));
            data.spec1.teUsed = data.spec1.te + data.spec1.t2TeExtra;
            fprintf('Summation of all NR applied\n');
        else
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,data.select),2));
            data.spec1.teUsed = data.spec1.te + data.spec1.t2TeExtra(data.select);
            fprintf('Summation of selected NR range applied: %s (%.0f out of %.0f)\n',...
                    data.selectStr,data.selectN,data.spec1.nr)
        end
    else
        if flag.dataAllSelect
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:),2));
            data.spec1.teUsed = data.spec1.te;
            fprintf('Summation of all NR applied\n');
        else
            data.spec1.fid    = squeeze(mean(data.spec1.fid(:,data.rcvrInd,data.select),2));
            data.spec1.teUsed = data.spec1.te(data.select);
            fprintf('Summation of selected NR range applied: %s (%.0f out of %.0f)\n',...
                    data.selectStr,data.selectN,data.spec1.nr)
        end
    end
    
    %--- info printout ---
    fprintf('Non-weighted summation of Rx channels applied:\n');
end
fprintf('Receive cannels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));


% %--- phase cycle summation ---
% if flag.dataAllSelect           % all T1/T2 delays
%     %--- data summation ---
%     data.spec1.fid = mean(data.spec1.fid,2);
% 
%     %--- info printout ---
%     fprintf('All delays phase cycle steps summed, i.e. no selection applied\n');
% else                            % selected sat-rec. range
%     %--- data summation ---
%     data.spec1.fid = mean(data.spec1.fid(:,data.select,:),2);
% 
%     %--- info printout ---
%     fprintf('Selection of phase cycle steps:\n%s\n',SP2_Vec2PrintStr(data.select,0));
% end


%% backup before NR selction was added
% %--- Rx summation ---
% if flag.dataRcvrWeight
%     % note that here the data set itself is used to determine the weighting factors
%     weightVec      = mean(abs(data.spec1.fid(1:5,data.rcvrInd,1)));
%     % note that the 2nd sat-recovery scan is used here due to the resorting
%     weightVec      = weightVec/sum(weightVec);
%     weightMat      = repmat(weightVec,[data.spec1.nspecC 1 data.spec1.nr]);
%     data.spec1.fid = squeeze(sum(data.spec1.fid(:,data.rcvrInd,:).*weightMat,2));
%     
%     %--- info printout ---
%     fprintf('Amplitude-weighted summation of Rx channels applied:\n');
%     fprintf('Scaling: %s\n',SP2_Vec2PrintStr(weightVec/max(weightVec),3));
% else
%     data.spec1.fid = squeeze(mean(data.spec1.fid(:,data.rcvrInd,:),2));
% 
%     %--- info printout ---
%     fprintf('Non-weighted summation of Rx channels applied:\n');
% end
% fprintf('Receive cannels: %s\n',SP2_Vec2PrintStr(data.rcvrInd,0));


%--- info printout ---
fprintf('%s done.\n',FCTNAME);

%--- update success flag ---
f_done = 1;


end
