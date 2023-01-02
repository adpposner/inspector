%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_FormatMagnUpdate
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
flag.mrsiFormat = 3;

%--- switch radiobutton ---
set(fm.mrsi.formatReal,'Value',flag.mrsiFormat==1)
set(fm.mrsi.formatImag,'Value',flag.mrsiFormat==2)
set(fm.mrsi.formatMagn,'Value',flag.mrsiFormat==3)
set(fm.mrsi.formatPhase,'Value',flag.mrsiFormat==4)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
