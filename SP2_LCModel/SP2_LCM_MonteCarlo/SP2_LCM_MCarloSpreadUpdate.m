%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_MCarloSpreadUpdate
%% 
%%  Standard deviation [%%] of variation for Monte-Carlo initialization.
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- get value ---
lcm.mc.initSpread = min(max(round(str2num(get(fm.lcm.anaMCarloSpread,'String'))),0),1000);

%--- update display ---
set(fm.lcm.anaMCarloSpread,'String',sprintf('%.0f',lcm.mc.initSpread))

