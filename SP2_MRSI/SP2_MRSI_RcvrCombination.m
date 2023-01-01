%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datStruct,f_succ] = SP2_MRSI_RcvrCombination(datStruct)
%%
%%  Combination of multi-receive channels.
%%
%%  05-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global data mrsi flag
    
FCTNAME = 'SP2_MRSI_RcvrCombination';


%--- init success flag ---
f_succ = 0;

%--- check data existence ---
if ~isfield(datStruct,'fidimg')
    fprintf('%s ->\nNo FID image of data set 1 found. Program aborted.\',FCTNAME)
    return
end
if flag.dataRcvrWeight          % weighted summation
    if ~isfield(mrsi.ref,'fidimg')
        fprintf('%s ->\nNo reference FID image found. Program aborted.\',FCTNAME)
        return
    end
end

%--- Rx summation ---
if flag.dataRcvrWeight      % weighted summation
    weightMat = mean(abs(mrsi.ref.fidimg(1:5,:,:,data.rcvrInd,1)));
    weightMat = weightMat/max(max(max(weightMat)));
    weightMat = repmat(weightMat,[datStruct.nspecC 1]);
    datStruct.fidimg = sum(datStruct.fidimg(:,:,:,data.rcvrInd).*weightMat,4);
else
    datStruct.fidimg = squeeze(sum(datStruct.fidimg(:,:,:,data.rcvrInd),4));
end

%--- info printout ---
if flag.dataRcvrWeight
    fprintf('Weighted combination of receive channels applied (%s).\n',datStruct.name)
else
    fprintf('Combination of receive channels applied (%s).\n',datStruct.name)
end

%--- update success flag ---
f_succ = 1;
