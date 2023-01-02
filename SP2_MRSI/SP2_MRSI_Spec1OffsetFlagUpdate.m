%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_Spec1OffsetFlagUpdate
%% 
%%  Switching on/off baseline offset for spectrum 1.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.mrsiSpec1Offset = get(fm.mrsi.spec1OffsetFlag,'Value');
set(fm.mrsi.spec1OffsetFlag,'Value',flag.mrsiSpec1Offset)

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate
