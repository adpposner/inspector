%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_PpmNoiseWinUpdate
%% 
%%  Update of noise frequency window.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm proc


%--- update ppm window ---
proc.ppmNoiseMin = str2num(get(fm.proc.ppmNoiseMin,'String'));
proc.ppmNoiseMax = str2num(get(fm.proc.ppmNoiseMax,'String'));
set(fm.proc.ppmNoiseMin,'String',sprintf('%.2f',proc.ppmNoiseMin))
set(fm.proc.ppmNoiseMax,'String',sprintf('%.2f',proc.ppmNoiseMax))

%--- window update ---
SP2_Proc_ProcessWinUpdate

%--- analysis update ---
SP2_Proc_ProcAndPlotUpdate

end
