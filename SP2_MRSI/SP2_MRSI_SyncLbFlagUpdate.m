%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SyncLbFlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag update ---
flag.mrsiSyncLb = get(fm.mrsi.syncLb,'Value');

%--- button update ---
set(fm.mrsi.syncLb,'Value',flag.mrsiSyncLb)

%--- window update ---
SP2_MRSI_MrsiWinUpdate
