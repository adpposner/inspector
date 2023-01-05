%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignPhaseUpdate
%% 
%%  Switching on/off spectral phase alignment for procession of arrayed
%%  acquisitions.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.mmAlignPhase = get(fm.mm.align.phase,'Value');

%--- window update ---
set(fm.mm.align.phase,'Value',flag.mmAlignPhase)

