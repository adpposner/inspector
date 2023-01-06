%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_ProcScaleDec1
%% 
%%  0.001 reduced scaling of spectrum 1.
%%
%%  12-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm marss flag


%--- update value spec 1 ---
marss.procScale = marss.procScale - 0.1;
set(fm.marss.procScaleVal,'String',sprintf('%.3f',marss.procScale))

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate

end
