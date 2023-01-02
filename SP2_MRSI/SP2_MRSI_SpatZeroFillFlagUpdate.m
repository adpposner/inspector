%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SpatZeroFillFlagUpdate
%% 
%%  Update flag for spatial zero-filling.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.mrsiSpatZF = get(fm.mrsi.spatZfFlag,'Value');
set(fm.mrsi.spatZfFlag,'Value',flag.mrsiSpatZF)

%--- window update ---
SP2_MRSI_MrsiWinUpdate

