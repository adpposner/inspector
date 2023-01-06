%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_FrequCorrPointUpdate
%% 
%%  Switch between frequency correction methods.
%%  1: frequency of maximum spectral (single) point of reference peak
%%  0: frequency of maximum value of interpolated/modeled maximum.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- retrieve parameter ---
flag.dataFrequCorr = get(fm.data.frCorrPoint,'Value');

%--- update switches ---
set(fm.data.frCorrPoint,'Value',flag.dataFrequCorr)
set(fm.data.frCorrPeak,'Value',~flag.dataFrequCorr)

end
