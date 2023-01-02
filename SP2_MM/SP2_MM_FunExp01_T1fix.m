%--- mono-exponential fitting function ---
function f = SP2_MM_FunExp01_T1fix(a,x)

global loggingfile mm

f = a(1) * (1 - exp(-x/mm.anaTOne(1)));
