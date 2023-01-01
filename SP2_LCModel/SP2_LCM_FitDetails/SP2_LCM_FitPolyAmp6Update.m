%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp6Update
%% 
%%  Update polynomial amplitude: 6th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(5) = str2double(get(fm.lcm.fit.polyAmp6,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


