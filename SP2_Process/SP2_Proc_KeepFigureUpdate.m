%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Proc_KeepFigureUpdate
%% 
%%  Switching on/off figure preservation
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.procKeepFig = get(fm.proc.keepFigure,'Value');

%--- window update ---
set(fm.proc.keepFigure,'Value',flag.procKeepFig)

end
