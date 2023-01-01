%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_FidCutUpdate
%% 
%%  FID apodization of spectrum visualization purposes only.
%%
%%  03-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- update points ---
data.fidCut = max(str2num(get(fm.data.fidCut,'String')),1);

%--- consistency check ---
data.fidCut = max(min(data.fidCut,1024*16),1);

%--- window update ---
set(fm.data.fidCut,'String',sprintf('%.0f',data.fidCut))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
