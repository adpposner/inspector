%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignPhModeIntegralUpdate
%% 
%%  Switching optimization mode:
%%  0: maximization of spectrum integral
%%  1: maximization of congruency with reference
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- retrieve parameter ---
flag.dataAlignPhMode = ~get(fm.data.alignDet.phModeInteg,'Value');

%--- update switches ---
set(fm.data.alignDet.phModeInteg,'Value',~flag.dataAlignPhMode)
set(fm.data.alignDet.phModeCongr,'Value',flag.dataAlignPhMode)

%--- window update ---
SP2_Data_AlignDetailsWinUpdate

