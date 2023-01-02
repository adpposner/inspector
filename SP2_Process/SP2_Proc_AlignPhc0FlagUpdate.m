%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignPhc0FlagUpdate
%% 
%%  Switching on/off zero order phase correction for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.procAlignPhc0 = get(fm.proc.alignPhc0Flag,'Value');
set(fm.proc.alignPhc0Flag,'Value',flag.procAlignPhc0)

%--- window update ---
SP2_Proc_ProcessWinUpdate

