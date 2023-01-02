%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignStretchFlagUpdate
%% 
%%  Switching on/off spectral stretch for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.procAlignStretch = get(fm.proc.alignStretchFlag,'Value');
set(fm.proc.alignStretchFlag,'Value',flag.procAlignStretch)

%--- window update ---
SP2_Proc_ProcessWinUpdate

