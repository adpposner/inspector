%--- exponential fitting function ---
function f = SP2_MM_FunExp15_T1fix_offset(a,x)

global mm

f = a(1) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(1))) + ...
    a(2) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(2))) + ...
    a(3) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(3))) + ...
    a(4) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(4))) + ...
    a(5) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(5))) + ...
    a(6) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(6))) + ...
    a(7) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(7))) + ...
    a(8) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(8))) + ...
    a(9) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(9))) + ...
    a(10) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(10))) + ...
    a(11) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(11))) + ...
    a(12) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(12))) + ...
    a(13) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(13))) + ...
    a(14) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(14))) + ...
    a(15) * (1 - exp(-(x-mm.xOff)/mm.anaTOne(15))) + mm.yOff;
       


