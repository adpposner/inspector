 function [pRelaxed] = relaxInTime(p,dt,relaxationTimes,filterMatrixPlusOne,filterMatrixMinusOne,filterMatrixIz,pz)
 %function which just relaxes the populations by T1 and the single quantum
 %coherence terms by T2
%  pRelaxed = p.*(filterMatrixPlusOne+filterMatrixMinusOne)*exp(-dt/relaxationTimes(2))+p.*(filterMatrixIz)*exp(-dt/relaxationTimes(1))+(1-exp(-dt/relaxationTimes(1)))*pz+p.*(1-filterMatrixPlusOne-filterMatrixMinusOne-filterMatrixIz);

 pRelaxed = p.*(filterMatrixPlusOne+filterMatrixMinusOne)*exp(-dt/relaxationTimes(2))+p.*(filterMatrixIz)*exp(-dt/relaxationTimes(1))+p.*(1-filterMatrixPlusOne-filterMatrixMinusOne-filterMatrixIz);
end
