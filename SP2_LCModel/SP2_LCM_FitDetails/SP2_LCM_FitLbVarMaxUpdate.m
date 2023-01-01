%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbVarMaxUpdate
%% 
%%  Update maximum LB variation for assignment.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- retrieve entry ---
lcm.fit.lbVarMax = str2double(get(fm.lcm.fit.anaLbVarMax,'String'));

%--- consistency check ---
lcm.fit.lbVarMax = min(max(lcm.fit.lbVarMax,0),1e3);

%--- display update ---
set(fm.lcm.fit.anaLbVarMax,'String',sprintf('%.1f',lcm.fit.lbVarMax))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
