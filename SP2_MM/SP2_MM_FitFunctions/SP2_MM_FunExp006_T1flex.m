%
% Automatically generated fit function
% created 13-Oct-2014 15:32:45
%
function f = SP2_MM_FunExp006_T1flex(a,x)

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4))) + ...
    a(5) * (1 - exp(-x/a(6))) + ...
    a(7) * (1 - exp(-x/a(8))) + ...
    a(9) * (1 - exp(-x/a(10))) + ...
    a(11) * (1 - exp(-x/a(12)));