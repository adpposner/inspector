%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignGbFlagUpdate
%% 
%%  Switching on/off Gaussian line broadening for spectrum alignment.
%%
%%  03-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.procAlignGb = get(fm.proc.alignGbFlag,'Value');
set(fm.proc.alignGbFlag,'Value',flag.procAlignGb)

%--- window update ---
SP2_Proc_ProcessWinUpdate


end
