%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PolyOrderUpdate
%% 
%%  Update order of polynomial baseline correction.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm lcm


%--- parameter update ---
lcm.basePolyOrder = max(round(str2num(get(fm.lcm.base.polyOrder,'String'))),0);

%--- window update ---
set(fm.lcm.base.polyOrder,'String',sprintf('%.0f',lcm.basePolyOrder))

%--- window update ---
SP2_LCM_ProcessWinUpdate
