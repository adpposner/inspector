%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp2Update
%% 
%%  Update polynomial amplitude: 2nd order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(9) = str2double(get(fm.lcm.fit.polyAmp2,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


