%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_UpdateCalcUpdate
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
flag.procUpdateCalc = get(fm.proc.updateCalc,'Value');

%--- window update ---
set(fm.proc.updateCalc,'Value',flag.procUpdateCalc)
