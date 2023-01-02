%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp10Update
%% 
%%  Update polynomial amplitude: 10th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(1) = str2double(get(fm.lcm.fit.polyAmp10,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


