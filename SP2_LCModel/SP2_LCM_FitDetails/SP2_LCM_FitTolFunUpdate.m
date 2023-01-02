%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitTolFunUpdate
%% 
%%  Update tolerance function limit.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- retrieve entry ---
lcm.fit.tolFun = str2double(get(fm.lcm.fit.tolFun,'String'));

%--- consistency checks ---
lcm.fit.tolFun = min(max(lcm.fit.tolFun,1e-15),1e-4);

%--- display update ---
set(fm.lcm.fit.tolFun,'String',sprintf('%.2g',lcm.fit.tolFun))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
