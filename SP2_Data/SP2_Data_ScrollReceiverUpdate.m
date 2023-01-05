%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ScrollReceiverUpdate
%% 
%%  Update receiver number for raw FID/spectrum visualization.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data


%--- parameter update ---
data.scrollRcvr = str2double(get(fm.data.scrRcvrNum,'String'));

%--- consistency check ---
if isfield(data.spec1,'nRcvrs')
    data.scrollRcvr = max(min(data.scrollRcvr+1,data.spec1.nRcvrs),1);
else
    data.scrollRcvr = max(min(data.scrollRcvr+1,data.rcvrMax),1);
end

%--- window update ---
set(fm.data.scrRcvrNum,'String',sprintf('%.0f',data.scrollRcvr))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate
