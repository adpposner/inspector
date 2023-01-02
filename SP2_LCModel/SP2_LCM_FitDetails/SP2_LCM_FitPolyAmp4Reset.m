%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp4Reset
%% 
%%  Reset polynomial amplitude: 4th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(7)     = 0;
lcm.anaPolyCoeffImag(7) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


