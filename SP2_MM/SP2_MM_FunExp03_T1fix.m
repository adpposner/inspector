%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp03_T1fix(a,x)

global loggingfile mm

f = a(1) * (1 - exp(-x/mm.anaTOne(1))) + ...
    a(2) * (1 - exp(-x/mm.anaTOne(2))) + ...
    a(3) * (1 - exp(-x/mm.anaTOne(3)));
       


