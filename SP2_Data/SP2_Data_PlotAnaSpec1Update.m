%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PlotAnaSpec1Update
%% 
%%  Data selection for analysis:
%%  1: FID 1
%%  2: spectrum 1
%%  3: FID 2
%%  4: spectrum 2
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global flag


%--- update flag parameter ---
flag.dataAna = 2;

%--- window update ---
SP2_Data_DataWinUpdate


end
