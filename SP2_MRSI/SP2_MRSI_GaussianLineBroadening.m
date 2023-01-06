%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_done] = SP2_MRSI_GaussianLineBroadening(datStruct)
%%
%%  Gaussian apodization.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_MRSI_GaussianLineBroadening';


%--- init success flag ---
f_done = 0;

%--- consistency check ---
if ~SP2_Check4ColVec(datStruct.fid)
    return
end

%--- generation of weighting function ---
gbWeight = exp(-datStruct.gb*(datStruct.dwell*(0:datStruct.nspecC-1)*pi).^2)';
% gbWeight = exp(-pi^2/(4*log(2)) * datStruct.gb^2 * (datStruct.dwell*(0:datStruct.nspecC-1)).^2)';

%--- line broadening --------------------
datFid = datStruct.fid .* gbWeight;

%--- update success flag ---
f_done = 1;

end
