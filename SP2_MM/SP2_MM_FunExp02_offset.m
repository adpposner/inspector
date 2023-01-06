%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp02_offset(a,x)

global mm

f = a(1) * (1 - exp(-(x-mm.xOff)/a(2))) + ...
    a(3) * (1 - exp(-(x-mm.xOff)/a(4))) + mm.yOff;
       



end
