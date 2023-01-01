%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp1Reset
%% 
%%  Reset polynomial amplitude: 1st order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(10)     = 0;
lcm.anaPolyCoeffImag(10) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


