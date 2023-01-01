%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignLbFlagUpdate
%% 
%%  Switching on/off exponential line broadening for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.procAlignLb = get(fm.proc.alignLbFlag,'Value');
set(fm.proc.alignLbFlag,'Value',flag.procAlignLb)

%--- window update ---
SP2_Proc_ProcessWinUpdate

