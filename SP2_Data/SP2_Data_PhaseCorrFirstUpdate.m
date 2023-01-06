%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PhaseCorrFirstUpdate
%% 
%%  Switching on/off phase correction of spectral data.
%%  0: off
%%  1: Klose method (includes frequency correction)
%%  2: global correction via phase of first point of reference FID.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- retrieve parameter ---
if get(fm.data.phCorrFirst,'Value');
    flag.dataPhaseCorr = 2;         % 1st point
else
    flag.dataPhaseCorr = 0;         % off
end

%--- update switches ---
set(fm.data.phCorrKlose,'Value',flag.dataPhaseCorr==1)
set(fm.data.phCorrFirst,'Value',flag.dataPhaseCorr==2)

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
end
