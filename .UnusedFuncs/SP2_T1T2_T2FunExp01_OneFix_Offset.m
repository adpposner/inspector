%--- exponential fitting function ---
function f = SP2_T1T2_T2FunExp01_OneFix_Offset(a,x)

global t1t2

f = a(1) * exp(-x/t1t2.anaTConstFlex1Fix) + a(2);
       



end
