%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp9Reset
%% 
%%  Reset polynomial amplitude: 9th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(2) = 0;
lcm.anaPolyCoeffImag(2) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


