%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_MCarloRefUpdate
%% 
%%  Update flag for LCM  of Monte-Carlo analysis:
%%  1: Perform reference LCM analysis
%%  0: Use the current LCM result as reference
%%
%%  06-2016, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag handling ---
flag.lcmMCarloRef = get(fm.lcm.anaMCarloRef,'Value');

%--- update flag displays ---
set(fm.lcm.anaMCarloRef,'Value',flag.lcmMCarloRef)

%--- window update ---
SP2_LCM_LCModelWinUpdate


end
