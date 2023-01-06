%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_LCM_DataDataUpdate
%% 
%%  Updates radiobutton setting for data selection:
%%  1: Import from Data page
%%  2: Import from Processing page
%%  3: Import from MRSI page
%%  4: Import from synthesis page
%%  5: Import from MARSS page
%%  6: Load directly from LCM page
%%
%%  10-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- data selection ---
flag.lcmData = 1;

%--- switch radiobutton ---
set(fm.lcm.dataData,'Value',flag.lcmData==1)
set(fm.lcm.dataProc,'Value',flag.lcmData==2)
set(fm.lcm.dataMrsi,'Value',flag.lcmData==3)
set(fm.lcm.dataSyn,'Value',flag.lcmData==4)
set(fm.lcm.dataMarss,'Value',flag.lcmData==5)
set(fm.lcm.dataLcm,'Value',flag.lcmData==6)

%--- update window ---
SP2_LCM_LCModelWinUpdate

%--- analysis update ---
SP2_LCM_ProcAndPlotUpdate

end
