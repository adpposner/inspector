%--- double-exponential fitting function ---
function f = SP2_T1T2_T1FunExp01_Offset(a,x)

f = a(1) * (1 - exp(-x/a(2))) + a(3);
       


