%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_ColormapLegendUpdate
%% 
%%  Enable/disable visualization of data legend.
%%
%%  01-2014, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.mmCMapLegend = get(fm.mm.cmapLegend,'Value');

%--- window update ---
set(fm.mm.cmapLegend,'Value',flag.mmCMapLegend)

%--- figure update ---
SP2_MM_SatRecShowSpecSuper(0);
SP2_MM_T1ShowSpecSuper(0);
SP2_MM_ExpFitAnalysis(0);

%--- window update ---
SP2_MM_MacroWinUpdate

end
