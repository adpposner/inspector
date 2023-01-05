%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_AmplShowAutoUpdate
%% 
%%  Updates radiobutton setting: automatic determination of reasonable
%%  amplitude limits
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.marssAmplShow = ~get(fm.marss.amplShowAuto,'Value');

%--- switch radiobutton ---
set(fm.marss.amplShowAuto,'Value',~flag.marssAmplShow)
set(fm.marss.amplShowDirect,'Value',flag.marssAmplShow)

%--- update window ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate


