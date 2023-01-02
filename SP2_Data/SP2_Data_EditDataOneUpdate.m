%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_EditDataOneUpdate
%% 
%%  Edit(ON) data selection in combined JDE experiment:
%%  1: first condition / data set
%%  2: second condition / data set
%%  Note that the overall reference is always expected to be last.
%%
%%  11-2013, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global loggingfile fm flag


%--- update flag parameter ---
flag.dataEditNo = 1;

%--- update display ---
set(fm.data.editOne,'Value',flag.dataEditNo==1)
set(fm.data.editTwo,'Value',flag.dataEditNo==2)

%--- window update ---
SP2_Data_DataWinUpdate

