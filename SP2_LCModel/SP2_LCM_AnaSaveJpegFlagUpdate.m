%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_AnaSaveJpegFlagUpdate
%% 
%%  Saves figures not only as Matlab figures (.fig), but also as jpeg for
%%  direct visual inspection.
%%
%%  08-2017, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag handling ---
flag.lcmSaveJpeg = get(fm.lcm.saveJpeg,'Value');

%--- update flag displays ---
set(fm.lcm.saveJpeg,'Value',flag.lcmSaveJpeg)

%--- window update ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_BasisProcAndPlotUpdate

%--- analysis update ---
SP2_LCM_FitFigureUpdate

end
