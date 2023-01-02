%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_KeepFigureUpdate
%% 
%%  Switching on/off figure preservation
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.lcmKeepFig = get(fm.lcm.keepFigure,'Value');

%--- window update ---
set(fm.lcm.keepFigure,'Value',flag.lcmKeepFig)
