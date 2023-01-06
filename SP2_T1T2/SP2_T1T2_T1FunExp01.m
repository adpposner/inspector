%--- double-exponential fitting function ---
function f = SP2_T1T2_T1FunExp01(a,x)

f = a(1) * (1 - exp(-x/a(2)));
       



end
