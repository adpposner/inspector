%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_T1SelectUpdate
%% 
%%  T1 selection for selective visualization.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm mm


%--- parameter update ---
mm.tOneSelect = str2num(get(fm.mm.tOneSelect,'String'));
mm.tOneSelect = min(max(1,round(mm.tOneSelect)),mm.anaTOneN);
set(fm.mm.tOneSelect,'String',num2str(mm.tOneSelect))

%--- figure update ---
SP2_MM_T1ShowFidSingle(0);
SP2_MM_T1ShowSpecSingle(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_T1ShowSpecArray(0);
SP2_MM_T1ShowSpecSum(0);

%--- window update ---
SP2_MM_MacroWinUpdate
