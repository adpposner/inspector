%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_RcvrWeightUpdate
%% 
%%  Switching on/off signal-weighted summation of spectral data.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.dataRcvrWeight = get(fm.data.rcvrWeight,'Value');

%--- window update ---
set(fm.data.rcvrWeight,'Value',flag.dataRcvrWeight)

end
