%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_FormatPhaseUpdate
%% 
%%  Updates radiobutton setting: spectrum visualization
%%  1) real
%%  2) imaginary
%%  3) magnitude
%%  4) phase
%%
%%  09-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- direct assignment ---
flag.procFormat = 4;

%--- switch radiobutton ---
set(fm.proc.formatReal,'Value',flag.procFormat==1)
set(fm.proc.formatImag,'Value',flag.procFormat==2)
set(fm.proc.formatMagn,'Value',flag.procFormat==3)
set(fm.proc.formatPhase,'Value',flag.procFormat==4)

%--- update window ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate
