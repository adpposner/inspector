%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SyncOffsetFlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- flag update ---
flag.procSyncOffset = get(fm.proc.syncOffset,'Value');

%--- button update ---
set(fm.proc.syncOffset,'Value',flag.procSyncOffset)

%--- window update ---
SP2_Proc_ProcessWinUpdate
