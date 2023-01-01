%
% Automatically generated fit function
% created 13-Oct-2014 15:44:09
%
function f = SP2_MM_FunExp001_T1flex(a,x)

f = a(1) * (1 - exp(-x/a(2)));
