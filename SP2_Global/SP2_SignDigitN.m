%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function ndigit = SP2_SignDigitN(value,nsign)
%%
%%  function ndigit = SP2_SignDigitN(value,nsign)
%%  Determines the number of digits 'ndigit' to be diplayed (e.g. in
%%  fprintf's %.nf) in order to represent selected number of significant 
%%  digits 'nsign' for a given number 'value').
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

FCTNAME = 'SP2_SignDigitN';

%--- init ---
ndigit = 0;

%--- consistency checks ---
if ~SP2_Check4Num(value)
    return
end
if ~SP2_Check4Num(nsign)
    return
end

%--- ndigit calculation ---
if floor(log10(abs(value)))<nsign
    ndigit = (nsign-1) - floor(log10(abs(value)));
else
    ndigit = 0;
end

% %--- info printout ---
% fprintf('ndigit = %.0f\n',ndigit);
end
