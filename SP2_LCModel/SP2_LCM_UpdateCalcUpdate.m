%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_UpdateCalcUpdate
%% 
%%  Switching on/off calculation updating.
%%  Automatic updating is handy to optimize reconstruction parameters,
%%  however, it must be disabled e.g. once baseline correction has been
%%  applied.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.lcmUpdateCalc = get(fm.lcm.updateCalc,'Value');

%--- window update ---
set(fm.lcm.updateCalc,'Value',flag.lcmUpdateCalc)
