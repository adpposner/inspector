%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp09(a,x)

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4))) + ...
    a(5) * (1 - exp(-x/a(6))) + ...
    a(7) * (1 - exp(-x/a(8))) + ...
    a(9) * (1 - exp(-x/a(10))) + ...
    a(11) * (1 - exp(-x/a(12))) + ...
    a(13) * (1 - exp(-x/a(14))) + ...
    a(15) * (1 - exp(-x/a(16))) + ...
    a(17) * (1 - exp(-x/a(18)));
       


