%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function [nThPowerVal,nThPower] = SP2_RoundToPowerOfN(value,base)
%%
%%  function value = SP2_RoundToPowerOfN(value,base)
%%  rounds parameter value to the next power of n.
%%
%%  02-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_RoundToPowerOfN';

nThPowerVal = 0;            % init
nThPower    = 0;            % init

if ~SP2_Check4Num(value)
    return
end
if ~SP2_Check4Num(base)
    return
end
if base<0
    fprintf('%s -> only positive numbers are allowed as 2nd function argument\n\n',FCTNAME);
    return
end
nThRootVec  = nthroot(value,1:100);
nThPower    = round(SP2_BestApprox(nThRootVec,base));
nThPowerVal = base^nThPower;

end
