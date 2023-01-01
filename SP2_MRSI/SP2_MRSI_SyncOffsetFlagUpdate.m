%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SyncOffsetFlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag update ---
flag.mrsiSyncOffset = get(fm.mrsi.syncOffset,'Value');

%--- button update ---
set(fm.mrsi.syncOffset,'Value',flag.mrsiSyncOffset)

%--- window update ---
SP2_MRSI_MrsiWinUpdate
