%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_FIDsSelectUpdate
%% 
%%  Data summation mode:
%%  1: all available FIDs
%%  0: selected FID range
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- retrieve parameter ---
flag.dataAllSelect = ~get(fm.data.sumSelect,'Value');

%--- update switches ---
set(fm.data.sumAll,'Value',flag.dataAllSelect)
set(fm.data.sumSelect,'Value',~flag.dataAllSelect)

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
