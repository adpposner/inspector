%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp01(a,x)

f = a(1) * (1 - exp(-x/a(2)));
       



end
