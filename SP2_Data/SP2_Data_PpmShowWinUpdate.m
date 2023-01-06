%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmShowWinUpdate
%% 
%%  Update visualization frequency window.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- update ppm window ---
data.ppmShowMin = str2num(get(fm.data.ppmShowMin,'String'));
data.ppmShowMax = str2num(get(fm.data.ppmShowMax,'String'));
set(fm.data.ppmShowMin,'String',sprintf('%.2f',data.ppmShowMin))
set(fm.data.ppmShowMax,'String',sprintf('%.2f',data.ppmShowMax))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

end
