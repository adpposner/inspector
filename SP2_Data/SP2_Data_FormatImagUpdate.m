%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_FormatImagUpdate
%% 
%%  Visualization mode:
%%  1) real
%%  2) imaginary
%%  3) magnitude
%%  4) phase
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- direct assignment ---
flag.dataFormat = 2;

%--- switch radiobutton ---
set(fm.data.formatReal,'Value',flag.dataFormat==1)
set(fm.data.formatImag,'Value',flag.dataFormat==2)
set(fm.data.formatMagn,'Value',flag.dataFormat==3)
set(fm.data.formatPhase,'Value',flag.dataFormat==4)

%--- figure update ---
SP2_Data_FigureUpdate;

%--- update window ---
SP2_Data_DataWinUpdate

