%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AmplAutoUpdate
%% 
%%  Updates radiobutton setting: automatic determination of reasonable
%%  amplitude limits
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


flag.lcmAmpl = ~get(fm.lcm.amplAuto,'Value');

%--- switch radiobutton ---
set(fm.lcm.amplAuto,'Value',~flag.lcmAmpl)
set(fm.lcm.amplDirect,'Value',flag.lcmAmpl)

%--- update window ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate
