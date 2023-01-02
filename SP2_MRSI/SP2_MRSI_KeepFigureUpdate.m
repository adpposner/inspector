%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_KeepFigureUpdate
%% 
%%  Switching on/off figure preservation
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.mrsiKeepFig = get(fm.mrsi.keepFigure,'Value');

%--- window update ---
set(fm.mrsi.keepFigure,'Value',flag.mrsiKeepFig)
