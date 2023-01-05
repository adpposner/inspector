%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_DataMrsiUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  0: data sheet
%%  1: MRSI sheet
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.mrsiData = get(fm.mrsi.datMrsi,'Value');

%--- switch radiobutton ---
set(fm.mrsi.datData,'Value',~flag.mrsiData)
set(fm.mrsi.datMrsi,'Value',flag.mrsiData)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
