%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_EccFlagUpdate
%% 
%%  Update flag for eddy current compensation.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.mrsiEcc = get(fm.mrsi.eccFlag,'Value');
set(fm.mrsi.eccFlag,'Value',flag.mrsiEcc)

%--- window update ---
SP2_MRSI_MrsiWinUpdate

