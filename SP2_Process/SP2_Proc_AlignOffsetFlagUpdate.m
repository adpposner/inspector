%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignOffsetFlagUpdate
%% 
%%  Switching on/off baseline offset for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.procAlignOffset = get(fm.proc.alignOffsetFlag,'Value');
set(fm.proc.alignOffsetFlag,'Value',flag.procAlignOffset)

%--- window update ---
SP2_Proc_ProcessWinUpdate

