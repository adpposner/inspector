%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaScaleFlagUpdate
%% 
%%  Switching on/off amplitude scaling in reset of starting values only.
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.lcmAnaScale = get(fm.lcm.anaScaleFlag,'Value');
set(fm.lcm.anaScaleFlag,'Value',flag.lcmAnaScale)

%--- window update ---
SP2_LCM_LCModelWinUpdate

