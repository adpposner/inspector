%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignAmplExtraWinUpdate
%% 
%%  Update function to include/exclude extra spectral window with user-
%%  defined frequency range.
%%
%%  05-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- retrieve parameter ---
flag.amAlignExtraWin = get(fm.data.align.amExtraWin,'Value');

%--- update window ---
set(fm.data.align.amExtraWin,'Value',flag.amAlignExtraWin==1)

%--- window update ---
SP2_Data_AlignDetailsWinUpdate

