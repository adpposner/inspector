%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmTargetWinUpdate
%% 
%%  Update visualization frequency window.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- update ppm window ---
data.ppmTargetMin = str2num(get(fm.data.ppmTargetMin,'String'));
data.ppmTargetMax = str2num(get(fm.data.ppmTargetMax,'String'));
set(fm.data.ppmTargetMin,'String',sprintf('%.2f',data.ppmTargetMin))
set(fm.data.ppmTargetMax,'String',sprintf('%.2f',data.ppmTargetMax))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
