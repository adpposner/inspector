%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp1Update
%% 
%%  Update polynomial amplitude: 1st order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(10) = str2double(get(fm.lcm.fit.polyAmp1,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


