%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_TotalSelectUpdate
%% 
%%  Spectral analysis of whole spectral range from selected spectra.
%%
%%  12-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- update flag parameter ---
flag.stabTotSel = get(fm.stab.totSel,'Value');
set(fm.stab.totSel,'Value',flag.stabTotSel)

end
