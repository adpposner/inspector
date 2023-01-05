%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_BinAllUpdate
%% 
%%  Spectral analysis of a binned spectral range from all spectra.
%%
%%  12-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- update flag parameter ---
flag.stabBinAll = get(fm.stab.binAll,'Value');
set(fm.stab.binAll,'Value',flag.stabBinAll)
