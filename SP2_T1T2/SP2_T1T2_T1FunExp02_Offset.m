%--- double-exponential fitting function ---
function f = SP2_T1T2_T1FunExp02_offset(a,x)

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4))) + a(5);
       


