%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp10Reset
%% 
%%  Reset polynomial amplitude: 10th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(1)     = 0;
lcm.anaPolyCoeffImag(1) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


