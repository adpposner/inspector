%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_DataFormatTextUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  1: Matlab format (.mat) including basic spectroscopic parameters
%%  0: text format (.txt) for export to RAG software.
%%
%%  10-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.mrsiDatFormat = ~get(fm.mrsi.datFormatTxt,'Value');

%--- switch radiobutton ---
set(fm.mrsi.datFormatMat,'Value',flag.mrsiDatFormat)
set(fm.mrsi.datFormatTxt,'Value',~flag.mrsiDatFormat)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate


end
