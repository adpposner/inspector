%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_FidZfUpdate
%% 
%%  Spectral zero-filling for visualization purposes only.
%%
%%  02-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- update points ---
data.fidZf = max(str2num(get(fm.data.fidZf,'String')),1);

%--- consistency check ---
data.fidZf = max(min(data.fidZf,1024*64),512);

%--- window update ---
set(fm.data.fidZf,'String',sprintf('%.0f',data.fidZf))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

end
