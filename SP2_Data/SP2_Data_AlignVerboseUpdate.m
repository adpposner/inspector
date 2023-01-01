%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignVerboseUpdate
%% 
%%  Switching on/off detailed output of spectral phase/frequency alignment
%%  for procession of arrayed acquisitions.
%%
%%  09-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm flag


%--- parameter update ---
flag.dataAlignVerbose = get(fm.data.alignVerbose,'Value');

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
set(fm.data.alignVerbose,'Value',flag.dataAlignVerbose)

