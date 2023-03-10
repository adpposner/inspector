%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PhaseCorrKloseCombinedUpdate
%% 
%%  Klose correction mode:
%%  1: phase information of all phase cycling steps combined is applied for
%%     Klose phase correction
%%  2: Phase information of individual phase-cycling steps is applied for
%%     Klose phase correction
%%  3: Single water reference from an arrayed experiment is applied for
%%     Klose correction
%%
%%  06-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- retrieve parameter ---
flag.dataKloseMode = 1;

%--- update switches ---
set(fm.data.kloseComb,'Value',flag.dataKloseMode==1)
set(fm.data.kloseSep,'Value',flag.dataKloseMode==2)
set(fm.data.kloseSelect,'Value',flag.dataKloseMode==3)

%--- window update ---
SP2_Data_DataWinUpdate
end
