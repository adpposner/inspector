%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignPhc1FlagUpdate
%% 
%%  Switching on/off first order phase correction for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.procAlignPhc1 = get(fm.proc.alignPhc1Flag,'Value');
set(fm.proc.alignPhc1Flag,'Value',flag.procAlignPhc1)

%--- window update ---
SP2_Proc_ProcessWinUpdate

