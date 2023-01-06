%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignAmplitudeUpdate
%% 
%%  Switching on/off spectral amplitude correction for procession of arrayed
%%  acquisitions.
%%
%%  12-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.dataAlignAmpl = get(fm.data.alignAmplitude,'Value');

%--- window update ---
set(fm.data.alignAmplitude,'Value',flag.dataAlignAmpl)


end
