%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SyncZfFlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- flag update ---
flag.procSyncZf = get(fm.proc.syncZf,'Value');

%--- button update ---
set(fm.proc.syncZf,'Value',flag.procSyncZf)

%--- window update ---
SP2_Proc_ProcessWinUpdate
