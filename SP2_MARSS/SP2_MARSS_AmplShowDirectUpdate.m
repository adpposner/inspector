%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_AmplShowDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignmen of amplitude limits
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


flag.marssAmplShow = get(fm.marss.amplShowDirect,'Value');

%--- switch radiobutton ---
set(fm.marss.amplShowAuto,'Value',~flag.marssAmplShow)
set(fm.marss.amplShowDirect,'Value',flag.marssAmplShow)

%--- update window ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate


