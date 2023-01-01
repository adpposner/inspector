%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitGbVarMaxUpdate
%% 
%%  Update maximum GB variation for assignment.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- retrieve entry ---
lcm.fit.gbVarMax = str2double(get(fm.lcm.fit.anaGbVarMax,'String'));

%--- consistency check ---
lcm.fit.gbVarMax = min(max(lcm.fit.gbVarMax,0),1e3);

%--- display update ---
set(fm.lcm.fit.anaGbVarMax,'String',sprintf('%.1f',lcm.fit.gbVarMax))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
