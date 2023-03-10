%
% Automatically generated fit function
% created 27-Jun-2014 18:46:05
%
function f = SP2_MM_FunExp005_T1fix(a,x)

global mm

f = a(1) * (1 - exp(-x/mm.anaTOne(1))) + ...
    a(2) * (1 - exp(-x/mm.anaTOne(2))) + ...
    a(3) * (1 - exp(-x/mm.anaTOne(3))) + ...
    a(4) * (1 - exp(-x/mm.anaTOne(4))) + ...
    a(5) * (1 - exp(-x/mm.anaTOne(5)));

end
