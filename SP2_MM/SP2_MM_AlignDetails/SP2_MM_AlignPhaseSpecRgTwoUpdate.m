%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignPhaseSpecRgTwoUpdate
%% 
%%  Switching on/off between 1 and 2 spectral windows for phase alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- retrieve parameter ---
flag.mmAlignPhSpecRg = get(fm.mm.align.phSpecRgTwo,'Value');

%--- update switches ---
set(fm.mm.align.phSpecRgOne,'Value',~flag.mmAlignPhSpecRg)
set(fm.mm.align.phSpecRgTwo,'Value',flag.mmAlignPhSpecRg)

%--- window update ---
SP2_MM_AlignDetailsWinUpdate

