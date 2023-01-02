%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp8Update
%% 
%%  Update polynomial amplitude: 8th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(3) = str2double(get(fm.lcm.fit.polyAmp8,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


