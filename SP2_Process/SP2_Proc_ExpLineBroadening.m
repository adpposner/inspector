%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [datFid, f_done] = SP2_Proc_ExpLineBroadening(datStruct)
%%
%%  Exponential line broadening.
%%  1st arg: FID
%%  2nd arg: exponential/Lorentzian linebroadening [Hz]
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_Proc_ExpLineBroadening';


%--- init success flag ---
f_done = 0;
datFid = datStruct.fid;             % init (in case of abort)

%--- consistency check ---
if ~SP2_Check4ColVec(datStruct.fid)
    return
end

%--- generation of weighting function ---
lbWeight = exp(-datStruct.lb*datStruct.dwell*(0:datStruct.nspecC-1)*pi)';

%--- line broadening --------------------
datFid = datStruct.fid .* lbWeight;

%--- update success flag ---
f_done = 1;

end
