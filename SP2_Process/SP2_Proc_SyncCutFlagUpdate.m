%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SyncCutFlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag update ---
flag.procSyncCut = get(fm.proc.syncCut,'Value');

%--- button update ---
set(fm.proc.syncCut,'Value',flag.procSyncCut)

%--- window update ---
SP2_Proc_ProcessWinUpdate
