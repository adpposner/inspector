%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PhaseCorrNrUpdate
%% 
%%  Number of water reference (in an arrayed experiment) applied for Klose
%%  correction
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm data


%--- parameter update ---
data.phaseCorrNr = max(round(str2double(get(fm.data.phaseCorrNr,'String'))),1);

%--- window update ---
set(fm.data.phaseCorrNr,'String',sprintf('%.0f',data.phaseCorrNr))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
