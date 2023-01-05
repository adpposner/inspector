%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_AlignRefFidUpdate
%% 
%%  Update FID number to be used as reference for phase and frequency
%%  alignment. Note the continous, interleaved counting.
%%  1) edited, non-edited.
%%  2) with all scans to be summed together in one data vector
%%
%%  01-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- parameter update ---
data.alignRefFid = max(str2double(get(fm.data.alignRefFid,'String')),1);

%--- window update ---
set(fm.data.alignRefFid,'String',sprintf('%.0f',data.alignRefFid))

%--- window update ---
SP2_Data_DataWinUpdate
