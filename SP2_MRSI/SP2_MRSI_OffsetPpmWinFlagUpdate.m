%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_OffsetPpmWinFlagUpdate
%% 
%%  Updates radiobutton setting: baseline offset mode
%%  1: mean of ppm range
%%  0: direct assignment of offset value
%%
%%  07-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- retrieve parameter ---
flag.mrsiOffset = get(fm.mrsi.offsetPpmFlag,'Value');

%--- switch radiobutton ---
set(fm.mrsi.offsetPpmFlag,'Value',flag.mrsiOffset)
set(fm.mrsi.offsetValFlag,'Value',~flag.mrsiOffset)

%--- update window ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
