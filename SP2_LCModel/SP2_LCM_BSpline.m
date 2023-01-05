%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function SP2_LCM_BSpline(T,p,y,order)
    function yVal = SP2_LCM_BSpline

%% Adapted from 
%% function val = DEBOOR(T,p,y,order)
%% by Jonas Ballani, 2007-11-27, TUM
%% 
%% INPUT:  T     St�tzstellen
%%         p     Kontrollpunkte (nx2-Matrix)
%%         y     Auswertungspunkte (Spaltenvektor)
%%         order Spline-Ordnung
%% 
%% OUTPUT: val   Werte des B-Splines an y (mx2-Matrix)
%%
%%  11-2018, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm



knotVec = 0:1/100:1;
% 
% ampVec = [0 1 1.9 3.1 4.3 4.6 6 7 9 11 8 6 3];



bspline(knotVec)


