%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPhc0AnaUpdate
%% 
%%  Update PHC0 start value.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- retrieve entry ---
lcm.anaPhc0 = str2double(get(fm.lcm.fit.phc0,'String'));

%--- display update ---
set(fm.lcm.fit.phc0,'String',sprintf('%.1f',lcm.anaPhc0))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

