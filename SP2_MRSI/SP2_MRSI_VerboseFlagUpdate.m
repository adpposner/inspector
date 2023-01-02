%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_VerboseFlagUpdate
%% 
%%  Switch for extended parameter/result display
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.verbose = get(fm.mrsi.verbose,'Value');

%--- window update ---
set(fm.mrsi.verbose,'Value',flag.verbose)
