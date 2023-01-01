%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp5Update
%% 
%%  Update polynomial amplitude: 5th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(6) = str2double(get(fm.lcm.fit.polyAmp5,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


