%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_PhaseLinearCorrectionUpdate
%% 
%%  Switching on/off linear phase (i.e. frequency correction) of FIDs
%%  (display only).
%%
%%  04-2015, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.dataPhaseLinCorr = get(fm.data.phaseLinCorr,'Value');
set(fm.data.phaseLinCorr,'Value',flag.dataPhaseLinCorr)

%--- figure update ---
SP2_Data_FigureUpdate;


