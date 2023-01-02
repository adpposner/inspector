%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp0Reset
%% 
%%  Reset polynomial amplitude: 0 order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm


%--- retrieve entry ---
lcm.anaPolyCoeff(11)     = 0;
lcm.anaPolyCoeffImag(11) = 0;

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


