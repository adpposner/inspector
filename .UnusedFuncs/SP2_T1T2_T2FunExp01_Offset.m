%--- exponential fitting function ---
function f = SP2_T1T2_T2FunExp01_Offset(a,x)

f = a(1) * exp(-x/a(2)) + a(3);
       



end
