function [pAfter] = evolveInTime(p,dt,H)
%function written to evolve p in time by a unit of dt when acted on by the
%operator H (Hamiltonian)

A = -1i*H*dt;
% if (tolerance < 1E-6 && Nspins > 5)
expA = expm(A); %MATLABs is better for small tolerance with large spin systems
% else
%     expA = fastExpm(A,tolerance); %mine is better for relatively large tolerance or small spin systems
% end
pAfter = expA*p*expA';
