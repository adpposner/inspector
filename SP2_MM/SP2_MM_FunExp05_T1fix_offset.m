%--- exponential fitting function ---
function f = SP2_MM_FunExp05_T1fix_offset(a,x)

global mm

f = a(1) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(1))) + ...
    a(2) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(2))) + ...
    a(3) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(3))) + ...
    a(4) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(4))) + ...
    a(5) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(5))) + mm.yOff;
       



end
