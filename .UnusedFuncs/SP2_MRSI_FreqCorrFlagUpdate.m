%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MRSI_FreqCorrFlagUpdate
%% 
%%  Switching on/off water based scan-by-scan frequency correction
%%
%%  08-2008, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- update flag parameter ---
flag.mrsiFreqCorr = get(fm.mrsi.freqCorr,'Value');
set(fm.mrsi.freqCorr,'Value',flag.mrsiFreqCorr)

%--- window update ---
SP2_MRSI_MrsiWinUpdate

%--- analysis update ---
SP2_MRSI_ProcAndPlotUpdate

end
