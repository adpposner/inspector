%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_NumSpecOneUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  0: One spectrum
%%  1: Two spectra
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mrsiNumSpec = ~get(fm.mrsi.numSpecOne,'Value');

%--- switch radiobutton ---
set(fm.mrsi.numSpecOne,'Value',~flag.mrsiNumSpec)
set(fm.mrsi.numSpecTwo,'Value',flag.mrsiNumSpec)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
