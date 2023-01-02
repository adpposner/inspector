%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_BinSelectUpdate
%% 
%%  Spectral analysis of a binned spectral range from selected spectra.
%%
%%  12-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- update flag parameter ---
flag.stabBinSel = get(fm.stab.binSel,'Value');
set(fm.stab.binSel,'Value',flag.stabBinSel)
