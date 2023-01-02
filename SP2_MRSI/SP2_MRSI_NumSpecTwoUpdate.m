%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_NumSpecTwoUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  0: One spectrum
%%  1: Two spectra
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

flag.mrsiNumSpec = get(fm.mrsi.numSpecTwo,'Value');

%--- switch radiobutton ---
set(fm.mrsi.numSpecOne,'Value',~flag.mrsiNumSpec)
set(fm.mrsi.numSpecTwo,'Value',flag.mrsiNumSpec)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
