%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ProcZfUpdate
%% 
%%  Update time-domain zero-filling number of points for spectrum 1.
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss flag


%--- update ZF value ---
marss.procZf = str2num(get(fm.marss.procZfVal,'String'));
set(fm.marss.procZfVal,'String',sprintf('%.0f',marss.procZf))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
