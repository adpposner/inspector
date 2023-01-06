%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignPhModeCongruencyUpdate
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
flag.dataAlignPhMode = get(fm.data.align.phModeCongr,'Value');

%--- update switches ---
set(fm.data.align.phModeInteg,'Value',~flag.dataAlignPhMode)
set(fm.data.align.phModeCongr,'Value',flag.dataAlignPhMode)

%--- window update ---
SP2_Data_AlignDetailsWinUpdate


end
