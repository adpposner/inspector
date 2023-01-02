%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Syn_UpdateCalcUpdate
%% 
%%  Switching on/off calculation updating.
%%  Automatic updating is handy to optimize reconstruction parameters,
%%  however, it must be disabled e.g. once baseline correction has been
%%  applied.
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.synUpdateCalc = get(fm.syn.updateCalc,'Value');

%--- window update ---
set(fm.syn.updateCalc,'Value',flag.synUpdateCalc)
