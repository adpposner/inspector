%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_RcvrVecUpdate
%% 
%%  Updates radiobutton: Receiver selection.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- retrieve setting ---
data.rcvr(1) = get(fm.data.rcvr1,'Value');
data.rcvr(2) = get(fm.data.rcvr2,'Value');
data.rcvr(3) = get(fm.data.rcvr3,'Value');
data.rcvr(4) = get(fm.data.rcvr4,'Value');
data.rcvr(5) = get(fm.data.rcvr5,'Value');
data.rcvr(6) = get(fm.data.rcvr6,'Value');
data.rcvr(7) = get(fm.data.rcvr7,'Value');
data.rcvr(8) = get(fm.data.rcvr8,'Value');

%--- derive secondary parameters ---
data.rcvrInd = find(data.rcvr);
data.rcvrN   = length(data.rcvrInd);

%--- update display ---
set(fm.data.rcvr1,'Value',data.rcvr(1))
set(fm.data.rcvr2,'Value',data.rcvr(2))
set(fm.data.rcvr3,'Value',data.rcvr(3))
set(fm.data.rcvr4,'Value',data.rcvr(4))
set(fm.data.rcvr5,'Value',data.rcvr(5))
set(fm.data.rcvr6,'Value',data.rcvr(6))
set(fm.data.rcvr7,'Value',data.rcvr(7))
set(fm.data.rcvr8,'Value',data.rcvr(8))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate