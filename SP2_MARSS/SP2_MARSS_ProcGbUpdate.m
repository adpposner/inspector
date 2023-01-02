%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ProcGbUpdate
%% 
%%  Update line Gaussian broadening for spectrum 1
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss flag


%--- update percentage value ---
marss.procGb = str2num(get(fm.marss.procGbVal,'String'));
set(fm.marss.procGbVal,'String',sprintf('%.2f',marss.procGb))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
