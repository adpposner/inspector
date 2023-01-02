%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp05(a,x)
f = a(1) * exp(-(x-a(2))/a(3)) + ...
    a(4) * exp(-(x-a(5))/a(6)) + ...;
    a(7) * exp(-(x-a(8))/a(9)) + ...;
    a(10) * exp(-(x-a(11))/a(12)) + ...;
    a(13) * exp(-(x-a(14))/a(15)) + a(16);
       


