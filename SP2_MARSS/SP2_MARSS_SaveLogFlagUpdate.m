%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_SaveLogFlagUpdate
%% 
%%  Update log file flag.
%%
%%  01-2020, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag handling ---
flag.marssSaveLog = get(fm.marss.saveLog,'Value');

%--- update flag displays ---
set(fm.marss.saveLog,'Value',flag.marssSaveLog)

%--- window update ---
SP2_MARSS_MARSSWinUpdate


end
