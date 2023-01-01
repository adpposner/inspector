%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPolyAmp9Update
%% 
%%  Update polynomial amplitude: 9th order.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global lcm fm


%--- retrieve entry ---
lcm.anaPolyCoeff(2) = str2double(get(fm.lcm.fit.polyAmp9,'String'));

%--- update window ---
SP2_LCM_FitDetailsWinUpdate


