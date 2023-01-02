%--- double-exponential fitting function ---
function f = SP2_T1T2_T1FunExp04_OneFix_Offset(a,x)

global loggingfile t1t2

f = a(1) * (1 - exp(-x/a(2))) + ...
    a(3) * (1 - exp(-x/a(4))) + ...
    a(5) * (1 - exp(-x/a(6))) + ...
    a(7) * (1 - exp(-x/t1t2.anaTConstFlex1Fix)) + a(8);
       


