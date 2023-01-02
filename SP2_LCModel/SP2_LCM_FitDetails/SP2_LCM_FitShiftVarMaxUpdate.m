%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitShiftVarMaxUpdate
%% 
%%  Update maximum shift variation for assignment.
%%
%%  08-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm lcm


%--- retrieve entry ---
lcm.fit.shiftVarMax = str2double(get(fm.lcm.fit.anaShiftVarMax,'String'));

%--- consistency check ---
lcm.fit.shiftVarMax = min(max(lcm.fit.shiftVarMax,0),1e3);

%--- display update ---
set(fm.lcm.fit.anaShiftVarMax,'String',sprintf('%.1f',lcm.fit.shiftVarMax))

%--- update window ---
SP2_LCM_FitDetailsWinUpdate
