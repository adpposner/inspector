%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_MM_AlignAmplitudeUpdate
%% 
%%  Switching on/off spectral amplitude correction for procession of arrayed
%%  acquisitions.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- parameter update ---
flag.mmAlignAmpl = get(fm.mm.align.amplitude,'Value');

%--- window update ---
set(fm.mm.align.amplitude,'Value',flag.mmAlignAmpl)

