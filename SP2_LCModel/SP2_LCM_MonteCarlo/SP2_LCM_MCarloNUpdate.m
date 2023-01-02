%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_MCarloNUpdate
%% 
%%  Update number of Monte-Carlo computations.
%%
%%  05-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- get value ---
lcm.mc.n = max(round(str2num(get(fm.lcm.anaMCarloN,'String'))),3);

%--- update display ---
set(fm.lcm.anaMCarloN,'String',sprintf('%.0f',lcm.mc.n))

