%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp05_offset(a,x)

global mm

f = a(1) * (1 - exp(-(x-mm.xOff)/a(2))) + ...
    a(3) * (1 - exp(-(x-mm.xOff)/a(4))) + ...
    a(5) * (1 - exp(-(x-mm.xOff)/a(6))) + ...
    a(7) * (1 - exp(-(x-mm.xOff)/a(8))) + ...
    a(9) * (1 - exp(-(x-mm.xOff)/a(10))) + mm.yOff;
       



end
