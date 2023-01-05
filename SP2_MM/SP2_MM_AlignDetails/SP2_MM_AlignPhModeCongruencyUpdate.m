%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignPhModeCongruencyUpdate
%% 
%%  Switching optimization mode:
%%  0: maximization of spectrum integral
%%  1: maximization of congruency with reference
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- retrieve parameter ---
flag.mmAlignPhMode = get(fm.mm.align.phModeCongr,'Value');

%--- update switches ---
set(fm.mm.align.phModeInteg,'Value',~flag.mmAlignPhMode)
set(fm.mm.align.phModeCongr,'Value',flag.mmAlignPhMode)

%--- window update ---
SP2_MM_AlignDetailsWinUpdate

