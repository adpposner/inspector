%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmAssignUpdate
%% 
%%  Update frequency assignment value in [ppm].
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data


%--- update percentage value ---
data.ppmAssign = str2num(get(fm.data.ppmAssign,'String'));
set(fm.data.ppmAssign,'String',num2str(data.ppmAssign))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
