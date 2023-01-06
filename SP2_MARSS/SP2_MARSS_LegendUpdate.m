%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_LegendUpdate
%% 
%%  Update legend radiobutton
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- flag handling ---
flag.marssLegend = get(fm.marss.legend,'Value');

%--- update flag displays ---
set(fm.marss.legend,'Value',flag.marssLegend)

%--- analysis update ---
SP2_MARSS_ProcAndPlotUpdate

end
