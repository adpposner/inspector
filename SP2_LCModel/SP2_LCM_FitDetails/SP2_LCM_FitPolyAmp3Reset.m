%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp3Reset
%% 
%%  Reset polynomial amplitude: 3rd order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(8)     = 0;
lcm.anaPolyCoeffImag(8) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


