%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec2ShiftFlagUpdate
%% 
%%  Switching on/off amplitude shift for spectrum 2
%%
%%  09-2009, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.mrsiSpec2Shift = get(fm.mrsi.spec2ShiftFlag,'Value');
set(fm.mrsi.spec2ShiftFlag,'Value',flag.mrsiSpec2Shift)

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
