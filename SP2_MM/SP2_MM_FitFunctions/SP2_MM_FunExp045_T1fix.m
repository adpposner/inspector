%
% Automatically generated fit function
% created 10-Feb-2015 21:28:04
%
function f = SP2_MM_FunExp045_T1fix(a,x)

global mm

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
    a(15) * (1 - exp(-x/mm.anaTOne(15))) + ...
    a(16) * (1 - exp(-x/mm.anaTOne(16))) + ...
    a(17) * (1 - exp(-x/mm.anaTOne(17))) + ...
    a(18) * (1 - exp(-x/mm.anaTOne(18))) + ...
    a(19) * (1 - exp(-x/mm.anaTOne(19))) + ...
    a(20) * (1 - exp(-x/mm.anaTOne(20))) + ...
    a(21) * (1 - exp(-x/mm.anaTOne(21))) + ...
    a(22) * (1 - exp(-x/mm.anaTOne(22))) + ...
    a(23) * (1 - exp(-x/mm.anaTOne(23))) + ...
    a(24) * (1 - exp(-x/mm.anaTOne(24))) + ...
    a(25) * (1 - exp(-x/mm.anaTOne(25))) + ...
    a(26) * (1 - exp(-x/mm.anaTOne(26))) + ...
    a(27) * (1 - exp(-x/mm.anaTOne(27))) + ...
    a(28) * (1 - exp(-x/mm.anaTOne(28))) + ...
    a(29) * (1 - exp(-x/mm.anaTOne(29))) + ...
    a(30) * (1 - exp(-x/mm.anaTOne(30))) + ...
    a(31) * (1 - exp(-x/mm.anaTOne(31))) + ...
    a(32) * (1 - exp(-x/mm.anaTOne(32))) + ...
    a(33) * (1 - exp(-x/mm.anaTOne(33))) + ...
    a(34) * (1 - exp(-x/mm.anaTOne(34))) + ...
    a(35) * (1 - exp(-x/mm.anaTOne(35))) + ...
    a(36) * (1 - exp(-x/mm.anaTOne(36))) + ...
    a(37) * (1 - exp(-x/mm.anaTOne(37))) + ...
    a(38) * (1 - exp(-x/mm.anaTOne(38))) + ...
    a(39) * (1 - exp(-x/mm.anaTOne(39))) + ...
    a(40) * (1 - exp(-x/mm.anaTOne(40))) + ...
    a(41) * (1 - exp(-x/mm.anaTOne(41))) + ...
    a(42) * (1 - exp(-x/mm.anaTOne(42))) + ...
    a(43) * (1 - exp(-x/mm.anaTOne(43))) + ...
    a(44) * (1 - exp(-x/mm.anaTOne(44))) + ...
    a(45) * (1 - exp(-x/mm.anaTOne(45)));
