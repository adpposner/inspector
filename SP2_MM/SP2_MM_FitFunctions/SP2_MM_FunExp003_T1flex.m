%
% Automatically generated fit function
% created 13-Oct-2014 15:55:53
%
function f = SP2_MM_FunExp003_T1flex(a,x)

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4))) + ...
    a(5) * (1 - exp(-x/a(6)));

end
