%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp0Update
%% 
%%  Update polynomial amplitude: 0 order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(11) = str2double(get(fm.lcm.fit.polyAmp0,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


