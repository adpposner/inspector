%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_SpatFiltFlagUpdate
%% 
%%  Spatial filter flag.
%%
%%  04-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.mrsiSpatFilt = get(fm.mrsi.spatFiltFlag,'Value');
set(fm.mrsi.spatFiltFlag,'Value',flag.mrsiSpatFilt)

%--- window update ---
SP2_MRSI_MrsiWinUpdate


end
