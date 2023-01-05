%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SyncPhc1FlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag update ---
flag.procSyncPhc1 = get(fm.proc.syncPhc1,'Value');

%--- button update ---
set(fm.proc.syncPhc1,'Value',flag.procSyncPhc1)

%--- window update ---
SP2_Proc_ProcessWinUpdate
