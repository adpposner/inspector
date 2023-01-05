%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PolyOrderUpdate
%% 
%%  Update order of polynomial baseline correction.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- parameter update ---
proc.basePolyOrder = max(round(str2num(get(fm.proc.base.polyOrder,'String'))),0);

%--- window update ---
set(fm.proc.base.polyOrder,'String',sprintf('%.0f',proc.basePolyOrder))

%--- window update ---
SP2_Proc_ProcessWinUpdate
