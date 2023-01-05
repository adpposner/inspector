%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AmplWinUpdate
%% 
%%  Update amplitude window
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- update amplitude window ---
data.amplMin = str2num(get(fm.data.amplMin,'String'));
data.amplMax = str2num(get(fm.data.amplMax,'String'));
set(fm.data.amplMin,'String',num2str(data.amplMin))
set(fm.data.amplMax,'String',num2str(data.amplMax))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

