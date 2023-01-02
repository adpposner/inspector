%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp6Reset
%% 
%%  Reset polynomial amplitude: 6th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(5)     = 0;
lcm.anaPolyCoeffImag(5) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


