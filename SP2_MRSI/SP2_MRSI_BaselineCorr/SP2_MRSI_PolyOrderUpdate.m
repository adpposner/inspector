%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_PolyOrderUpdate
%% 
%%  Update order of polynomial baseline correction.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mrsi


%--- parameter update ---
mrsi.basePolyOrder = max(round(str2num(get(fm.mrsi.base.polyOrder,'String'))),0);

%--- window update ---
set(fm.mrsi.base.polyOrder,'String',sprintf('%.0f',mrsi.basePolyOrder))

%--- window update ---
SP2_MRSI_MrsiWinUpdate
