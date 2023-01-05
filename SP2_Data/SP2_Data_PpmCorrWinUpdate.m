%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmCorrWinUpdate
%% 
%%  Update frequency window
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- parameter update ---
data.ppmCorrMin = str2num(get(fm.data.ppmCorrMin,'String'));
data.ppmCorrMax = str2num(get(fm.data.ppmCorrMax,'String'));

%--- window update ---
set(fm.data.ppmCorrMin,'String',sprintf('%.2f',data.ppmCorrMin))
set(fm.data.ppmCorrMax,'String',sprintf('%.2f',data.ppmCorrMax))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
