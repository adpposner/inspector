%--- double-exponential fitting function ---
function f = SP2_MM_FunExp02(a,x)

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4)));
       


