%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignPhaseUpdate
%% 
%%  Switching on/off spectral phase alignment for procession of arrayed
%%  acquisitions.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.dataAlignPhase = get(fm.data.alignPhase,'Value');

%--- window update ---
set(fm.data.alignPhase,'Value',flag.dataAlignPhase)

