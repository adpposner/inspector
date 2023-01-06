%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp7Update
%% 
%%  Update polynomial amplitude: 7th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(4) = str2double(get(fm.lcm.fit.polyAmp7,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate



end
