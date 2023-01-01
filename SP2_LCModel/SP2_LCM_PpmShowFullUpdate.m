%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_PpmShowFullUpdate
%% 
%%  Updates radiobutton setting: full sweep width visualization
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.lcmPpmShow = ~get(fm.lcm.ppmShowFull,'Value');

%--- switch radiobutton ---
set(fm.lcm.ppmShowFull,'Value',~flag.lcmPpmShow)
set(fm.lcm.ppmShowDirect,'Value',flag.lcmPpmShow)

%--- update window ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
