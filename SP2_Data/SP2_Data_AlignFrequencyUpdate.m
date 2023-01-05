%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignFrequencyUpdate
%% 
%%  Switching on/off spectral frequency alignment for procession of arrayed
%%  acquisitions.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.dataAlignFrequ = get(fm.data.alignFrequency,'Value');

%--- window update ---
set(fm.data.alignFrequency,'Value',flag.dataAlignFrequ)

