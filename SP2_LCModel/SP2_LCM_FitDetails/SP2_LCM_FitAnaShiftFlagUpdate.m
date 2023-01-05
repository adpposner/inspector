%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_FitAnaShiftFlagUpdate
%% 
%%  Switching on/off amplitude shift for spectrum alignment.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmAnaShift = get(fm.lcm.fit.shift,'Value');
set(fm.lcm.fit.shift,'Value',flag.lcmAnaShift)

%--- window update ---
SP2_LCM_FitDetailsWinUpdate
SP2_LCM_LCModelWinUpdate


