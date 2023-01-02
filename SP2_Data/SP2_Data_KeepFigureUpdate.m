%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_KeepFigureUpdate
%% 
%%  Switching on/off figure preservation
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.dataKeepFig = get(fm.data.keepFigure,'Value');

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
set(fm.data.keepFigure,'Value',flag.dataKeepFig)
