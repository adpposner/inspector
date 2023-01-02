%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_MCarloInitUpdate
%% 
%%  Update flag for LCM initialization of Monte-Carlo analysis:
%%  1: Init LCM fit with result form previous analysis
%%  0: Reset all parameters for every LCM analysis
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- flag handling ---
flag.lcmMCarloInit = get(fm.lcm.anaMCarloInit,'Value');

%--- update flag displays ---
set(fm.lcm.anaMCarloInit,'Value',flag.lcmMCarloInit)

%--- window update ---
SP2_LCM_LCModelWinUpdate

