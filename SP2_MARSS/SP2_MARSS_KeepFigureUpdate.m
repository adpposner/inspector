%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MARSS_KeepFigureUpdate
%% 
%%  Switching on/off figure preservation
%%
%%  01-2019, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.marssKeepFig = get(fm.marss.keepFigure,'Value');

%--- window update ---
set(fm.marss.keepFigure,'Value',flag.marssKeepFig)

end
