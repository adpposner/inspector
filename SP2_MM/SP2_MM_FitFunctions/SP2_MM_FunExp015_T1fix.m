%
% Automatically generated fit function
% created 10-Oct-2014 14:49:23
%
function f = SP2_MM_FunExp015_T1fix(a,x)

global loggingfile mm

f = a(1) * (1 - exp(-x/mm.anaTOne(1))) + ...
    a(2) * (1 - exp(-x/mm.anaTOne(2))) + ...
    a(3) * (1 - exp(-x/mm.anaTOne(3))) + ...
    a(4) * (1 - exp(-x/mm.anaTOne(4))) + ...
    a(5) * (1 - exp(-x/mm.anaTOne(5))) + ...
    a(6) * (1 - exp(-x/mm.anaTOne(6))) + ...
    a(7) * (1 - exp(-x/mm.anaTOne(7))) + ...
    a(8) * (1 - exp(-x/mm.anaTOne(8))) + ...
    a(9) * (1 - exp(-x/mm.anaTOne(9))) + ...
    a(10) * (1 - exp(-x/mm.anaTOne(10))) + ...
    a(11) * (1 - exp(-x/mm.anaTOne(11))) + ...
    a(12) * (1 - exp(-x/mm.anaTOne(12))) + ...
    a(13) * (1 - exp(-x/mm.anaTOne(13))) + ...
    a(14) * (1 - exp(-x/mm.anaTOne(14))) + ...
    a(15) * (1 - exp(-x/mm.anaTOne(15)));