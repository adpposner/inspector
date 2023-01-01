%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ColormapJetUpdate
%% 
%%  Updates radiobutton settings to switch color modes:
%%  1) JET
%%  2) Uns Uwe Club
%%  3) HOT
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag

%--- flag handling ---
flag.colormap = 0;

%--- update flag displays ---
set(fm.data.cMapJet,'Value',1)
set(fm.data.cMapHsv,'Value',0)
set(fm.data.cMapHot,'Value',0)

%--- figure update ---
SP2_Data_FigureUpdate;

%--- update window ---
SP2_Data_DataWinUpdate
