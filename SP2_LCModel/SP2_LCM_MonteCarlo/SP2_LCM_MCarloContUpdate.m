%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_MCarloContUpdate
%% 
%%  Update flag for continuation of Monte-Carlo analysis:
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag

%--- flag handling ---
flag.lcmMCarloCont = get(fm.lcm.anaMCarloCont,'Value');

%--- update flag displays ---
set(fm.lcm.anaMCarloCont,'Value',flag.lcmMCarloCont)

%--- window update ---
SP2_LCM_LCModelWinUpdate

