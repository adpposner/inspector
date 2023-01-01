%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitLbVarMinUpdate
%% 
%%  Update minimum LB variation for assignment.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- retrieve entry ---
lcm.fit.lbVarMin = str2double(get(fm.lcm.fit.anaLbVarMin,'String'));

%--- consistency check ---
lcm.fit.lbVarMin = min(max(lcm.fit.lbVarMin,0),1e3);

%--- display update ---
set(fm.lcm.fit.anaLbVarMin,'String',sprintf('%.1f',lcm.fit.lbVarMin))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
