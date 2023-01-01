%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ScrollReceiverDecr
%% 
%%  Decrease receiver number of spectral data set to be visualized.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

%--- update receiver number ---
data.scrollRcvr = max(data.scrollRcvr-1,1);

%--- update display
set(fm.data.scrRcvrNum,'String',num2str(data.scrollRcvr))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
