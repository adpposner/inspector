%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp4Update
%% 
%%  Update polynomial amplitude: 4th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(7) = str2double(get(fm.lcm.fit.polyAmp4,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate



end
