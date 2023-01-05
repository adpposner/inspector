%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_UpdateCalcUpdate
%% 
%%  Switching on/off calculation updating.
%%  Automatic updating is handy to optimize reconstruction parameters,
%%  however, it must be disabled e.g. once baseline correction has been
%%  applied.
%%
%%  02-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.mrsiUpdateCalc = get(fm.mrsi.updateCalc,'Value');

%--- window update ---
set(fm.mrsi.updateCalc,'Value',flag.mrsiUpdateCalc)
