%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_succ] = SP2_Proc_GaussianLineBroadening(datStruct)
%%
%%  Gaussian apodization.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Proc_GaussianLineBroadening';


%--- init success flag ---
f_succ = 0;
datFid = datStruct.fid;         % init (in case of abort)

%--- consistency check ---
if ~SP2_Check4ColVec(datStruct.fid)
    return
end

%--- generation of weighting function ---
gbWeight = exp(-datStruct.gb*(datStruct.dwell*(0:datStruct.nspecC-1)*pi).^2)';       % until 06/2020
% gbWeight = exp(-pi^2/(4*log(2)) * datStruct.gb^2 * (datStruct.dwell*(0:datStruct.nspecC-1)).^2)';

%--- line broadening --------------------
datFid = datStruct.fid .* gbWeight;

%--- update success flag ---
f_succ = 1;
