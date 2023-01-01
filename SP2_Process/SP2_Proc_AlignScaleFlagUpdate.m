%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_AlignScaleFlagUpdate
%% 
%%  Switching on/off amplitude scaling for spectrum alignment.
%%
%%  09-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.procAlignScale = get(fm.proc.alignScaleFlag,'Value');
set(fm.proc.alignScaleFlag,'Value',flag.procAlignScale)

%--- window update ---
SP2_Proc_ProcessWinUpdate

