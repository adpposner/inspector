%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ScrollRepetitionUpdate
%% 
%%  Update repetition number for raw FID/spectrum visualization.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- parameter update ---
data.scrollRep = str2double(get(fm.data.scrRepNum,'String'));

%--- consistency check ---
data.scrollRep = max(data.scrollRep,1);

%--- window update ---
set(fm.data.scrRepNum,'String',sprintf('%.0f',data.scrollRep))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

end
