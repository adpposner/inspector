%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmNoiseWinUpdate
%% 
%%  Update visualization frequency window.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- update ppm window ---
data.ppmNoiseMin = str2num(get(fm.data.ppmNoiseMin,'String'));
data.ppmNoiseMax = str2num(get(fm.data.ppmNoiseMax,'String'));
set(fm.data.ppmNoiseMin,'String',sprintf('%.2f',data.ppmNoiseMin))
set(fm.data.ppmNoiseMax,'String',sprintf('%.2f',data.ppmNoiseMax))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

end
