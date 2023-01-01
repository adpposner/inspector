%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp5Reset
%% 
%%  Reset polynomial amplitude: 5th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(6)     = 0;
lcm.anaPolyCoeffImag(6) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


