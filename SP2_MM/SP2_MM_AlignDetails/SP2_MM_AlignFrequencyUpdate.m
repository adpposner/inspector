%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignFrequencyUpdate
%% 
%%  Switching on/off spectral frequency alignment for procession of arrayed
%%  acquisitions.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.mmAlignFrequ = get(fm.mm.align.frequency,'Value');

%--- window update ---
set(fm.mm.align.frequency,'Value',flag.mmAlignFrequ)


end
