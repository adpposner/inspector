%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftVarMinUpdate
%% 
%%  Update minimum shift variation for assignment.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- retrieve entry ---
lcm.fit.shiftVarMin = str2double(get(fm.lcm.fit.anaShiftVarMin,'String'));

%--- consistency check ---
lcm.fit.shiftVarMin = min(max(lcm.fit.shiftVarMin,0),1e3);

%--- display update ---
set(fm.lcm.fit.anaShiftVarMin,'String',sprintf('%.1f',lcm.fit.shiftVarMin))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
