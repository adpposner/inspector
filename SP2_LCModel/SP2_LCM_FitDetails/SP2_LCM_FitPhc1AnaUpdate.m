%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitPhc1AnaUpdate
%% 
%%  Update PHC0 start value.
%%
%%  07-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- retrieve entry ---
lcm.anaPhc1 = str2double(get(fm.lcm.fit.phc1,'String'));

%--- display update ---
set(fm.lcm.fit.phc1,'String',sprintf('%.1f',lcm.anaPhc1))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate

