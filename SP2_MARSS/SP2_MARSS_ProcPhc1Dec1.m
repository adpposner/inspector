%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ProcPhc1Dec1
%% 
%%  0.1deg decrease of first order phase correction
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss flag


%--- update value spec 1 ---
marss.procPhc1 = marss.procPhc1 - 0.1;
set(fm.marss.procPhc1Val,'String',sprintf('%.1f',marss.procPhc1))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
