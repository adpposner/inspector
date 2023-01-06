%--- mono-exponential fitting function ---
function f = SP2_MM_FunExp01_full(a,x)
f = a(1) * exp(-(x-a(2))/a(3)) + a(4);

end
