%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_TotalAllUpdate
%% 
%%  Spectral analysis of the entire spectral range from all spectra.
%%
%%  12-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- update flag parameter ---
flag.stabTotAll = get(fm.stab.totAll,'Value');
set(fm.stab.totAll,'Value',flag.stabTotAll)
