%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
    function SP2_Data_ScrollReceiverIncr
%% 
%%  Increase receiver number of spectral data set to be visualized.
%%
%%  01-2012, Christoph Juchem
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global fm data

%--- update receiver number ---
if isfield(data.spec1,'nRcvrs')
    data.scrollRcvr = min(data.scrollRcvr+1,data.spec1.nRcvrs);
else
    data.scrollRcvr = min(data.scrollRcvr+1,data.rcvrMax);
end

%--- update display
set(fm.data.scrRcvrNum,'String',num2str(data.scrollRcvr))

%--- figure update ---
SP2_Data_FigureUpdate;

%--- window update ---
SP2_Data_DataWinUpdate

end
