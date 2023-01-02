%--- exponential fitting function ---
function f = SP2_T1T2_T2FunExp03_Offset(a,x)

f = a(1) * exp(-x/a(2)) + ...
    a(3) * exp(-x/a(4)) + ...
    a(5) * exp(-x/a(6)) + a(7);
       


