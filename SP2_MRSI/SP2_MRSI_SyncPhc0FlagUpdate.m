%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SyncPhc0FlagUpdate
%% 
%%  Switch for synchronization of FID 1 & 2 processing.
%%
%%  11-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag update ---
flag.mrsiSyncPhc0 = get(fm.mrsi.syncPhc0,'Value');

%--- button update ---
set(fm.mrsi.syncPhc0,'Value',flag.mrsiSyncPhc0)

%--- window update ---
SP2_MRSI_MrsiWinUpdate

end
