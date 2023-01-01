%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function value = SP2_RoundToNthDigit(value,ndigit)
%%
%%  function value = SP2_RoundToNthDigit(value,ndigit)
%%  rounds parameter value to the n-th decimal digit
%%
%%  10-2004, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_RoundToNthDigit';


if ~SP2_Check4Num(value)
    return
end
if ~SP2_Check4Num(ndigit)
    return
end
if mod(ndigit,1)~=0 && ndigit<0
    fprintf('%s -> only positive integers are allowed for <ndigit>\n\n',FCTNAME)
    return
end

valueTmp = value * 10^ndigit;
value    = round(valueTmp)/10^ndigit;
