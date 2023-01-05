%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp10_T1fix(a,x)

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
    a(10) * (1 - exp(-x/mm.anaTOne(10)));
       


