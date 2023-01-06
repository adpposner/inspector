%--- double-exponential fitting function ---
function f = SP2_T1T2_T1FunExp03_Offset(a,x)

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4))) + ...
    a(5) * (1 - exp(-x/a(6))) + a(7);
       



end
