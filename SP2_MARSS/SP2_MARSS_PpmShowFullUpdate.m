%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_PpmShowFullUpdate
%% 
%%  Updates radiobutton setting: full sweep width visualization
%%
%%  11-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.marssPpmShow = get(fm.marss.ppmShowFull,'Value');

%--- switch radiobutton ---
set(fm.marss.ppmShowFull,'Value',flag.marssPpmShow)
set(fm.marss.ppmShowDirect,'Value',~flag.marssPpmShow)

%--- window update ---
SP2_MARSS_MARSSWinUpdate

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate
