%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitGbVarMinUpdate
%% 
%%  Update minimum GB variation for assignment.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- retrieve entry ---
lcm.fit.gbVarMin = str2double(get(fm.lcm.fit.anaGbVarMin,'String'));

%--- consistency check ---
lcm.fit.gbVarMin = min(max(lcm.fit.gbVarMin,0),1e3);

%--- display update ---
set(fm.lcm.fit.anaGbVarMin,'String',sprintf('%.1f',lcm.fit.gbVarMin))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
