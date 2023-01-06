%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_DataFormatMatlabUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  1: Matlab format (.mat) including basic spectroscopic parameters
%%  2: Text format (.txt) for export to or import from RAG software.
%%  3: Parameter file (.par) assignment to load all moeties of a metabolite
%%
%%  10-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.procDataFormat = 1;

%--- switch radiobutton ---
set(fm.proc.dataFormatMat,'Value',flag.procDataFormat==1)
set(fm.proc.dataFormatTxt,'Value',flag.procDataFormat==2)
set(fm.proc.dataFormatPar,'Value',flag.procDataFormat==3)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate


end
