%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitAnaLbFlagUpdate
%% 
%%  Switching on/off exponential line broadening for LCModel analysis.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmAnaLb = get(fm.lcm.fit.lb,'Value');
set(fm.lcm.fit.lb,'Value',flag.lcmAnaLb)

%--- window update ---
SP2_LCM_FitDetailsWinUpdate
SP2_LCM_LCModelWinUpdate

