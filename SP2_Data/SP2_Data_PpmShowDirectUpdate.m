%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PpmShowDirectUpdate
%% 
%%  Updates radiobutton setting: direct assignment of (zoomed) ppm range
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- flag update ---
flag.dataPpmShow = get(fm.data.ppmShowDirect,'Value');

%--- switch radiobutton ---
set(fm.data.ppmShowFull,'Value',~flag.dataPpmShow)
set(fm.data.ppmShowDirect,'Value',flag.dataPpmShow)

%--- figure update ---
SP2_Data_FigureUpdate;

%--- update window ---
SP2_Data_DataWinUpdate