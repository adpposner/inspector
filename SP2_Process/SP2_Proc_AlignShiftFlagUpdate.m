%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignShiftFlagUpdate
%% 
%%  Switching on/off amplitude shift for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.procAlignShift = get(fm.proc.alignShiftFlag,'Value');
set(fm.proc.alignShiftFlag,'Value',flag.procAlignShift)

%--- window update ---
SP2_Proc_ProcessWinUpdate

