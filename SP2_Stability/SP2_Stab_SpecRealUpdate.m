%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Stab_SpecRealUpdate
%% 
%%  Switching real/magnitude mode of the spectral analysis.
%%
%%  12-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- update flag parameter ---
flag.stabRealMagn = get(fm.stab.specReal,'Value');
set(fm.stab.specReal,'Value',flag.stabRealMagn)
set(fm.stab.specMagn,'Value',~flag.stabRealMagn)

%--- window update ---                           
SP2_Stab_StabilityWinUpdate