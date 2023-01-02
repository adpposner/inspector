%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignPhaseSpecRgOneUpdate
%% 
%%  Switching on/off between 1 and 2 spectral windows for phase alignment.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- retrieve parameter ---
flag.dataAlignPhSpecRg = ~get(fm.data.align.phSpecRgOne,'Value');

%--- update switches ---
set(fm.data.align.phSpecRgOne,'Value',~flag.dataAlignPhSpecRg)
set(fm.data.align.phSpecRgTwo,'Value',flag.dataAlignPhSpecRg)

%--- window update ---
SP2_Data_AlignDetailsWinUpdate

