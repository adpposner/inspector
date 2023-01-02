%
% Automatically generated fit function
% created 13-Oct-2014 15:43:03
%
function f = SP2_MM_FunExp002_T1flex(a,x)

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4)));
