%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp04_offset(a,x)

global loggingfile mm

f = a(1) * (1 - exp(-(x-mm.xOff)/a(2))) + ...
    a(3) * (1 - exp(-(x-mm.xOff)/a(4))) + ...
    a(5) * (1 - exp(-(x-mm.xOff)/a(6))) + ...
    a(7) * (1 - exp(-(x-mm.xOff)/a(8))) + mm.yOff;
       


