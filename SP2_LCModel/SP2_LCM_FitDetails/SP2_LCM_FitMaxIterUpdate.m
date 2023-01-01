%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitMaxIterUpdate
%% 
%%  Update maximum number of iterations.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- retrieve entry ---
lcm.fit.maxIter = str2double(get(fm.lcm.fit.maxIter,'String'));

%--- consistency check ---
lcm.fit.maxIter = min(max(lcm.fit.maxIter,10),1e5);

%--- display update ---
set(fm.lcm.fit.maxIter,'String',sprintf('%.0f',lcm.fit.maxIter))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
