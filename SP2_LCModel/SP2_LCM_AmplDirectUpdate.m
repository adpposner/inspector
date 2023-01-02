%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AmplDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignmen of amplitude limits
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


flag.lcmAmpl = get(fm.lcm.amplDirect,'Value');

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
