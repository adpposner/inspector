%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AmplAutoUpdate
%% 
%%  Updates radiobutton setting: automatic determination of reasonable
%%  amplitude limits
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

flag.dataAmpl = ~get(fm.data.amplAuto,'Value');

%--- switch radiobutton ---
set(fm.data.amplAuto,'Value',~flag.dataAmpl)
set(fm.data.amplDirect,'Value',flag.dataAmpl)

%--- figure update ---
SP2_Data_FigureUpdate;

%--- update window ---
SP2_Data_DataWinUpdate

