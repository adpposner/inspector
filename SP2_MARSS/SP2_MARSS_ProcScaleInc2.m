%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ProcScaleInc2
%% 
%%  0.01 increased scaling of spectrum 1.
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm marss flag


%--- update value spec 1 ---
marss.procScale = marss.procScale + 1;
set(fm.marss.procScaleVal,'String',sprintf('%.3f',marss.procScale))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
