%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_NumSpecOneUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  0: One spectrum
%%  1: Two spectra
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.procNumSpec = ~get(fm.proc.numSpecOne,'Value');

%--- switch radiobutton ---
set(fm.proc.numSpecOne,'Value',~flag.procNumSpec)
set(fm.proc.numSpecTwo,'Value',flag.procNumSpec)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
