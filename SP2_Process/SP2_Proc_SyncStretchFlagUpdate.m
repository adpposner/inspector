%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_SyncStretchFlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- flag update ---
flag.procSyncStretch = get(fm.proc.syncStretch,'Value');

%--- button update ---
set(fm.proc.syncStretch,'Value',flag.procSyncStretch)

%--- window update ---
SP2_Proc_ProcessWinUpdate
