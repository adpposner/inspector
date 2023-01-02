%--- triple-exponential fitting function ---
function f = SP2_MM_FunExp01_offset(a,x)

global loggingfile mm

f = a(1) * (1 - exp(-(x-mm.xOff)/a(2))) + mm.yOff;
       


